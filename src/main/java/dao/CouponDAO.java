package dao;

import model.Coupon;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CouponDAO {

    private static boolean schemaChecked = false;

    public static synchronized void ensureCouponTable() {
        if (schemaChecked) return;
        String createTableSql = "CREATE TABLE IF NOT EXISTS coupons ("
                + "id INT AUTO_INCREMENT PRIMARY KEY, "
                + "code VARCHAR(50) NOT NULL UNIQUE, "
                + "description VARCHAR(255) NOT NULL, "
                + "discount_type VARCHAR(20) DEFAULT 'PERCENT', "
                + "discount_value DECIMAL(12,0) NOT NULL, "
                + "max_discount DECIMAL(12,0) DEFAULT 0, "
                + "min_order_amount DECIMAL(12,0) DEFAULT 0, "
                + "usage_limit INT DEFAULT 100, "
                + "used_count INT DEFAULT 0, "
                + "start_date DATE, "
                + "end_date DATE, "
                + "is_active TINYINT(1) DEFAULT 1, "
                + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
                + ") ENGINE=InnoDB;";

        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            st.executeUpdate(createTableSql);

            // Kiểm tra và khởi tạo dữ liệu mẫu nếu bảng rỗng
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM coupons")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    st.executeUpdate("INSERT INTO coupons (code, description, discount_type, discount_value, max_discount, min_order_amount, usage_limit, is_active) VALUES "
                            + "('KEEB10', 'Giảm 10% (tối đa 150.000₫) cho đơn hàng từ 200.000₫', 'PERCENT', 10, 150000, 200000, 200, 1),"
                            + "('KEEBHUB50', 'Giảm trực tiếp 50.000₫ cho đơn hàng từ 300.000₫', 'FIXED', 50000, 0, 300000, 150, 1),"
                            + "('VIPKEYBOARD', 'Ưu đãi cao cấp giảm 15% (tối đa 300.000₫) cho đơn từ 1.000.000₫', 'PERCENT', 15, 300000, 1000000, 100, 1),"
                            + "('FREESHIP30', 'Hỗ trợ 30.000₫ phí vận chuyển cho đơn từ 100.000₫', 'FIXED', 30000, 0, 100000, 300, 1);");
                }
            }
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Coupon> getAvailableCoupons() {
        ensureCouponTable();
        List<Coupon> list = new ArrayList<>();
        String sql = "SELECT * FROM coupons WHERE is_active = 1 AND (usage_limit = 0 OR used_count < usage_limit) ORDER BY min_order_amount ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapCoupon(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Coupon findByCode(String code) {
        if (code == null || code.trim().isEmpty()) return null;
        ensureCouponTable();
        String sql = "SELECT * FROM coupons WHERE UPPER(code) = UPPER(?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static class DiscountResult {
        private boolean valid;
        private String message;
        private Coupon coupon;
        private BigDecimal discountAmount = BigDecimal.ZERO;
        private BigDecimal finalTotal = BigDecimal.ZERO;

        public boolean isValid() { return valid; }
        public void setValid(boolean valid) { this.valid = valid; }

        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }

        public Coupon getCoupon() { return coupon; }
        public void setCoupon(Coupon coupon) { this.coupon = coupon; }

        public BigDecimal getDiscountAmount() { return discountAmount; }
        public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

        public BigDecimal getFinalTotal() { return finalTotal; }
        public void setFinalTotal(BigDecimal finalTotal) { this.finalTotal = finalTotal; }
    }

    public DiscountResult calculateDiscount(String code, BigDecimal subtotal) {
        DiscountResult result = new DiscountResult();
        if (subtotal == null) subtotal = BigDecimal.ZERO;

        if (code == null || code.trim().isEmpty()) {
            result.setValid(false);
            result.setMessage("Vui lòng nhập mã khuyến mãi.");
            result.setFinalTotal(subtotal);
            return result;
        }

        Coupon coupon = findByCode(code.trim());
        if (coupon == null) {
            result.setValid(false);
            result.setMessage("Mã khuyến mãi '" + code.trim() + "' không tồn tại trong hệ thống.");
            result.setFinalTotal(subtotal);
            return result;
        }

        if (!coupon.isActive()) {
            result.setValid(false);
            result.setMessage("Mã khuyến mãi này hiện đang tạm khóa hoặc đã ngưng áp dụng.");
            result.setFinalTotal(subtotal);
            return result;
        }

        if (coupon.getUsageLimit() > 0 && coupon.getUsedCount() >= coupon.getUsageLimit()) {
            result.setValid(false);
            result.setMessage("Mã khuyến mãi này đã hết lượt sử dụng.");
            result.setFinalTotal(subtotal);
            return result;
        }

        if (coupon.getMinOrderAmount() != null && subtotal.compareTo(coupon.getMinOrderAmount()) < 0) {
            result.setValid(false);
            result.setMessage("Đơn hàng chưa đạt giá trị tối thiểu " + Coupon.formatVND(coupon.getMinOrderAmount()) + " để áp dụng mã này.");
            result.setFinalTotal(subtotal);
            return result;
        }

        BigDecimal discount = BigDecimal.ZERO;
        if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
            BigDecimal percent = coupon.getDiscountValue().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
            discount = subtotal.multiply(percent).setScale(0, RoundingMode.HALF_UP);
            if (coupon.getMaxDiscount() != null && coupon.getMaxDiscount().compareTo(BigDecimal.ZERO) > 0) {
                if (discount.compareTo(coupon.getMaxDiscount()) > 0) {
                    discount = coupon.getMaxDiscount();
                }
            }
        } else {
            discount = coupon.getDiscountValue();
        }

        if (discount.compareTo(subtotal) > 0) {
            discount = subtotal;
        }

        BigDecimal finalTotal = subtotal.subtract(discount);
        if (finalTotal.compareTo(BigDecimal.ZERO) < 0) {
            finalTotal = BigDecimal.ZERO;
        }

        result.setValid(true);
        result.setCoupon(coupon);
        result.setDiscountAmount(discount);
        result.setFinalTotal(finalTotal);
        result.setMessage("Áp dụng mã thành công! Bạn được giảm " + Coupon.formatVND(discount) + ".");
        return result;
    }

    public boolean recordUsage(String code) {
        if (code == null || code.trim().isEmpty()) return false;
        ensureCouponTable();
        String sql = "UPDATE coupons SET used_count = used_count + 1 WHERE UPPER(code) = UPPER(?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Coupon mapCoupon(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();
        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setDescription(rs.getString("description"));
        c.setDiscountType(rs.getString("discount_type"));
        c.setDiscountValue(rs.getBigDecimal("discount_value"));
        c.setMaxDiscount(rs.getBigDecimal("max_discount"));
        c.setMinOrderAmount(rs.getBigDecimal("min_order_amount"));
        c.setUsageLimit(rs.getInt("usage_limit"));
        c.setUsedCount(rs.getInt("used_count"));
        c.setStartDate(rs.getDate("start_date"));
        c.setEndDate(rs.getDate("end_date"));
        c.setActive(rs.getInt("is_active") == 1);
        return c;
    }
}
