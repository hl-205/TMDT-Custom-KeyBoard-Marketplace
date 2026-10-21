package controller;

import dao.CartDAO;
import dao.AddressDAO;
import dao.OrderDAO;
import dao.ProductDAO;
import model.CartItem;
import model.Order;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

@WebServlet(urlPatterns = {"/checkout", "/order-success"})
public class CheckoutServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    private Map<String, CartItem> loadCart(HttpSession session) {
        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            User user = (User) session.getAttribute("user");
            cart = user == null ? new LinkedHashMap<>() : new CartDAO().getCartByUserId(user.getId());
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    @SuppressWarnings("unchecked")
    private Map<String, CartItem> selectItems(HttpServletRequest req, Map<String, CartItem> cart) {
        String[] keys = req.getParameterValues("sel");
        if (keys == null) {
            List<String> saved = (List<String>) req.getSession().getAttribute("checkoutSelectedKeys");
            keys = saved == null ? new String[0] : saved.toArray(new String[0]);
        }
        Map<String, CartItem> selected = new LinkedHashMap<>();
        for (String key : keys) {
            CartItem item = cart.get(key);
            if (item != null) selected.put(key, item);
        }
        return selected;
    }

    private void showOrderSuccess(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Order found = null;
            for (Order order : new OrderDAO().findByUser(user.getId())) {
                if (order.getId() == id) { found = order; break; }
            }
            if (found == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
            req.setAttribute("order", found);
            // Gợi ý sản phẩm từ database, không ảnh hưởng đến việc hiển thị đơn hàng.
            try {
                req.setAttribute("recommendedProducts",
                        new ProductDAO().getSimilarProducts(0, 3));
            } catch (Exception recommendationError) {
                log("Không tải được sản phẩm gợi ý", recommendationError);
                req.setAttribute("recommendedProducts", Collections.emptyList());
            }
            req.getRequestDispatcher("/order-success.jsp").forward(req, resp);
        } catch (NumberFormatException ex) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/order-success".equals(req.getServletPath())) {
            showOrderSuccess(req, resp);
            return;
        }
        HttpSession session = req.getSession();
        Map<String, CartItem> cart = loadCart(session);
        if (cart.isEmpty()) {
            session.setAttribute("flashError", "Giỏ hàng đang trống.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        Map<String, CartItem> selected = selectItems(req, cart);
        if (selected.isEmpty()) {
            session.setAttribute("flashError", "Vui lòng chọn ít nhất một sản phẩm để thanh toán.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        session.setAttribute("checkoutSelectedKeys", new ArrayList<>(selected.keySet()));
        long subtotal = 0;
        Set<Integer> shopIds = new HashSet<>();
        for (CartItem item : selected.values()) {
            subtotal = Math.addExact(subtotal, item.getLineTotal().longValueExact());
            shopIds.add(item.getProduct().getShopId());
        }
        long discount = 0;
        String code = (String) session.getAttribute("appliedCouponCode");
        if (code != null && !code.isBlank()) {
            try {
                CartDAO coupons = new CartDAO();
                Map<String, Object> coupon = coupons.findCoupon(code);
                if (coupons.isCouponValid(coupon, subtotal)) {
                    discount = Math.max(0, Math.min(subtotal, coupons.calculateDiscount(coupon, subtotal)));
                } else {
                    session.removeAttribute("appliedCouponCode");
                    code = null;
                }
            } catch (SQLException ex) {
                throw new ServletException("Không thể kiểm tra mã giảm giá", ex);
            }
        }
        // Addresses always come from the DB and belong to the logged-in user.
        User checkoutUser = (User) session.getAttribute("user");
        if (checkoutUser != null) {
            try {
                req.setAttribute("savedAddresses", new AddressDAO().findByUser(checkoutUser.getId()));
            } catch (SQLException ex) {
                log("Cannot load shipping addresses", ex);
                req.setAttribute("addressError", "Không tải được sổ địa chỉ. Kiểm tra bảng user_addresses và cấu hình kết nối MySQL.");
                req.setAttribute("savedAddresses", Collections.emptyList());
            }
        } else {
            req.setAttribute("savedAddresses", Collections.emptyList());
        }
        req.setAttribute("cartItems", new ArrayList<>(selected.values()));
        req.setAttribute("selectedKeys", selected.keySet());
        req.setAttribute("checkoutSubtotal", subtotal);
        req.setAttribute("checkoutTotal", subtotal - discount);
        req.setAttribute("appliedCouponDiscount", discount);
        req.setAttribute("appliedCouponCode", code);
        req.setAttribute("shopCount", shopIds.size());
        Object activeId = session.getAttribute("checkoutActiveAddressId");
        req.setAttribute("activeAddressId", activeId);
        req.setAttribute("addressSuccess", session.getAttribute("checkoutAddressSuccess"));
        req.setAttribute("addressUpdateError", session.getAttribute("checkoutAddressError"));
        session.removeAttribute("checkoutAddressSuccess");
        session.removeAttribute("checkoutAddressError");
        req.setAttribute("checkoutUser", checkoutUser);
        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/order-success".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        // Cập nhật địa chỉ độc lập với thao tác đặt hàng.
        if ("updateAddress".equals(req.getParameter("action"))) {
            try {
                int addressId = Integer.parseInt(req.getParameter("editAddressId"));
                String name = req.getParameter("editReceiverName");
                String phone = req.getParameter("editReceiverPhone");
                String address = req.getParameter("editShippingAddress");
                if (blank(name) || blank(phone) || blank(address)) {
                    session.setAttribute("checkoutAddressError", "Vui lòng nhập đủ thông tin địa chỉ.");
                } else if (!new AddressDAO().update(user.getId(), addressId, name.trim(), phone.trim(), address.trim())) {
                    session.setAttribute("checkoutAddressError", "Không thể sửa địa chỉ này.");
                } else {
                    session.setAttribute("checkoutActiveAddressId", addressId);
                    session.setAttribute("checkoutAddressSuccess", "Đã cập nhật địa chỉ nhận hàng.");
                }
            } catch (Exception ex) {
                log("Lỗi cập nhật địa chỉ", ex);
                session.setAttribute("checkoutAddressError", "Không cập nhật được địa chỉ.");
            }
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }
        Map<String, CartItem> cart = loadCart(session);
        Map<String, CartItem> selected = selectItems(req, cart);
        if (selected.isEmpty()) {
            session.setAttribute("flashError", "Sản phẩm đã chọn không còn trong giỏ hàng.");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }
        String name = req.getParameter("receiverName");
        String phone = req.getParameter("receiverPhone");
        String address = req.getParameter("shippingAddress");
        String shipping = req.getParameter("shippingMethod");
        String payment = req.getParameter("paymentMethod");
        // Do not trust client-supplied address text when an existing address is selected.
        String selectedAddressId = req.getParameter("addressId");
        if (selectedAddressId != null && !"new".equals(selectedAddressId)) {
            try { session.setAttribute("checkoutActiveAddressId", Integer.parseInt(selectedAddressId)); }
            catch (NumberFormatException ignored) { }
        }
        if (selectedAddressId != null && !selectedAddressId.isBlank() && !"new".equals(selectedAddressId)) {
            try {
                int id = Integer.parseInt(selectedAddressId);
                AddressDAO.Address saved = new AddressDAO().findOwned(user.getId(), id);
                if (saved == null) {
                    req.setAttribute("error", "Địa chỉ đã chọn không tồn tại hoặc không thuộc tài khoản này.");
                    doGet(req, resp);
                    return;
                }
                name = saved.getName();
                phone = saved.getPhone();
                address = saved.getAddress();
            } catch (NumberFormatException | SQLException ex) {
                log("Invalid shipping address", ex);
                req.setAttribute("error", "Không thể xác nhận địa chỉ từ cơ sở dữ liệu.");
                doGet(req, resp);
                return;
            }
        }
        if (blank(name) || blank(phone) || blank(address)) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin nhận hàng.");
            doGet(req, resp);
            return;
        }
        long shippingFee;
        switch (shipping == null ? "" : shipping) {
            case "STANDARD": shippingFee = 30000; break;
            case "EXPRESS": shippingFee = 55000; break;
            case "SAME_DAY": shippingFee = 90000; break;
            default:
                req.setAttribute("error", "Vui lòng chọn phương thức vận chuyển hợp lệ.");
                doGet(req, resp);
                return;
        }
        if (payment == null || !Set.of("COD", "VNPAY_QR", "ATM", "BANK_TRANSFER").contains(payment)) {
            req.setAttribute("error", "Phương thức thanh toán không hợp lệ.");
            doGet(req, resp);
            return;
        }
        try {
            if ("new".equals(selectedAddressId) && "on".equals(req.getParameter("saveAddress"))) {
                new AddressDAO().save(user.getId(), name.trim(), phone.trim(), address.trim());
            }
            List<Integer> ids = new OrderDAO().createOrders(
                    user.getId(), name.trim(), phone.trim(), address.trim(),
                    new ArrayList<>(selected.values()),
                    (String) session.getAttribute("appliedCouponCode"), shippingFee, payment);
            if (ids == null || ids.isEmpty()) throw new IllegalStateException("Không tạo được đơn hàng.");
            cart.keySet().removeAll(selected.keySet());
            session.removeAttribute("appliedCouponCode");
            session.removeAttribute("checkoutSelectedKeys");
            session.setAttribute("lastCheckoutOrderIds", ids);
            try {
                new CartDAO().syncCart(user.getId(), cart);
            } catch (Exception syncEx) {
                log("Đơn hàng đã tạo nhưng không đồng bộ được giỏ hàng", syncEx);
            }
            resp.sendRedirect(req.getContextPath() + "/order-success?id=" + ids.get(0));
        } catch (Exception ex) {
            log("Lỗi tạo đơn hàng", ex);
            req.setAttribute("error", "Không thể tạo đơn hàng: " + ex.getMessage());
            doGet(req, resp);
        }
    }

    private boolean blank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
