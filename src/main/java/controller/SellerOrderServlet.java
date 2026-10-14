package controller;

import dao.CustomOrderDAO;
import dao.CustomOrderDAO.CustomOrder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/seller-orders", "/seller-confirm-custom"})
public class SellerOrderServlet extends HttpServlet {
    private final CustomOrderDAO customDAO = new CustomOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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
                order = customDAO.getOrderByCode("KH-284170");
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

        // Nhận đơn xong chuyển thẳng sang màn hình Tiến độ gia công của đơn đó
        response.sendRedirect("seller-progress?id=" + orderId + "&msg=accepted");
    }
}