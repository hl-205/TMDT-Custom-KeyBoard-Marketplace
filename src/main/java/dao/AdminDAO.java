package dao;

import java.sql.*;
import java.util.*;

/** DAO cho màn hình quản trị cơ bản: người dùng, đơn hàng, sản phẩm. */
public class AdminDAO {

    private List<Map<String, Object>> query(String sql) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            ResultSetMetaData md = rs.getMetaData();
            int n = md.getColumnCount();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= n; i++) {
                    row.put(md.getColumnLabel(i), rs.getObject(i));
                }
                rows.add(row);
            }
        }
        return rows;
    }

    private boolean update(String sql, Object... args) throws SQLException {
        try (Connection c = DBContext.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            return ps.executeUpdate() > 0;
        }
    }

    public List<Map<String, Object>> getUsers() throws SQLException {
        return query("SELECT id, first_name, last_name, email, phone, role, status, created_at FROM users ORDER BY created_at DESC");
    }

    public List<Map<String, Object>> getOrders() throws SQLException {
        return query("SELECT o.id, o.order_code, o.receiver_name, o.receiver_phone, o.total_amount, o.order_status, o.created_at, u.email AS customer_email FROM orders o JOIN users u ON u.id = o.user_id ORDER BY o.created_at DESC");
    }

    public List<Map<String, Object>> getProducts() throws SQLException {
        return query("SELECT p.id, p.name, p.sku, p.price, p.stock, p.status, s.shop_name FROM products p JOIN shops s ON s.id = p.shop_id ORDER BY p.created_at DESC");
    }

    public boolean updateUserStatus(int id, String status) throws SQLException {
        if (!Set.of("ACTIVE", "INACTIVE", "BLOCKED").contains(status)) return false;
        return update("UPDATE users SET status = ? WHERE id = ?", status, id);
    }

    public boolean updateOrderStatus(int id, String status) throws SQLException {
        if (!Set.of("PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "COMPLETED", "CANCELLED").contains(status)) return false;
        return update("UPDATE orders SET order_status = ? WHERE id = ?", status, id);
    }

    public boolean updateProductStatus(int id, String status) throws SQLException {
        if (!Set.of("ACTIVE", "INACTIVE").contains(status)) return false;
        return update("UPDATE products SET status = ? WHERE id = ?", status, id);
    }

    public boolean deleteProduct(int id) throws SQLException {
        return update("DELETE FROM products WHERE id = ?", id);
    }

    public Map<String, Object> getStats() throws SQLException {
        List<Map<String, Object>> r = query("SELECT (SELECT COUNT(*) FROM users) AS userCount, (SELECT COUNT(*) FROM orders) AS orderCount, (SELECT COUNT(*) FROM products) AS productCount, (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status <> 'CANCELLED') AS totalOrdersValue");
        return r.isEmpty() ? new HashMap<>() : r.get(0);
    }
}