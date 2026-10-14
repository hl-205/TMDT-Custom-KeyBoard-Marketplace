package controller;

import dao.CustomOrderDAO;
import dao.CustomOrderDAO.CustomOrder;
import dao.ShopDAO;
import model.Shop;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/seller-orders", "/seller-confirm-custom"})
public class SellerOrderServlet extends HttpServlet {
    private final CustomOrderDAO customDAO = new CustomOrderDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login");
            return;
        }

        Shop sellerShop = shopDAO.getShopByOwnerId(currentUser.getId());
        request.setAttribute("sellerShop", sellerShop);
        request.setAttribute("totalOrdersCount", customDAO.countOrdersByStatus("ALL", false));
        request.setAttribute("pendingCount", customDAO.countOrdersByStatus("PENDING", false));
        request.setAttribute("pendingCustomCount", customDAO.countOrdersByStatus("PENDING", true));
        request.setAttribute("processingCount", customDAO.countOrdersByStatus("PROCESSING", false));
        request.setAttribute("processingCustomCount", customDAO.countOrdersByStatus("PROCESSING", true));
        request.setAttribute("shippingCount", customDAO.countOrdersByStatus("SHIPPING", false));
        request.setAttribute("completedCount", customDAO.countOrdersByStatus("COMPLETED", false));

        String path = request.getServletPath();
        if ("/seller-confirm-custom".equals(path)) {
            CustomOrder order = null;
            String idParam = request.getParameter("id");
            if (idParam != null) {
                try {
                    order = customDAO.getOrderById(Integer.parseInt(idParam));
                } catch (Exception ignored) {}
            }
            if (order == null) {
                List<CustomOrder> pendingList = customDAO.getOrdersForSeller("PENDING", true);
                if (!pendingList.isEmpty()) order = pendingList.get(0);
            }
            if (order == null) {
                List<CustomOrder> all = customDAO.getOrdersForSeller("ALL", false);
                if (!all.isEmpty()) order = all.get(0);
            }
            request.setAttribute("order", order);
            request.getRequestDispatcher("seller-confirm-custom.jsp").forward(request, response);
            return;
        }

        String status = request.getParameter("status");
        if (status == null || status.isEmpty()) status = "ALL";
        boolean onlyCustom = "1".equals(request.getParameter("custom"));

        List<CustomOrder> orders = customDAO.getOrdersForSeller(status, onlyCustom);
        request.setAttribute("orders", orders);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("onlyCustom", onlyCustom);
        request.getRequestDispatcher("seller-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String decision = request.getParameter("decision");
        int orderId = 0;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (Exception ignored) {}

        if ("reject".equals(decision)) {
            customDAO.rejectCustomOrder(orderId);
            response.sendRedirect("seller-orders?msg=rejected");
            return;
        }

        int committedDays = 7;
        try {
            committedDays = Integer.parseInt(request.getParameter("committedDays").replaceAll("[^0-9]", ""));
            if (committedDays <= 0) committedDays = 7;
        } catch (Exception ignored) {}

        long extraFee = 0;
        try {
            String extraStr = request.getParameter("extraFee");
            if (extraStr != null && !extraStr.isBlank()) {
                extraFee = Long.parseLong(extraStr.replaceAll("[^0-9]", ""));
            }
        } catch (Exception ignored) {}

        String shopNote = request.getParameter("shopNote");
        customDAO.acceptCustomOrder(orderId, committedDays, shopNote, extraFee);

        response.sendRedirect("seller-progress?id=" + orderId + "&msg=accepted");
    }
}