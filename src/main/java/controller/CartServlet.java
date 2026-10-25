package controller;

import com.google.gson.Gson;
import dao.CartDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.Product;
import model.User;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private final CartDAO cartDAO = new CartDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final Gson gson = new Gson();

    @SuppressWarnings("unchecked")
    private Map<String, CartItem> getCart(HttpSession session, User user) {
        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = user == null ? new LinkedHashMap<>() : cartDAO.getCartByUserId(user.getId());
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    private long subtotal(Collection<CartItem> items) {
        long sum = 0;
        for (CartItem item : items) sum = Math.addExact(sum, item.getLineTotal().longValue());
        return Math.max(0, sum);
    }

    private long selectedSubtotal(HttpServletRequest req, Map<String, CartItem> cart) {
        String[] keys = req.getParameterValues("selectedKey");
        if (keys == null) return "true".equals(req.getParameter("selectionProvided")) ? 0 : subtotal(cart.values());
        long sum = 0;
        for (String key : keys) {
            CartItem item = cart.get(key);
            if (item != null) sum = Math.addExact(sum, item.getLineTotal().longValue());
        }
        return Math.max(0, sum);
    }

    private void prepareCoupons(HttpServletRequest req, HttpSession session,
                                Map<String, CartItem> cart) throws SQLException {
        long sum = subtotal(cart.values());
        req.setAttribute("availableCoupons", cartDAO.getAvailableCoupons(sum));
        String code = (String) session.getAttribute("appliedCouponCode");
        long discount = 0;
        if (code != null && !code.isBlank()) {
            Map<String, Object> coupon = cartDAO.findCoupon(code);
            if (cartDAO.isCouponValid(coupon, sum)) {
                discount = cartDAO.calculateDiscount(coupon, sum);
                req.setAttribute("appliedCouponCode", code);
            } else {
                session.removeAttribute("appliedCouponCode");
            }
        }
        req.setAttribute("appliedCouponDiscount", discount);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        Map<String, CartItem> cart = getCart(session, user);
        if (user != null) cartDAO.syncCart(user.getId(), cart);
        req.setAttribute("cartItems", new ArrayList<>(cart.values()));
        int productId = cart.isEmpty() ? 0 : cart.values().iterator().next().getProduct().getId();
        req.setAttribute("recommendedProducts", productDAO.getSimilarProducts(productId, 4));
        try {
            prepareCoupons(req, session, cart);
        } catch (SQLException e) {
            log("Không tải được mã giảm giá", e);
            req.setAttribute("availableCoupons", Collections.emptyList());
            req.setAttribute("appliedCouponDiscount", 0L);
        }
        req.getRequestDispatcher("/cart.jsp").forward(req, resp);
    }

    private void json(HttpServletResponse resp, boolean success, String message,
                      long discount, long total, String code) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", success);
        result.put("message", message);
        result.put("couponDiscount", discount);
        result.put("grandTotal", Math.max(0, total));
        result.put("appliedCouponCode", code == null ? "" : code);
        resp.getWriter().write(gson.toJson(result));
    }

    private int positiveInt(String text, String field) {
        try {
            int n = Integer.parseInt(text);
            if (n > 0) return n;
        } catch (NumberFormatException ignored) { }
        throw new IllegalArgumentException(field + " phải là số nguyên dương.");
    }

    private int nonNegativeInt(String text, String field) {
        try {
            int n = Integer.parseInt(text);
            if (n >= 0) return n;
        } catch (NumberFormatException ignored) { }
        throw new IllegalArgumentException(field + " không hợp lệ.");
    }

    private String text(String s) { return s == null ? "" : s.trim(); }

    // CartItem(Product, int, long, String) theo model thực tế.
    private CartItem createItem(Product product, int qty, String color, String plate, long extra) {
        String variant = (color.isEmpty() ? "" : color)
                + (plate.isEmpty() ? "" : (color.isEmpty() ? "" : " / ") + plate);
        return new CartItem(product, qty, extra, variant);
    }

    private void validateColor(int productId, String color) {
        if (color.isEmpty()) return;
        for (Product.ProductOption option : productDAO.getOptionsByGroup(productId, "COLOR")) {
            if (color.equals(option.getOptionName()) && option.isAvailable()) return;
        }
        throw new IllegalArgumentException("Màu sắc không hợp lệ hoặc đã hết hàng.");
    }

    // Giá phụ phí lấy từ DB, không tin hidden input extraPrice của trình duyệt.
    private long validatedExtraPrice(int productId, String plate) {
        if (plate == null || plate.isBlank()) return 0;
        for (Product.ProductOption option : productDAO.getOptionsByGroup(productId, "plate")) {
            if (plate.equals(option.getOptionName()) && option.isAvailable()) return option.getExtraPrice();
        }
        throw new IllegalArgumentException("Tùy chọn plate không hợp lệ hoặc đã ngừng bán.");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        Map<String, CartItem> cart = getCart(session, user);
        String action = text(req.getParameter("action"));
        if (action.isEmpty()) action = "add";

        if ("applyCoupon".equals(action) || "removeCoupon".equals(action)
                || "recalculateCoupon".equals(action)) {
            long sum = selectedSubtotal(req, cart);
            if ("removeCoupon".equals(action)) {
                session.removeAttribute("appliedCouponCode");
                json(resp, true, "Đã bỏ mã giảm giá.", 0, sum, null);
                return;
            }
            if ("recalculateCoupon".equals(action)) {
                String currentCode = (String) session.getAttribute("appliedCouponCode");
                if (currentCode == null || currentCode.isBlank() || sum <= 0) {
                    if (sum <= 0) session.removeAttribute("appliedCouponCode");
                    json(resp, true, "", 0, sum, sum <= 0 ? null : currentCode);
                    return;
                }
                try {
                    Map<String, Object> current = cartDAO.findCoupon(currentCode);
                    if (!cartDAO.isCouponValid(current, sum)) {
                        session.removeAttribute("appliedCouponCode");
                        json(resp, true, "Mã giảm giá không còn đủ điều kiện với sản phẩm đã chọn.", 0, sum, null);
                    } else {
                        long amount = cartDAO.calculateDiscount(current, sum);
                        json(resp, true, "", amount, sum - amount, currentCode);
                    }
                } catch (SQLException e) {
                    log("Không thể tính lại coupon", e);
                    json(resp, false, "Không thể kiểm tra lại mã giảm giá.", 0, sum, currentCode);
                }
                return;
            }
            String code = text(req.getParameter("couponCode")).toUpperCase(Locale.ROOT);
            if (code.isEmpty()) {
                json(resp, false, "Vui lòng nhập mã giảm giá.", 0, sum, null);
                return;
            }
            try {
                Map<String, Object> coupon = cartDAO.findCoupon(code);
                if (!cartDAO.isCouponValid(coupon, sum)) {
                    json(resp, false, "Mã không hợp lệ, hết hạn hoặc đơn chưa đủ điều kiện.", 0, sum, null);
                    return;
                }
                long discount = cartDAO.calculateDiscount(coupon, sum);
                session.setAttribute("appliedCouponCode", code);
                json(resp, true, "Áp dụng mã thành công!", discount, sum - discount, code);
            } catch (SQLException e) {
                log("Lỗi mã giảm giá", e);
                json(resp, false, "Không thể kiểm tra mã giảm giá.", 0, sum, null);
            }
            return;
        }

        boolean ajax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"));
        boolean buyNow = "1".equals(req.getParameter("buyNow"));
        try {
            switch (action) {
                case "add": {
                    int productId = positiveInt(req.getParameter("productId"), "Sản phẩm");
                    int quantity = positiveInt(req.getParameter("quantity"), "Số lượng");
                    Product product = productDAO.getProductById(productId);
                    if (product == null) throw new IllegalArgumentException("Sản phẩm không tồn tại.");
                    if (product.getStock() < 1) throw new IllegalArgumentException("Sản phẩm đã hết hàng.");
                    String color = text(req.getParameter("color"));
                    String plate = text(req.getParameter("plate"));
                    validateColor(productId, color);
                    long extra = validatedExtraPrice(productId, plate);
                    if (extra < 0) throw new IllegalArgumentException("Phụ phí không hợp lệ.");
                    CartItem incoming = createItem(product, quantity, color, plate, extra);
                    if (buyNow) {
                        // Mua ngay: không đụng tới giỏ hàng, chỉ giữ riêng 1 sản phẩm cho lượt thanh toán này.
                        if (quantity > Math.min(99, product.getStock()))
                            throw new IllegalArgumentException("Số lượng vượt tồn kho.");
                        session.setAttribute("buyNowItem", incoming);
                        break;
                    }
                    String key = incoming.getKey();
                    CartItem existing = cart.get(key);
                    int current = existing == null ? 0 : existing.getQuantity();
                    int limit = Math.min(99, product.getStock());
                    int reserved = 0;
                    for (CartItem ci : cart.values()) {
                        if (ci.getProduct().getId() == productId) reserved = Math.addExact(reserved, ci.getQuantity());
                    }
                    if (quantity > limit - reserved) throw new IllegalArgumentException("Số lượng vượt tồn kho.");
                    if (existing == null) cart.put(key, incoming);
                    else existing.setQuantity(current + quantity);
                    session.removeAttribute("flashSuccess");
                    break;
                }
                case "addBundle": {
                    String[] ids = req.getParameterValues("productId");
                    if (ids == null || ids.length == 0) throw new IllegalArgumentException("Combo không có sản phẩm.");
                    // Kiểm tra toàn bộ trước, hợp lệ hết mới thêm vào giỏ (tránh thêm dở dang).
                    List<CartItem> toAdd = new ArrayList<>();
                    Map<Integer, Integer> requestedByProduct = new LinkedHashMap<>();
                    for (String idText : ids) {
                        int pid = positiveInt(idText, "Sản phẩm");
                        Product product = productDAO.getProductById(pid);
                        if (product == null) throw new IllegalArgumentException("Sản phẩm trong combo không tồn tại.");
                        if (product.getStock() < 1)
                            throw new IllegalArgumentException("\"" + product.getName() + "\" đã hết hàng.");
                        CartItem incoming = createItem(product, 1, "", "", 0);
                        int reserved = requestedByProduct.getOrDefault(pid, 0);
                        for (CartItem ci : cart.values()) {
                            if (ci.getProduct().getId() == pid) reserved = Math.addExact(reserved, ci.getQuantity());
                        }
                        if (reserved + 1 > Math.min(99, product.getStock()))
                            throw new IllegalArgumentException("\"" + product.getName() + "\" vượt tồn kho.");
                        requestedByProduct.merge(pid, 1, Integer::sum);
                        toAdd.add(incoming);
                    }
                    for (CartItem incoming : toAdd) {
                        CartItem existing = cart.get(incoming.getKey());
                        if (existing == null) cart.put(incoming.getKey(), incoming);
                        else existing.setQuantity(existing.getQuantity() + 1);
                    }
                    session.removeAttribute("flashSuccess");
                    break;
                }
                case "update": {
                    String key = text(req.getParameter("key"));
                    CartItem item = cart.get(key);
                    if (item == null) throw new IllegalArgumentException("Sản phẩm không còn trong giỏ hàng.");
                    int quantity = positiveInt(req.getParameter("quantity"), "Số lượng");
                    int reservedOthers = 0;
                    for (CartItem ci : cart.values()) {
                        if (ci != item && ci.getProduct().getId() == item.getProduct().getId())
                            reservedOthers = Math.addExact(reservedOthers, ci.getQuantity());
                    }
                    Product fresh = productDAO.getProductById(item.getProduct().getId());
                    if (fresh == null || quantity > Math.min(99, fresh.getStock()) - reservedOthers)
                        throw new IllegalArgumentException("Số lượng vượt tồn kho.");
                    item.setQuantity(quantity);
                    break;
                }
                case "remove": {
                    String key = text(req.getParameter("key"));
                    if (cart.remove(key) == null) throw new IllegalArgumentException("Không tìm thấy sản phẩm cần xóa.");
                    break;
                }
                default: throw new IllegalArgumentException("Thao tác không hợp lệ: " + action);
            }
            if (user != null) cartDAO.syncCart(user.getId(), cart);
            // Mã vẫn lưu trong session nhưng sẽ được kiểm tra lại theo giá trị giỏ hàng.
            if (ajax) json(resp, true, "Cập nhật giỏ hàng thành công.", 0, subtotal(cart.values()), null);
            else if (buyNow && "add".equals(action)) {
                resp.sendRedirect(req.getContextPath() + "/checkout?buyNow=1");
            } else resp.sendRedirect(req.getContextPath() + "/cart");
        } catch (Exception e) {
            log("Lỗi thao tác giỏ hàng", e);
            if (ajax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                json(resp, false, e.getMessage(), 0, subtotal(cart.values()), null);
            } else {
                session.setAttribute("flashError", e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/cart");
            }
        }
    }
}