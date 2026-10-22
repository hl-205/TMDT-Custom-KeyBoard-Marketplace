package dao;

import context.DBContext;
import model.CartItem;
import model.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

public class CartDAO extends DBContext {

    public Map<String, CartItem> getCartByUserId(int userId) {
        Map<String, CartItem> cart = new LinkedHashMap<>();
        String sql = "SELECT c.quantity, c.variant_label, c.extra_price, p.* FROM cart_items c " +
                "JOIN products p ON c.product_id = p.id " +
                "WHERE c.user_id = ? ORDER BY c.id ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setId(rs.getInt("id"));
                    product.setShopId(rs.getInt("shop_id"));
                    product.setCategoryId(rs.getInt("category_id"));
                    product.setSku(rs.getString("sku"));
                    product.setName(rs.getString("name"));
                    product.setBrand(rs.getString("brand"));
                    product.setShortDesc(rs.getString("short_desc"));
                    product.setDescription(rs.getString("description"));

                    // Dùng rs.getLong() để sửa lỗi "possible lossy conversion from double to long"
                    product.setPrice(rs.getLong("price"));
                    product.setOldPrice(rs.getLong("old_price"));

                    product.setDiscountPercent(rs.getInt("discount_percent"));
                    product.setStock(rs.getInt("stock"));
                    product.setSoldCount(rs.getInt("sold_count"));
                    product.setImageUrl(rs.getString("image_url"));

                    int quantity = rs.getInt("quantity");
                    CartItem item = new CartItem(product, quantity, rs.getLong("extra_price"), rs.getString("variant_label"));
                    cart.put(item.getKey(), item);
                }
            }
        } catch (Exception e) {
            throw new IllegalStateException("Không tải được giỏ hàng từ database. Kiểm tra migration cart_items.", e);
        }
        return cart;
    }

    /** Đồng bộ từng biến thể; rollback toàn bộ nếu một lệnh SQL thất bại. */
    public void syncCart(int userId, Map<String, CartItem> cart) {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement del = conn.prepareStatement("DELETE FROM cart_items WHERE user_id = ?")) {
                    del.setInt(1, userId);
                    del.executeUpdate();
                }
                try (PreparedStatement ins = conn.prepareStatement(
                        "INSERT INTO cart_items (user_id, product_id, quantity, variant_label, extra_price) " +
                                "VALUES (?, ?, ?, ?, ?)")) {
                    if (cart != null) {
                        for (CartItem item : cart.values()) {
                            if (item == null || item.getProduct() == null) continue;
                            ins.setInt(1, userId);
                            ins.setInt(2, item.getProduct().getId());
                            ins.setInt(3, Math.max(1, Math.min(item.getQuantity(), 99)));
                            ins.setString(4, item.getVariantLabel());
                            ins.setLong(5, item.getExtraPrice());
                            ins.addBatch();
                        }
                    }
                    ins.executeBatch();
                }
                conn.commit();
            } catch (Exception ex) {
                try { conn.rollback(); } catch (SQLException rollbackEx) { ex.addSuppressed(rollbackEx); }
                throw new IllegalStateException("Không đồng bộ được giỏ hàng. Kiểm tra migration cart_items.", ex);
            } finally {
                try { conn.setAutoCommit(true); } catch (SQLException ignored) { }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không kết nối được database để đồng bộ giỏ hàng.", e);
        }
    }

    public void clearCart(int userId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Ma giam gia: doc tu bang coupons trong keebhub_db.
    private Map<String,Object> couponRow(ResultSet r) throws SQLException {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("id", r.getInt("id"));
        m.put("code", r.getString("code"));
        m.put("description", r.getString("description"));
        m.put("discountType", r.getString("discount_type"));
        m.put("discountValue", r.getBigDecimal("discount_value"));
        m.put("maxDiscountAmount", r.getBigDecimal("max_discount"));
        m.put("minOrderAmount", r.getBigDecimal("min_order_amount"));
        m.put("startAt", r.getDate("start_date"));
        m.put("endAt", r.getDate("end_date"));
        int limit = r.getInt("usage_limit");
        m.put("usageLimit", r.wasNull() ? null : limit);
        m.put("usedCount", r.getInt("used_count"));
        m.put("status", r.getInt("is_active") == 1 ? "ACTIVE" : "INACTIVE");
        return m;
    }

    private static final String COUPON_COLUMNS =
            "id, code, description, discount_type, discount_value, max_discount, " +
                    "min_order_amount, start_date, end_date, usage_limit, used_count, is_active";

    public Map<String,Object> findCoupon(String code) throws SQLException {
        if (code == null || code.trim().isEmpty()) return null;
        String sql = "SELECT " + COUPON_COLUMNS + " FROM coupons WHERE UPPER(code)=UPPER(?) LIMIT 1";
        try (Connection c = getConnection(); PreparedStatement p = c.prepareStatement(sql)) {
            p.setString(1, code.trim());
            try (ResultSet r = p.executeQuery()) {
                return r.next() ? couponRow(r) : null;
            }
        }
    }

    public String couponInvalidReason(Map<String,Object> coupon, long subtotal) {
        if (coupon == null) return "Mã giảm giá không tồn tại.";
        if (subtotal <= 0) return "Vui lòng chọn sản phẩm để áp dụng mã.";
        if (!"ACTIVE".equalsIgnoreCase(String.valueOf(coupon.get("status"))))
            return "Mã giảm giá đang tạm ngừng.";
        java.time.LocalDate today = java.time.LocalDate.now();
        java.sql.Date start = (java.sql.Date) coupon.get("startAt");
        java.sql.Date end = (java.sql.Date) coupon.get("endAt");
        if (start != null && start.toLocalDate().isAfter(today)) return "Mã chưa đến ngày bắt đầu.";
        if (end != null && end.toLocalDate().isBefore(today)) return "Mã đã hết hạn.";
        Integer limit = (Integer) coupon.get("usageLimit");
        Object used = coupon.get("usedCount");
        if (limit != null && limit > 0 && used instanceof Number && ((Number) used).intValue() >= limit)
            return "Mã đã hết lượt sử dụng.";
        BigDecimal minimum = (BigDecimal) coupon.get("minOrderAmount");
        if (minimum != null && BigDecimal.valueOf(subtotal).compareTo(minimum) < 0)
            return "Đơn hàng chưa đạt mức tối thiểu " +
                    String.format(java.util.Locale.forLanguageTag("vi-VN"), "%,d₫", minimum.longValue()) + ".";
        return "";
    }

    public boolean isCouponValid(Map<String,Object> coupon, long subtotal) {
        return couponInvalidReason(coupon, subtotal).isEmpty();
    }

    public List<Map<String,Object>> getAvailableCoupons(long subtotal) throws SQLException {
        List<Map<String,Object>> result = new ArrayList<>();
        // Hien thi ca ma chua du dieu kien; JSP se khoa nut Ap dung.
        String sql = "SELECT " + COUPON_COLUMNS + " FROM coupons " +
                "WHERE is_active = 1 ORDER BY min_order_amount, id";
        try (Connection c = getConnection(); PreparedStatement p = c.prepareStatement(sql);
             ResultSet r = p.executeQuery()) {
            while (r.next()) {
                Map<String,Object> coupon = couponRow(r);
                String reason = couponInvalidReason(coupon, subtotal);
                coupon.put("usable", reason.isEmpty());
                coupon.put("unavailableReason", reason);
                BigDecimal minimum = (BigDecimal) coupon.get("minOrderAmount");
                coupon.put("condition", "Đơn tối thiểu " +
                        String.format(java.util.Locale.forLanguageTag("vi-VN"), "%,d₫",
                                minimum == null ? 0L : minimum.longValue()));
                result.add(coupon);
            }
        }
        return result;
    }

    public long calculateDiscount(Map<String,Object> coupon, long subtotal) {
        if (!isCouponValid(coupon, subtotal)) return 0;
        String type = String.valueOf(coupon.get("discountType"));
        BigDecimal value = (BigDecimal) coupon.get("discountValue");
        if (value == null || value.signum() < 0) return 0;
        BigDecimal discount;
        if ("FIXED".equalsIgnoreCase(type)) discount = value;
        else if ("PERCENT".equalsIgnoreCase(type)) {
            if (value.compareTo(BigDecimal.valueOf(100)) > 0) return 0;
            discount = BigDecimal.valueOf(subtotal).multiply(value)
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        } else if ("FREESHIP".equalsIgnoreCase(type)) {
            discount = BigDecimal.ZERO;
        } else return 0;
        BigDecimal max = (BigDecimal) coupon.get("maxDiscountAmount");
        if (max != null && max.signum() > 0) discount = discount.min(max);
        return discount.max(BigDecimal.ZERO).min(BigDecimal.valueOf(subtotal)).longValue();
    }
}