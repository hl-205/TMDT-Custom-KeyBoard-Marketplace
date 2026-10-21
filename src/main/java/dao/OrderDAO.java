package dao;

import model.CartItem;
import model.Order;
import model.OrderItem;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class OrderDAO {

    public int createOrder(int userId, String receiverName, String phone, String address, List<CartItem> cart) throws SQLException {
        return createOrder(userId, receiverName, phone, address, cart, BigDecimal.ZERO, "COD", null);
    }

    public int createOrder(int userId, String receiverName, String phone, String address, List<CartItem> cart,
                           BigDecimal discountAmount, String paymentMethod, String couponCode) throws SQLException {
        if (cart == null || cart.isEmpty()) {
            throw new SQLException("Giỏ hàng đang trống.");
        }

        if (discountAmount == null || discountAmount.compareTo(BigDecimal.ZERO) < 0) {
            discountAmount = BigDecimal.ZERO;
        }

        if (paymentMethod == null || paymentMethod.isBlank()) {
            paymentMethod = "COD";
        }

        // Schema hiện tại có shop_id bắt buộc: mỗi lần đặt hàng phải thuộc một shop.
        int shopId = cart.get(0).getProduct().getShopId();
        for (CartItem item : cart) {
            if (item.getProduct().getShopId() != shopId) {
                throw new SQLException("Vui lòng đặt từng đơn theo từng cửa hàng.");
            }
        }

        String code = "KH" + System.currentTimeMillis();
        BigDecimal subtotal = cart.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal shipping = BigDecimal.ZERO;

        BigDecimal total = subtotal.add(shipping).subtract(discountAmount);
        if (total.compareTo(BigDecimal.ZERO) < 0) {
            total = BigDecimal.ZERO;
        }

        String initialStatus = "PENDING";
        int firstProductId = cart.get(0).getProduct().getId();
        String variantSummary = cart.get(0).getProduct().getName() + " · ×" + cart.get(0).getQuantity();
        if (cart.size() > 1) {
            variantSummary += " (+" + (cart.size() - 1) + " sản phẩm khác)";
        }

        String sql = "INSERT INTO orders(order_code, user_id, shop_id, product_id, variant_summary, receiver_name, receiver_phone, shipping_address, "
                + "is_custom_order, subtotal, shipping_fee, discount_amount, total_amount, payment_method, order_status, progress_percent) "
                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, 0)";

        try (Connection c = DBContext.getConnection()) {
            if (c == null) {
                throw new SQLException("Không kết nối được cơ sở dữ liệu.");
            }
            c.setAutoCommit(false);

            try {
                int orderId;
                try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, code);
                    ps.setInt(2, userId);
                    ps.setInt(3, shopId);
                    ps.setInt(4, firstProductId);
                    ps.setString(5, variantSummary);
                    ps.setString(6, receiverName);
                    ps.setString(7, phone);
                    ps.setString(8, address);
                    ps.setBigDecimal(9, subtotal);
                    ps.setBigDecimal(10, shipping);
                    ps.setBigDecimal(11, discountAmount);
                    ps.setBigDecimal(12, total);
                    ps.setString(13, paymentMethod);
                    ps.setString(14, initialStatus);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) {
                            throw new SQLException("Không tạo được đơn hàng.");
                        }
                        orderId = rs.getInt(1);
                    }
                }

                String itemSql = "INSERT INTO order_items(order_id, product_id, product_name, quantity, unit_price, line_total) VALUES(?, ?, ?, ?, ?, ?)";
                String stockSql = "UPDATE products SET stock = stock - ?, sold_count = sold_count + ? WHERE id = ? AND stock >= ?";

                for (CartItem item : cart) {
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
                        ps.setString(3, item.getProduct().getName());
                        ps.setInt(4, item.getQuantity());
                        ps.setBigDecimal(5, BigDecimal.valueOf(item.getProduct().getPrice()));
                        ps.setBigDecimal(6, item.getLineTotal());
                        ps.executeUpdate();
                    }
                }

                // Ghi nhận coupon đã sử dụng nếu có
                if (couponCode != null && !couponCode.isBlank()) {
                    new CouponDAO().recordUsage(couponCode);
                }

                c.commit();
                return orderId;
            } catch (SQLException ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public Order getOrderById(int id) throws SQLException {
        String sql = "SELECT * FROM orders WHERE id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = map(rs);
                    o.setItems(findItemsByOrderId(o.getId()));
                    return o;
                }
            }
        }
        return null;
    }

    public Order getOrderByCode(String code) throws SQLException {
        String sql = "SELECT * FROM orders WHERE order_code = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = map(rs);
                    o.setItems(findItemsByOrderId(o.getId()));
                    return o;
                }
            }
        }
        return null;
    }

    public boolean updatePaymentSuccess(int orderId, String paymentMethod) throws SQLException {
        String sql = "UPDATE orders SET payment_method = ?, order_status = 'CONFIRMED', progress_percent = 20 WHERE id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, paymentMethod);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updatePaymentSuccessByCode(String orderCode, String paymentMethod) throws SQLException {
        String sql = "UPDATE orders SET payment_method = ?, order_status = 'CONFIRMED', progress_percent = 20 WHERE order_code = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, paymentMethod);
            ps.setString(2, orderCode);
            return ps.executeUpdate() > 0;
        }
    }

    public List<OrderItem> findItemsByOrderId(int orderId) throws SQLException {
        List<OrderItem> list = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ?";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem it = new OrderItem();
                    it.setId(rs.getInt("id"));
                    it.setOrderId(rs.getInt("order_id"));
                    it.setProductId(rs.getInt("product_id"));
                    it.setProductName(rs.getString("product_name"));
                    it.setQuantity(rs.getInt("quantity"));
                    it.setUnitPrice(rs.getBigDecimal("unit_price"));
                    it.setLineTotal(rs.getBigDecimal("line_total"));
                    list.add(it);
                }
            }
        }
        return list;
    }

    public List<Order> findByUser(int userId) throws SQLException {
        List<Order> out = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = map(rs);
                    o.setItems(findItemsByOrderId(o.getId()));
                    out.add(o);
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
                Order o = map(rs);
                o.setItems(findItemsByOrderId(o.getId()));
                out.add(o);
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
        try {
            o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        } catch (SQLException ignored) {
            o.setDiscountAmount(BigDecimal.ZERO);
        }
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}