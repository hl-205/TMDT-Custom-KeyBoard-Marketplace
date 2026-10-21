package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/payment-qr")
public class PaymentQrServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/my-orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            req.setAttribute("order", order);
            req.getRequestDispatcher("payment-qr.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/my-orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Khách hàng bấm nút "Đã hoàn tất chuyển khoản"
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isBlank()) {
            try {
                int orderId = Integer.parseInt(orderIdStr.trim());
                orderDAO.updatePaymentSuccess(orderId, "VIETQR");
                Order order = orderDAO.getOrderById(orderId);

                req.setAttribute("isSuccess", true);
                req.setAttribute("message", "Xác nhận chuyển khoản VietQR thành công! Đơn hàng của bạn đã được thanh toán.");
                req.setAttribute("orderCode", order != null ? order.getOrderCode() : ("KH" + orderId));
                req.setAttribute("amount", order != null ? order.getTotalAmount().longValue() : 0);
                req.setAttribute("bankCode", "VietQR (Napas 247)");
                req.setAttribute("transactionNo", "QR" + System.currentTimeMillis());
                req.setAttribute("payDate", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()));
                req.setAttribute("order", order);

                req.getRequestDispatcher("payment-result.jsp").forward(req, resp);
                return;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        resp.sendRedirect(req.getContextPath() + "/my-orders");
    }
}
