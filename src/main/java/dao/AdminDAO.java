package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminDAO extends DBContext {

    // 1. Lấy danh sách tất cả người dùng
    public List<Map<String, Object>> getUsers() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, first_name, last_name, email, role, status FROM users ORDER BY id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("first_name", rs.getString("first_name"));
                map.put("last_name", rs.getString("last_name"));
                map.put("email", rs.getString("email"));
                map.put("role", rs.getString("role"));
                map.put("status", rs.getString("status"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy danh sách tất cả đơn hàng (kèm email người mua)
    public List<Map<String, Object>> getOrders() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT o.id, o.order_code, o.receiver_name, u.email AS customer_email, " +
                "o.total_amount, o.order_status " +
                "FROM orders o LEFT JOIN users u ON o.user_id = u.id ORDER BY o.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("order_code", rs.getString("order_code"));
                map.put("receiver_name", rs.getString("receiver_name"));
                map.put("customer_email", rs.getString("customer_email"));
                map.put("total_amount", rs.getLong("total_amount"));
                map.put("order_status", rs.getString("order_status"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Lấy danh sách tất cả sản phẩm (kèm tên cửa hàng)
    public List<Map<String, Object>> getProducts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.sku, s.shop_name, p.price, p.stock, p.status " +
                "FROM products p LEFT JOIN shops s ON p.shop_id = s.id ORDER BY p.id DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getInt("id"));
                map.put("name", rs.getString("name"));
                map.put("sku", rs.getString("sku"));
                map.put("shop_name", rs.getString("shop_name"));
                map.put("price", rs.getLong("price"));
                map.put("stock", rs.getInt("stock"));
                map.put("status", rs.getString("status"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Lấy số liệu thống kê tổng quan (Stats) - Tự động nhóm ĐỘNG cho tất cả các Role & Trạng thái đơn
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();

        String sqlUser = "SELECT COUNT(*) FROM users";
        String sqlOrder = "SELECT COUNT(*) FROM orders";
        String sqlProduct = "SELECT COUNT(*) FROM products";
        String sqlTotalValue = "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status != 'CANCELLED'";

        // Gom nhóm động toàn bộ các Role thực tế trong Database (kể cả CUSTOM, MODERATOR,...)
        String sqlRoles = "SELECT COALESCE(role, 'GUEST') AS role_name, COUNT(*) AS count " +
                "FROM users GROUP BY role ORDER BY count DESC";

        // Gom nhóm động toàn bộ các Trạng thái đơn hàng thực tế trong Database
        String sqlStatuses = "SELECT COALESCE(order_status, 'UNKNOWN') AS status_name, COUNT(*) AS count " +
                "FROM orders GROUP BY order_status ORDER BY count DESC";

        try (Connection conn = getConnection()) {
            // Đếm tổng số người dùng
            try (PreparedStatement ps = conn.prepareStatement(sqlUser); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("userCount", rs.getInt(1));
            }

            // Đếm tổng số đơn hàng
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("orderCount", rs.getInt(1));
            }

            // Đếm tổng số sản phẩm
            try (PreparedStatement ps = conn.prepareStatement(sqlProduct); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("productCount", rs.getInt(1));
            }

            // Tính tổng giá trị đơn không hủy
            try (PreparedStatement ps = conn.prepareStatement(sqlTotalValue); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalOrdersValue", rs.getLong(1));
            }

            // 1. Map lưu toàn bộ Role động (Dùng cho biểu đồ tròn & danh sách hiển thị)
            Map<String, Integer> roleStats = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement(sqlRoles); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String role = rs.getString("role_name").toUpperCase();
                    int count = rs.getInt("count");
                    roleStats.put(role, count);
                    // Đưa key lẻ vào stats để tương thích với code cũ (ví dụ: stats.customCount, stats.customerCount)
                    stats.put(role.toLowerCase() + "Count", count);
                }
            }
            stats.put("roleStats", roleStats);

            // 2. Map lưu toàn bộ Trạng thái đơn động
            Map<String, Integer> orderStatusStats = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement(sqlStatuses); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status_name").toUpperCase();
                    int count = rs.getInt("count");
                    orderStatusStats.put(status, count);
                    // Đưa key lẻ vào stats (ví dụ: stats.pendingCount, stats.completedCount)
                    stats.put(status.toLowerCase() + "Count", count);
                }
            }
            stats.put("orderStatusStats", orderStatusStats);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // 5. Cập nhật trạng thái Người dùng
    public void updateUserStatus(int id, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 6. Cập nhật trạng thái Đơn hàng
    public void updateOrderStatus(int id, String status) {
        String sql = "UPDATE orders SET order_status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 7. Cập nhật trạng thái Sản phẩm
    public void updateProductStatus(int id, String status) {
        String sql = "UPDATE products SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 8. Xóa sản phẩm
    public void deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}