package controller;

import com.google.gson.Gson;
import dao.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/apply-coupon")
public class CouponServlet extends HttpServlet {

    private final CouponDAO couponDAO = new CouponDAO();
    private final Gson gson = new Gson();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String code = req.getParameter("code");
        String remove = req.getParameter("remove");
        HttpSession session = req.getSession();

        Map<String, Object> jsonResponse = new HashMap<>();

        // Nếu người dùng chọn gỡ mã khuyến mãi
        if ("true".equalsIgnoreCase(remove)) {
            session.removeAttribute("appliedCouponCode");
            session.removeAttribute("appliedDiscountAmount");
            jsonResponse.put("success", true);
            jsonResponse.put("message", "Đã hủy áp dụng mã khuyến mãi.");
            jsonResponse.put("discountAmount", 0);
            jsonResponse.put("formattedDiscount", "0₫");

            BigDecimal subtotal = calculateCartSubtotal(session);
            jsonResponse.put("finalTotal", subtotal);
            jsonResponse.put("formattedFinalTotal", model.Coupon.formatVND(subtotal));
            resp.getWriter().write(gson.toJson(jsonResponse));
            return;
        }

        BigDecimal subtotal = calculateCartSubtotal(session);
        String subtotalParam = req.getParameter("subtotal");
        if (subtotalParam != null && !subtotalParam.isBlank()) {
            try {
                subtotal = new BigDecimal(subtotalParam.trim());
            } catch (Exception ignored) {}
        }

        CouponDAO.DiscountResult result = couponDAO.calculateDiscount(code, subtotal);
        if (result.isValid()) {
            session.setAttribute("appliedCouponCode", result.getCoupon().getCode());
            session.setAttribute("appliedDiscountAmount", result.getDiscountAmount());

            jsonResponse.put("success", true);
            jsonResponse.put("code", result.getCoupon().getCode());
            jsonResponse.put("message", result.getMessage());
            jsonResponse.put("discountAmount", result.getDiscountAmount());
            jsonResponse.put("formattedDiscount", model.Coupon.formatVND(result.getDiscountAmount()));
            jsonResponse.put("finalTotal", result.getFinalTotal());
            jsonResponse.put("formattedFinalTotal", model.Coupon.formatVND(result.getFinalTotal()));
        } else {
            session.removeAttribute("appliedCouponCode");
            session.removeAttribute("appliedDiscountAmount");

            jsonResponse.put("success", false);
            jsonResponse.put("message", result.getMessage());
            jsonResponse.put("discountAmount", 0);
            jsonResponse.put("formattedDiscount", "0₫");
            jsonResponse.put("finalTotal", subtotal);
            jsonResponse.put("formattedFinalTotal", model.Coupon.formatVND(subtotal));
        }

        resp.getWriter().write(gson.toJson(jsonResponse));
    }

    @SuppressWarnings("unchecked")
    private BigDecimal calculateCartSubtotal(HttpSession session) {
        Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) return BigDecimal.ZERO;
        java.util.List<String> selected = (java.util.List<String>) session.getAttribute("checkoutSelectedKeys");
        java.util.Collection<CartItem> items = cart.values();
        if (selected != null) {
            java.util.List<CartItem> filtered = new java.util.ArrayList<>();
            for (String key : selected) if (cart.containsKey(key)) filtered.add(cart.get(key));
            items = filtered;
        }
        return items.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}