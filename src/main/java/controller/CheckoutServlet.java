package controller;

import dao.CartDAO;
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
    private final CartDAO cartDAO = new CartDAO();
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

        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Chỉ các sản phẩm tích chọn tại giỏ hàng được chuyển sang thanh toán.
        String[] selected = req.getParameterValues("sel");
        if (selected != null) {
            LinkedHashSet<String> keys = new LinkedHashSet<>();
            for (String key : selected) if (cart.containsKey(key)) keys.add(key);
            session.setAttribute("checkoutSelectedKeys", keys);
        }
        List<CartItem> selectedItems = getSelectedItems(session, cart);
        if (selectedItems.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        BigDecimal selectedTotal = selectedItems.stream().map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        req.setAttribute("total", selectedTotal);
        String appliedCode = (String) session.getAttribute("appliedCouponCode");
        BigDecimal selectedDiscount = BigDecimal.ZERO;
        if (appliedCode != null && !appliedCode.isBlank()) {
            CouponDAO.DiscountResult coupon = couponDAO.calculateDiscount(appliedCode, selectedTotal);
            if (coupon.isValid()) {
                selectedDiscount = coupon.getDiscountAmount();
                req.setAttribute("appliedCouponCode", coupon.getCoupon().getCode());
            }
        }
        req.setAttribute("appliedCouponDiscount", selectedDiscount);
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
        req.setAttribute("cartItems", selectedItems);

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

        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
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
            case "EXPRESS":
                shippingFee = new BigDecimal("50000");
                break;
            case "SAME_DAY":
                shippingFee = new BigDecimal("90000");
                break;
            default:
                shippingFee = new BigDecimal("30000");
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

        // Chỉ tạo đơn từ lựa chọn đã lưu khi chuyển từ giỏ hàng.
        List<CartItem> cartList = getSelectedItems(session, cart);
        if (cartList.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
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
            List<Integer> orderIds = orderDAO.createOrders(
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

            int orderId = orderIds.get(0);
            // Chỉ xóa các dòng đã đặt, giữ lại các dòng chưa được chọn.
            @SuppressWarnings("unchecked")
            Set<String> selectedKeys = (Set<String>) session.getAttribute("checkoutSelectedKeys");
            if (selectedKeys != null) for (String key : selectedKeys) cart.remove(key);
            cartDAO.syncCart(user.getId(), cart);
            session.removeAttribute("checkoutSelectedKeys");
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

    @SuppressWarnings("unchecked")
    private List<CartItem> getSelectedItems(HttpSession session, Map<String, CartItem> cart) {
        Set<String> selectedKeys = (Set<String>) session.getAttribute("checkoutSelectedKeys");
        if (selectedKeys == null || selectedKeys.isEmpty()) return Collections.emptyList();
        List<CartItem> result = new ArrayList<>();
        for (String key : selectedKeys) {
            CartItem item = cart.get(key);
            if (item != null) result.add(item);
        }
        return result;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}