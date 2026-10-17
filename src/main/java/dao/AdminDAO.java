package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminDAO extends DBContext {

    // 1. LẤY DANH SÁCH NGƯỜI DÙNG
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

    // 2. LẤY DANH SÁCH ĐƠN HÀNG
    public List<Map<String, Object>> getOrders() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT o.id, o.order_code, o.receiver_name, COALESCE(u.email, '') AS customer_email, " +
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

    // 3. LẤY DANH SÁCH SẢN PHẨM
    public List<Map<String, Object>> getProducts() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.sku, COALESCE(s.shop_name, 'KeebHub Store') AS shop_name, " +
                "p.price, p.stock, p.status " +
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

    // 4. LẤY THỐNG KÊ DASHBOARD
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = getConnection()) {
            // Đếm users
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("userCount", rs.getInt(1));
            }

            // Đếm orders
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM orders");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("orderCount", rs.getInt(1));
            }

            // Đếm products
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM products");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("productCount", rs.getInt(1));
            }

            // Tổng doanh thu đơn không hủy
            try (PreparedStatement ps = conn.prepareStatement("SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status != 'CANCELLED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) stats.put("totalOrdersValue", rs.getLong(1));
            }

            // Thống kê Role
            Map<String, Integer> roleStats = new HashMap<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT role, COUNT(*) FROM users GROUP BY role");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roleStats.put(rs.getString(1), rs.getInt(2));
                }
            }
            stats.put("roleStats", roleStats);

            // Thống kê Trạng thái đơn hàng
            Map<String, Integer> orderStatusStats = new HashMap<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT order_status, COUNT(*) FROM orders GROUP BY order_status");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orderStatusStats.put(rs.getString(1), rs.getInt(2));
                }
            }
            stats.put("orderStatusStats", orderStatusStats);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    // =========================================================================
    // CRUD - các hàm bên dưới KHÔNG nuốt lỗi nữa: có lỗi SQL là ném ra ngoài
    // để AdminServlet trả success=false cho giao diện (trước đây vẫn báo "thành công").
    // =========================================================================

    private int firstKey(PreparedStatement ps) throws SQLException {
        try (ResultSet rs = ps.getGeneratedKeys()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ---------------------------- USER ---------------------------------------
    public int saveUser(int id, String firstName, String lastName, String email,
                        String password, String role, String status) throws SQLException {
        if (id <= 0) {
            String sql = "INSERT INTO users (first_name, last_name, email, password, role, status) VALUES (?, ?, ?, ?, ?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, firstName);
                ps.setString(2, lastName);
                ps.setString(3, email);
                ps.setString(4, (password != null && !password.isEmpty()) ? password : "123456");
                ps.setString(5, role);
                ps.setString(6, status);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }

        boolean updatePassword = (password != null && !password.trim().isEmpty());
        String sql = updatePassword
                ? "UPDATE users SET first_name=?, last_name=?, email=?, password=?, role=?, status=? WHERE id=?"
                : "UPDATE users SET first_name=?, last_name=?, email=?, role=?, status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, firstName);
            ps.setString(i++, lastName);
            ps.setString(i++, email);
            if (updatePassword) ps.setString(i++, password);
            ps.setString(i++, role);
            ps.setString(i++, status);
            ps.setInt(i, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy người dùng #" + id);
            return id;
        }
    }

    public void updateUserStatus(int id, String status) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE users SET status=? WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void deleteUser(int id) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // orders.user_id không có ON DELETE CASCADE -> phải xóa đơn trước
                // (order_items, order_progress tự xóa theo vì có CASCADE)
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE user_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    // ---------------------------- ORDER --------------------------------------
    public int saveOrder(int id, String orderCode, String receiverName, String customerEmail,
                         long totalAmount, String status) throws SQLException {
        if (orderCode == null || orderCode.trim().isEmpty()) {
            orderCode = "KH" + System.currentTimeMillis();
        }

        int userId;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email=?")) {
            ps.setString(1, customerEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Email \"" + customerEmail + "\" chưa có tài khoản người dùng nào.");
                }
                userId = rs.getInt("id");
            }
        }

        if (id <= 0) {
            String sql = "INSERT INTO orders (order_code, user_id, shop_id, receiver_name, receiver_phone, shipping_address, subtotal, total_amount, order_status) "
                    + "VALUES (?, ?, 1, ?, '0987654321', 'Mặc định', ?, ?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, orderCode);
                ps.setInt(2, userId);
                ps.setString(3, receiverName);
                ps.setLong(4, totalAmount);
                ps.setLong(5, totalAmount);
                ps.setString(6, status);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }

        String sql = "UPDATE orders SET order_code=?, receiver_name=?, user_id=?, total_amount=?, subtotal=?, order_status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ps.setString(2, receiverName);
            ps.setInt(3, userId);
            ps.setLong(4, totalAmount);
            ps.setLong(5, totalAmount);
            ps.setString(6, status);
            ps.setInt(7, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy đơn hàng #" + id);
            return id;
        }
    }

    public void updateOrderStatus(int id, String status) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE orders SET order_status=? WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void deleteOrder(int id) throws SQLException {
        // order_items / order_progress có ON DELETE CASCADE nên chỉ cần xóa orders
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ---------------------------- PRODUCT ------------------------------------
    public int saveProduct(int id, String name, String sku, String shopName,
                           long price, int stock, String status) throws SQLException {
        int shopId;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id FROM shops WHERE shop_name = ? ORDER BY id LIMIT 1")) {
            ps.setString(1, shopName);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Không có cửa hàng tên \"" + shopName + "\". Hãy nhập đúng tên cửa hàng (vd: KeebLab Store).");
                }
                shopId = rs.getInt("id");
            }
        }

        if (id <= 0) {
            String sql = "INSERT INTO products (shop_id, category_id, sku, name, price, stock, status) VALUES (?, 1, ?, ?, ?, ?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, shopId);
                ps.setString(2, sku);
                ps.setString(3, name);
                ps.setLong(4, price);
                ps.setInt(5, stock);
                ps.setString(6, status);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }

        String sql = "UPDATE products SET name=?, sku=?, shop_id=?, price=?, stock=?, status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, sku);
            ps.setInt(3, shopId);
            ps.setLong(4, price);
            ps.setInt(5, stock);
            ps.setString(6, status);
            ps.setInt(7, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy sản phẩm #" + id);
            return id;
        }
    }

    public void updateProductStatus(int id, String status) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE products SET status=? WHERE id=?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void deleteProduct(int id) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // order_items.product_id không có CASCADE -> xóa dòng chi tiết đơn liên quan trước
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM order_items WHERE product_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }
}
