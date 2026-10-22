package controller;

import dao.CouponDAO;
import dao.OrderDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final UserDAO userDAO = new UserDAO();
    private final CouponDAO couponDAO = new CouponDAO();

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Lấy thông tin mới nhất của khách hàng từ DB để tự động điền họ tên, sđt, địa chỉ
        User customer = userDAO.getUserById(sessionUser.getId());
        if (customer != null) {
            session.setAttribute("user", customer);
            req.setAttribute("customer", customer);
        } else {
            req.setAttribute("customer", sessionUser);
        }

        // Lấy danh sách mã khuyến mãi khả dụng trong hệ thống
        req.setAttribute("availableCoupons", couponDAO.getAvailableCoupons());
        req.setAttribute("cartItems", cart.values());

        req.getRequestDispatcher("checkout.jsp").forward(req, resp);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String name = req.getParameter("receiverName");
        String phone = req.getParameter("receiverPhone");
        String address = req.getParameter("shippingAddress");
        String paymentMethod = req.getParameter("paymentMethod");
        String couponCode = req.getParameter("couponCode");
        String shippingMethod = req.getParameter("shippingMethod");
        BigDecimal shippingFee;
        switch (shippingMethod == null ? "STANDARD" : shippingMethod) {
            case "EXPRESS": shippingFee = new BigDecimal("55000"); break;
            case "SAME_DAY": shippingFee = new BigDecimal("90000"); break;
            default: shippingFee = new BigDecimal("30000");
        }
        if (paymentMethod == null || paymentMethod.isBlank()) {
            paymentMethod = "VNPAY-QR";
        }
        if (!Set.of("COD", "VNPAY-QR", "VIETQR").contains(paymentMethod)) {
            req.setAttribute("error", "Phương thức thanh toán không hợp lệ.");
            doGet(req, resp);
            return;
        }

        if (isBlank(name) || isBlank(phone) || isBlank(address)) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            doGet(req, resp);
            return;
        }

        // Tính toán tổng tiền sản phẩm trong giỏ hàng
        List<CartItem> cartList = new ArrayList<>(cart.values());
        BigDecimal subtotal = cartList.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Xác thực mã khuyến mãi phía máy chủ
        BigDecimal discountAmount = BigDecimal.ZERO;
        if (couponCode != null && !couponCode.trim().isEmpty()) {
            CouponDAO.DiscountResult result = couponDAO.calculateDiscount(couponCode.trim(), subtotal);
            if (result.isValid()) {
                discountAmount = result.getDiscountAmount();
                couponCode = result.getCoupon().getCode();
            } else {
                // Mã không hợp lệ nhưng vẫn cho phép tiếp tục đặt hàng không giảm giá, hoặc thông báo
                couponCode = null;
            }
        }

        try {
            int orderId = orderDAO.createOrder(
                    user.getId(),
                    name.trim(),
                    phone.trim(),
                    address.trim(),
                    cartList,
                    discountAmount,
                    paymentMethod,
                    couponCode,
                    shippingFee
            );

            // Dọn sạch giỏ hàng và session voucher
            cart.clear();
            session.removeAttribute("appliedCouponCode");
            session.removeAttribute("appliedDiscountAmount");

            // Điều hướng theo phương thức thanh toán đã chọn
            if ("VNPAY-QR".equalsIgnoreCase(paymentMethod)) {
                resp.sendRedirect(req.getContextPath() + "/vnpay-payment?orderId=" + orderId);
            } else if ("VIETQR".equalsIgnoreCase(paymentMethod)) {
                resp.sendRedirect(req.getContextPath() + "/payment-qr?orderId=" + orderId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/my-orders?success=1&orderId=" + orderId);
            }

        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}