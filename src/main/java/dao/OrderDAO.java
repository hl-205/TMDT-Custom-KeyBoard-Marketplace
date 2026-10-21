package dao;

import model.CartItem;
import model.Order;
import model.OrderItem;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class OrderDAO {

    public int createOrder(int userId, String receiverName, String phone, String address, List<CartItem> cart) throws SQLException {
        return createOrders(userId, receiverName, phone, address, cart).get(0);
    }

    public List<Integer> createOrders(int userId, String receiverName, String phone, String address, List<CartItem> cart) throws SQLException {
        return createOrders(userId, receiverName, phone, address, cart, null);
    }

    public List<Integer> createOrders(int userId, String receiverName, String phone, String address,
                                      List<CartItem> cart, String couponCode) throws SQLException {
        return createOrders(userId, receiverName, phone, address, cart, couponCode, 0, "CHUA_THANH_TOAN");
    }

    public List<Integer> createOrders(int userId, String receiverName, String phone, String address,
                                      List<CartItem> cart, String couponCode, long shippingFee,
                                      String paymentMethod) throws SQLException {
        if (shippingFee < 0 || !Set.of("COD", "VNPAY_QR", "ATM", "BANK_TRANSFER").contains(paymentMethod))
            throw new SQLException("Phương thức thanh toán hoặc phí vận chuyển không hợp lệ.");
        if (cart == null || cart.isEmpty()) {
            throw new SQLException("Giỏ hàng đang trống.");
        }

        Map<Integer, List<CartItem>> byShop = new LinkedHashMap<>();
        for (CartItem item : cart) {
            byShop.computeIfAbsent(item.getProduct().getShopId(), k -> new ArrayList<>()).add(item);
        }

        String sql = "INSERT INTO orders(order_code, user_id, shop_id, receiver_name, receiver_phone, shipping_address, subtotal, shipping_fee, total_amount, payment_method, order_status) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        String itemSql = "INSERT INTO order_items(order_id, product_id, product_name, quantity, unit_price, line_total) VALUES(?, ?, ?, ?, ?, ?)";
        String stockSql = "UPDATE products SET stock = stock - ?, sold_count = sold_count + ? WHERE id = ? AND stock >= ?";

        try (Connection c = DBContext.getConnection()) {
            if (c == null) {
                throw new SQLException("Không kết nối được cơ sở dữ liệu.");
            }
            c.setAutoCommit(false);

            try {
                List<Integer> orderIds = new ArrayList<>();
                long base = System.currentTimeMillis();
                int idx = 0;
                long wholeSubtotal = 0;
                for (CartItem item : cart) {
                    wholeSubtotal = Math.addExact(wholeSubtotal, item.getLineTotal().longValueExact());
                }
                long wholeDiscount = 0;
                if (couponCode != null && !couponCode.isBlank()) {
                    // Khóa bản ghi trong transaction để tránh vượt số lượt sử dụng.
                    String lockSql = "SELECT id, code, description, discount_type, discount_value, max_discount_amount, "
                            + "min_order_amount, start_at, end_at, usage_limit, used_count, status "
                            + "FROM discount_coupons WHERE UPPER(code)=UPPER(?) FOR UPDATE";
                    try (PreparedStatement lock = c.prepareStatement(lockSql)) {
                        lock.setString(1, couponCode.trim());
                        try (ResultSet rs = lock.executeQuery()) {
                            if (!rs.next()) throw new SQLException("Mã giảm giá không tồn tại.");
                            java.util.Map<String,Object> coupon = new java.util.LinkedHashMap<>();
                            coupon.put("id", rs.getInt("id"));
                            coupon.put("status", rs.getString("status"));
                            coupon.put("startAt", rs.getTimestamp("start_at"));
                            coupon.put("endAt", rs.getTimestamp("end_at"));
                            coupon.put("minOrderAmount", rs.getBigDecimal("min_order_amount"));
                            coupon.put("discountType", rs.getString("discount_type"));
                            coupon.put("discountValue", rs.getBigDecimal("discount_value"));
                            coupon.put("maxDiscountAmount", rs.getBigDecimal("max_discount_amount"));
                            int limit = rs.getInt("usage_limit");
                            coupon.put("usageLimit", rs.wasNull() ? null : limit);
                            coupon.put("usedCount", rs.getInt("used_count"));
                            CartDAO coupons = new CartDAO();
                            if (!coupons.isCouponValid(coupon, wholeSubtotal))
                                throw new SQLException("Mã giảm giá đã hết hạn, hết lượt hoặc đơn chưa đủ điều kiện.");
                            wholeDiscount = coupons.calculateDiscount(coupon, wholeSubtotal);
                            try (PreparedStatement use = c.prepareStatement(
                                    "UPDATE discount_coupons SET used_count=used_count+1 WHERE id=?")) {
                                use.setInt(1, rs.getInt("id"));
                                if (use.executeUpdate() != 1) throw new SQLException("Không cập nhật được lượt dùng mã.");
                            }
                        }
                    }
                }
                long remainingDiscount = wholeDiscount;
                long remainingSubtotal = wholeSubtotal;

                for (Map.Entry<Integer, List<CartItem>> e : byShop.entrySet()) {
                    int shopId = e.getKey();
                    List<CartItem> shopItems = e.getValue();

                    // Mỗi shop một mã đơn riêng (nhân 10 + chỉ số để không trùng trong cùng mili giây)
                    String code = "KH" + (base * 10 + idx);
                    idx++;

                    BigDecimal subtotal = shopItems.stream()
                            .map(CartItem::getLineTotal)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);
                    BigDecimal shipping = BigDecimal.valueOf(idx == 1 ? shippingFee : 0);
                    long shopSubtotal = subtotal.longValueExact();
                    long shopDiscount = remainingSubtotal == shopSubtotal
                            ? remainingDiscount
                            : BigDecimal.valueOf(remainingDiscount)
                            .multiply(BigDecimal.valueOf(shopSubtotal))
                            .divide(BigDecimal.valueOf(remainingSubtotal), 0, java.math.RoundingMode.DOWN)
                            .longValueExact();
                    remainingDiscount -= shopDiscount;
                    remainingSubtotal -= shopSubtotal;

                    int orderId;
                    try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setString(1, code);
                        ps.setInt(2, userId);
                        ps.setInt(3, shopId);
                        ps.setString(4, receiverName);
                        ps.setString(5, phone);
                        ps.setString(6, address);
                        ps.setBigDecimal(7, subtotal);
                        ps.setBigDecimal(8, shipping);
                        ps.setBigDecimal(9, subtotal.subtract(BigDecimal.valueOf(shopDiscount)).add(shipping));
                        ps.setString(10, paymentMethod);
                        ps.executeUpdate();

                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (!rs.next()) {
                                throw new SQLException("Không tạo được đơn hàng.");
                            }
                            orderId = rs.getInt(1);
                        }
                    }

                    for (CartItem item : shopItems) {
                        try (PreparedStatement ps = c.prepareStatement(stockSql)) {
                            int q = item.getQuantity();
                            ps.setInt(1, q);
                            ps.setInt(2, q);
                            ps.setInt(3, item.getProduct().getId());
                            ps.setInt(4, q);
                            if (ps.executeUpdate() != 1) {
                                throw new SQLException("Sản phẩm hết hàng hoặc không đủ số lượng: " + item.getProduct().getName());
                            }
                        }

                        try (PreparedStatement ps = c.prepareStatement(itemSql)) {
                            ps.setInt(1, orderId);
                            ps.setInt(2, item.getProduct().getId());
                            ps.setString(3, item.getProduct().getName()
                                    + (item.getVariantLabel().isEmpty() ? "" : " (" + item.getVariantLabel() + ")"));
                            ps.setInt(4, item.getQuantity());
                            ps.setBigDecimal(5, BigDecimal.valueOf(item.getUnitPrice()));
                            ps.setBigDecimal(6, item.getLineTotal());
                            ps.executeUpdate();
                        }
                    }
                    orderIds.add(orderId);
                }

                c.commit();
                return orderIds;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public List<Order> findByUser(int userId) throws SQLException {
        List<Order> out = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }
        }
        return out;
    }

    public List<Order> findAll() throws SQLException {
        List<Order> out = new ArrayList<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement("SELECT * FROM orders ORDER BY created_at DESC");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                out.add(map(rs));
            }
        }
        return out;
    }

    public boolean updateStatus(int id, String status) throws SQLException {
        Set<String> allowed = Set.of("PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "COMPLETED", "CANCELLED");
        if (!allowed.contains(status)) return false;

        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement("UPDATE orders SET order_status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() == 1;
        }
    }

    private Order map(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setOrderCode(rs.getString("order_code"));
        o.setUserId(rs.getInt("user_id"));
        o.setShopId(rs.getInt("shop_id"));
        o.setReceiverName(rs.getString("receiver_name"));
        o.setReceiverPhone(rs.getString("receiver_phone"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setSubtotal(rs.getBigDecimal("subtotal"));
        o.setShippingFee(rs.getBigDecimal("shipping_fee"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}