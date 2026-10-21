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
        int shopId = (sellerShop != null) ? sellerShop.getId() : 2;

        request.setAttribute("sellerShop", sellerShop);
        request.setAttribute("totalOrdersCount", customDAO.countOrdersByShopAndStatus(shopId, "ALL", false));
        request.setAttribute("pendingCount", customDAO.countOrdersByShopAndStatus(shopId, "PENDING", false));
        request.setAttribute("pendingCustomCount", customDAO.countOrdersByShopAndStatus(shopId, "PENDING", true));
        request.setAttribute("processingCount", customDAO.countOrdersByShopAndStatus(shopId, "PROCESSING", false));
        request.setAttribute("processingCustomCount", customDAO.countOrdersByShopAndStatus(shopId, "PROCESSING", true));
        request.setAttribute("shippingCount", customDAO.countOrdersByShopAndStatus(shopId, "SHIPPING", false));
        request.setAttribute("completedCount", customDAO.countOrdersByShopAndStatus(shopId, "COMPLETED", false));

        String path = request.getServletPath();
        if ("/seller-confirm-custom".equals(path)) {
            CustomOrder order = null;
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isBlank()) {
                try {
                    order = customDAO.getOrderById(Integer.parseInt(idParam));
                } catch (Exception ignored) {}
            }
            if (order == null) {
                List<CustomOrder> pendingList = customDAO.getOrdersForSellerByShop(shopId, "PENDING", true);
                if (!pendingList.isEmpty()) {
                    order = pendingList.get(0);
                }
            }
            request.setAttribute("order", order);
            request.getRequestDispatcher("seller-confirm-custom.jsp").forward(request, response);
            return;
        }

        String status = request.getParameter("status");
        if (status == null || status.isEmpty()) status = "ALL";
        boolean onlyCustom = "1".equals(request.getParameter("custom"));

        List<CustomOrder> orders = customDAO.getOrdersForSellerByShop(shopId, status, onlyCustom);
        request.setAttribute("orders", orders);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("onlyCustom", onlyCustom);
        request.getRequestDispatcher("seller-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String decision = request.getParameter("decision");
        int orderId = 0;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (Exception ignored) {}

        if ("complete".equals(decision)) {
            customDAO.markOrderCompleted(orderId);
            response.sendRedirect("seller-orders?msg=completed");
            return;
        }

        String shopNote = request.getParameter("shopNote");
        if ("reject".equals(decision)) {
            customDAO.rejectCustomOrder(orderId, shopNote);
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

        customDAO.acceptCustomOrder(orderId, committedDays, shopNote, extraFee);
        response.sendRedirect("seller-progress?id=" + orderId + "&msg=accepted");
    }
}