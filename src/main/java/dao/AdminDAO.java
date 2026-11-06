package dao;

import context.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AdminDAO extends DBContext {

    public List<Map<String, Object>> getUsers() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        // Số đơn / chi tiêu: khách hàng tính theo đơn đã mua, chủ shop tính theo đơn của cửa hàng.
        String sql = "SELECT u.id, u.first_name, u.last_name, u.email, u.phone, u.role, u.status, u.is_verified, u.created_at, "
                + "CASE WHEN u.role = 'SELLER' THEN COALESCE(t.cnt, 0) ELSE COALESCE(s.cnt, 0) END AS order_count, "
                + "CASE WHEN u.role = 'SELLER' THEN COALESCE(t.amount, 0) ELSE COALESCE(s.amount, 0) END AS total_spent "
                + "FROM users u "
                + "LEFT JOIN (SELECT user_id, COUNT(*) AS cnt, "
                + "  SUM(CASE WHEN order_status <> 'CANCELLED' THEN total_amount ELSE 0 END) AS amount "
                + "  FROM orders GROUP BY user_id) s ON s.user_id = u.id "
                + "LEFT JOIN (SELECT sh.owner_id, COUNT(o.id) AS cnt, "
                + "  SUM(CASE WHEN o.order_status <> 'CANCELLED' THEN o.total_amount ELSE 0 END) AS amount "
                + "  FROM shops sh JOIN orders o ON o.shop_id = sh.id GROUP BY sh.owner_id) t ON t.owner_id = u.id "
                + "ORDER BY u.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("first_name", rs.getString("first_name"));
                row.put("last_name", rs.getString("last_name"));
                row.put("email", rs.getString("email"));
                row.put("phone", rs.getString("phone"));
                row.put("role", rs.getString("role"));
                row.put("status", rs.getString("status"));
                row.put("verified", rs.getInt("is_verified") == 1);
                row.put("created_at", rs.getString("created_at"));
                row.put("order_count", rs.getLong("order_count"));
                row.put("total_spent", rs.getLong("total_spent"));
                list.add(row);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getOrders() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT o.id, o.order_code, o.receiver_name, o.receiver_phone, o.shipping_address, "
                + "COALESCE(u.email, '') AS customer_email, o.total_amount, o.order_status, "
                + "o.product_id, o.created_at, o.payment_method, "
                + "COALESCE(p.name, '') AS product_name "
                + "FROM orders o LEFT JOIN users u ON o.user_id = u.id "
                + "LEFT JOIN products p ON o.product_id = p.id ORDER BY o.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("order_code", rs.getString("order_code"));
                row.put("receiver_name", rs.getString("receiver_name"));
                row.put("receiver_phone", rs.getString("receiver_phone"));
                row.put("shipping_address", rs.getString("shipping_address"));
                row.put("customer_email", rs.getString("customer_email"));
                row.put("total_amount", rs.getLong("total_amount"));
                row.put("order_status", rs.getString("order_status"));
                row.put("payment_method", rs.getString("payment_method"));
                row.put("product_id", rs.getInt("product_id"));
                row.put("product_name", rs.getString("product_name"));
                list.add(row);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getProducts() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.sku, p.shop_id, p.category_id, "
                + "COALESCE(s.shop_name, '') AS shop_name, COALESCE(c.name, '') AS category_name, "
                + "p.price, p.stock, p.status, p.created_at, "
                + "COALESCE(p.brand, '') AS brand, COALESCE(p.switch_type, '') AS switch_type, "
                + "COALESCE(p.layout, '') AS layout, COALESCE(p.mount_type, '') AS mount_type, "
                + "COALESCE(p.pin_type, '') AS pin_type, COALESCE(p.actuation_force, '') AS actuation_force, "
                + "COALESCE(p.image_url, '') AS image_url, "
                + "CHAR_LENGTH(COALESCE(p.description, '')) AS desc_len, LEFT(COALESCE(p.description, ''), 600) AS description, "
                + "(SELECT COUNT(*) FROM product_specs ps WHERE ps.product_id = p.id) AS spec_count, "
                + "(SELECT COUNT(*) FROM product_compatibilities pc WHERE pc.product_id = p.id) AS compat_count "
                + "FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "LEFT JOIN categories c ON p.category_id = c.id ORDER BY p.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("name", rs.getString("name"));
                row.put("sku", rs.getString("sku"));
                row.put("shop_id", rs.getInt("shop_id"));
                row.put("category_id", rs.getInt("category_id"));
                row.put("shop_name", rs.getString("shop_name"));
                row.put("category_name", rs.getString("category_name"));
                row.put("price", rs.getLong("price"));
                row.put("stock", rs.getInt("stock"));
                row.put("status", rs.getString("status"));
                row.put("created_at", rs.getString("created_at"));
                row.put("brand", rs.getString("brand"));
                row.put("switch_type", rs.getString("switch_type"));
                row.put("layout", rs.getString("layout"));
                row.put("mount_type", rs.getString("mount_type"));
                row.put("pin_type", rs.getString("pin_type"));
                row.put("actuation_force", rs.getString("actuation_force"));
                row.put("image_url", rs.getString("image_url"));
                row.put("desc_len", rs.getInt("desc_len"));
                row.put("description", rs.getString("description"));
                row.put("spec_count", rs.getInt("spec_count"));
                row.put("compat_count", rs.getInt("compat_count"));
                list.add(row);
            }
        }
        return list;
    }

    /** Danh sách cửa hàng rút gọn dùng cho ô chọn cửa hàng khi thêm/sửa sản phẩm. */
    public List<Map<String, Object>> getShops() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, shop_name FROM shops ORDER BY shop_name");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("shop_name", rs.getString("shop_name"));
                list.add(row);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getCategories() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id, name, slug, COALESCE(icon, '') AS icon FROM categories ORDER BY id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("name", rs.getString("name"));
                row.put("slug", rs.getString("slug"));
                row.put("icon", rs.getString("icon"));
                list.add(row);
            }
        }
        return list;
    }

    /** Hồ sơ đầy đủ của cửa hàng kèm thông tin chủ shop và số liệu vận hành. */
    public List<Map<String, Object>> getShopsFull() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT s.id, s.shop_name, s.avatar_text, s.avatar_color, COALESCE(s.description, '') AS description, "
                + "COALESCE(s.address, '') AS address, s.is_verified, s.is_workshop, s.rating_avg, s.on_time_rate, s.cancel_rate, "
                + "COALESCE(s.joined_date, '') AS joined_date, s.owner_id, COALESCE(u.email, '') AS owner_email, "
                + "COALESCE(u.phone, '') AS owner_phone, TRIM(CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, ''))) AS owner_name, "
                + "COALESCE(u.status, 'ACTIVE') AS owner_status, "
                + "(SELECT COUNT(*) FROM products p WHERE p.shop_id = s.id) AS products, "
                + "(SELECT COUNT(*) FROM custom_services cs WHERE cs.shop_id = s.id) AS services, "
                + "(SELECT COUNT(*) FROM orders o WHERE o.shop_id = s.id) AS order_count, "
                + "(SELECT COALESCE(SUM(o.total_amount), 0) FROM orders o WHERE o.shop_id = s.id AND o.order_status <> 'CANCELLED' "
                + "   AND YEAR(o.created_at) = YEAR(CURDATE()) AND MONTH(o.created_at) = MONTH(CURDATE())) AS gmv_month "
                + "FROM shops s LEFT JOIN users u ON u.id = s.owner_id ORDER BY s.is_verified ASC, s.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("shop_name", rs.getString("shop_name"));
                row.put("avatar_text", rs.getString("avatar_text"));
                row.put("avatar_color", rs.getString("avatar_color"));
                row.put("description", rs.getString("description"));
                row.put("address", rs.getString("address"));
                row.put("verified", rs.getInt("is_verified") == 1);
                row.put("workshop", rs.getInt("is_workshop") == 1);
                row.put("rating_avg", rs.getDouble("rating_avg"));
                row.put("on_time_rate", rs.getDouble("on_time_rate"));
                row.put("cancel_rate", rs.getDouble("cancel_rate"));
                row.put("joined_date", rs.getString("joined_date"));
                row.put("owner_id", rs.getInt("owner_id"));
                row.put("owner_name", rs.getString("owner_name"));
                row.put("owner_email", rs.getString("owner_email"));
                row.put("owner_phone", rs.getString("owner_phone"));
                row.put("owner_status", rs.getString("owner_status"));
                row.put("products", rs.getInt("products"));
                row.put("services", rs.getInt("services"));
                row.put("order_count", rs.getLong("order_count"));
                row.put("gmv_month", rs.getLong("gmv_month"));
                list.add(row);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getServices() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT cs.id, cs.shop_id, COALESCE(s.shop_name, '') AS shop_name, cs.service_name, cs.price, "
                + "COALESCE(cs.duration_text, '') AS duration_text, CHAR_LENGTH(COALESCE(cs.description, '')) AS desc_len, "
                + "LEFT(COALESCE(cs.description, ''), 600) AS description, cs.status, COALESCE(s.is_workshop, 0) AS is_workshop "
                + "FROM custom_services cs LEFT JOIN shops s ON s.id = cs.shop_id ORDER BY cs.id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("shop_id", rs.getInt("shop_id"));
                row.put("shop_name", rs.getString("shop_name"));
                row.put("name", rs.getString("service_name"));
                row.put("price", rs.getLong("price"));
                row.put("duration", rs.getString("duration_text"));
                row.put("desc_len", rs.getInt("desc_len"));
                row.put("description", rs.getString("description"));
                row.put("status", rs.getString("status"));
                row.put("workshop", rs.getInt("is_workshop") == 1);
                list.add(row);
            }
        }
        return list;
    }

    public void setShopVerified(int shopId, boolean verified) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE shops SET is_verified = ? WHERE id = ?")) {
            ps.setInt(1, verified ? 1 : 0);
            ps.setInt(2, shopId);
            if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Không tìm thấy cửa hàng #" + shopId);
        }
    }

    /** Khóa / mở khóa tài khoản chủ shop (cột users.status). */
    public void setShopOwnerStatus(int shopId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ? WHERE id = (SELECT owner_id FROM shops WHERE id = ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, shopId);
            if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Cửa hàng này chưa gắn với tài khoản chủ shop.");
        }
    }

    public void setProductStatus(int id, String status) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE products SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Không tìm thấy sản phẩm #" + id);
        }
    }

    public void setServiceStatus(int id, String status) throws SQLException {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE custom_services SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Không tìm thấy dịch vụ #" + id);
        }
    }

    /**
     * Duyệt hàng loạt các mục đang chờ duyệt và đạt đủ 4 tiêu chí tự động
     * (phải khớp với bộ tiêu chí hiển thị ở admin.jsp).
     */
    public int bulkApprove(String type) throws SQLException {
        int total = 0;
        try (Connection conn = getConnection()) {
            if (!"SERVICE".equals(type)) {
                String sql = "UPDATE products p SET p.status = 'ACTIVE' WHERE p.status = 'PENDING' "
                        + "AND COALESCE(p.sku, '') <> '' AND COALESCE(p.brand, '') <> '' AND p.price > 0 AND CHAR_LENGTH(COALESCE(p.description, '')) >= 100 "
                        + "AND (SELECT COUNT(*) FROM product_specs ps WHERE ps.product_id = p.id) >= 3 "
                        + "AND (SELECT COUNT(*) FROM product_compatibilities pc WHERE pc.product_id = p.id) >= 1";
                try (PreparedStatement ps = conn.prepareStatement(sql)) { total += ps.executeUpdate(); }
            }
            if (!"PRODUCT".equals(type)) {
                String sql = "UPDATE custom_services cs SET cs.status = 'ACTIVE' WHERE cs.status = 'PENDING' "
                        + "AND CHAR_LENGTH(COALESCE(cs.description, '')) >= 100 AND cs.price > 0 "
                        + "AND COALESCE(cs.duration_text, '') <> '' "
                        + "AND EXISTS (SELECT 1 FROM shops s WHERE s.id = cs.shop_id AND s.is_workshop = 1)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) { total += ps.executeUpdate(); }
            }
        }
        return total;
    }

    public int saveCategory(int id, String name, String slug, String icon) throws SQLException {
        if (id <= 0) {
            String sql = "INSERT INTO categories (name, slug, icon, product_count) VALUES (?, ?, ?, 0)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, name);
                ps.setString(2, slug);
                ps.setString(3, icon);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }
        String sql = "UPDATE categories SET name = ?, slug = ?, icon = ? WHERE id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, slug);
            ps.setString(3, icon);
            ps.setInt(4, id);
            if (ps.executeUpdate() == 0) throw new IllegalArgumentException("Không tìm thấy danh mục #" + id);
            return id;
        }
    }

    public Map<String, Object> getStats() throws SQLException {
        Map<String, Object> stats = new LinkedHashMap<>();
        try (Connection conn = getConnection()) {
            stats.put("userCount", count(conn, "SELECT COUNT(*) FROM users"));
            stats.put("orderCount", count(conn, "SELECT COUNT(*) FROM orders"));
            stats.put("productCount", count(conn, "SELECT COUNT(*) FROM products"));
            stats.put("totalOrdersValue", countLong(conn,
                    "SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status <> 'CANCELLED'"));

            Map<String, Integer> roleStats = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT role, COUNT(*) AS total FROM users GROUP BY role ORDER BY role");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) roleStats.put(rs.getString("role"), rs.getInt("total"));
            }
            stats.put("roleStats", roleStats);

            Map<String, Integer> orderStatusStats = new LinkedHashMap<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT order_status, COUNT(*) AS total FROM orders GROUP BY order_status ORDER BY order_status");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) orderStatusStats.put(rs.getString("order_status"), rs.getInt("total"));
            }
            stats.put("orderStatusStats", orderStatusStats);
        }
        return stats;
    }

    public Map<String, Object> getRevenueStats(String fromDateStr, String toDateStr) throws SQLException {
        Map<String, Object> result = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        LocalDate toDate;
        LocalDate fromDate;

        try {
            toDate = (toDateStr != null && !toDateStr.isBlank()) ? LocalDate.parse(toDateStr.trim()) : today;
        } catch (Exception e) {
            toDate = today;
        }

        try {
            fromDate = (fromDateStr != null && !fromDateStr.isBlank()) ? LocalDate.parse(fromDateStr.trim()) : toDate.minusDays(29);
        } catch (Exception e) {
            fromDate = toDate.minusDays(29);
        }

        if (fromDate.isAfter(toDate)) {
            LocalDate tmp = fromDate;
            fromDate = toDate;
            toDate = tmp;
        }

        DateTimeFormatter dtfIso = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter dtfShort = DateTimeFormatter.ofPattern("dd/MM");

        String sql = "SELECT DATE(created_at) AS order_date, "
                + "COUNT(*) AS total_orders, "
                + "COALESCE(SUM(total_amount), 0) AS total_revenue "
                + "FROM orders "
                + "WHERE order_status <> 'CANCELLED' "
                + "  AND DATE(created_at) >= ? AND DATE(created_at) <= ? "
                + "GROUP BY DATE(created_at) "
                + "ORDER BY order_date ASC";

        Map<String, Long> revenueMap = new HashMap<>();
        Map<String, Integer> orderCountMap = new HashMap<>();

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fromDate.format(dtfIso));
            ps.setString(2, toDate.format(dtfIso));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("order_date");
                    orderCountMap.put(d, rs.getInt("total_orders"));
                    revenueMap.put(d, rs.getLong("total_revenue"));
                }
            }
        }

        // Lấy số đơn bị hủy trong kỳ
        int cancelledOrders = 0;
        String cancelSql = "SELECT COUNT(*) FROM orders WHERE order_status = 'CANCELLED' AND DATE(created_at) >= ? AND DATE(created_at) <= ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(cancelSql)) {
            ps.setString(1, fromDate.format(dtfIso));
            ps.setString(2, toDate.format(dtfIso));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) cancelledOrders = rs.getInt(1);
            }
        }

        // Biểu đồ tròn phản ánh trạng thái hiện tại của TẤT CẢ đơn hàng trong CSDL.
        // Không lọc theo fromDate/toDate vì đơn hàng cũ vẫn cần xuất hiện trong thống kê trạng thái.
        // Biểu đồ cột doanh thu phía trên vẫn dùng khoảng ngày được chọn.
        Map<String, Integer> orderStatusBreakdown = new LinkedHashMap<>();
        String statusSql = "SELECT COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') AS status, COUNT(*) AS total "
                + "FROM orders "
                + "GROUP BY COALESCE(NULLIF(TRIM(order_status), ''), 'UNKNOWN') "
                + "ORDER BY status";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(statusSql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                orderStatusBreakdown.put(rs.getString("status"), rs.getInt("total"));
            }
        }

        // Tạo mảng liên tục cho từng ngày
        List<String> labels = new ArrayList<>();
        List<String> fullDates = new ArrayList<>();
        List<Long> revenueData = new ArrayList<>();
        List<Integer> orderData = new ArrayList<>();
        List<Map<String, Object>> dailyList = new ArrayList<>();

        long totalRevenue = 0;
        int totalOrders = 0;

        LocalDate curr = fromDate;
        while (!curr.isAfter(toDate)) {
            String iso = curr.format(dtfIso);
            String label = curr.format(dtfShort);
            long rev = revenueMap.getOrDefault(iso, 0L);
            int orders = orderCountMap.getOrDefault(iso, 0);

            labels.add(label);
            fullDates.add(iso);
            revenueData.add(rev);
            orderData.add(orders);

            totalRevenue += rev;
            totalOrders += orders;

            Map<String, Object> dayRow = new LinkedHashMap<>();
            dayRow.put("date", iso);
            dayRow.put("label", label);
            dayRow.put("orders", orders);
            dayRow.put("revenue", rev);
            dailyList.add(dayRow);

            curr = curr.plusDays(1);
        }

        long dayCount = Math.max(1, java.time.temporal.ChronoUnit.DAYS.between(fromDate, toDate) + 1);
        long avgRevenuePerDay = totalRevenue / dayCount;

        result.put("fromDate", fromDate.format(dtfIso));
        result.put("toDate", toDate.format(dtfIso));
        result.put("dayCount", dayCount);
        result.put("totalRevenue", totalRevenue);
        result.put("totalOrders", totalOrders);
        result.put("cancelledOrders", cancelledOrders);
        result.put("avgRevenuePerDay", avgRevenuePerDay);
        result.put("labels", labels);
        result.put("fullDates", fullDates);
        result.put("revenueData", revenueData);
        result.put("orderData", orderData);
        result.put("dailyList", dailyList);
        result.put("orderStatusBreakdown", orderStatusBreakdown);

        return result;
    }

    private int count(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private long countLong(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            rs.next();
            return rs.getLong(1);
        }
    }

    private int firstKey(PreparedStatement ps) throws SQLException {
        try (ResultSet rs = ps.getGeneratedKeys()) {
            if (!rs.next()) throw new SQLException("Không lấy được ID bản ghi vừa tạo.");
            return rs.getInt(1);
        }
    }

    public int saveUser(int id, String firstName, String lastName, String email,
                        String password, String role, String status) throws SQLException {
        if (id <= 0) {
            String avatar = initials(firstName, lastName);
            String sql = "INSERT INTO users (first_name, last_name, email, password, avatar_text, role, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, firstName);
                ps.setString(2, lastName);
                ps.setString(3, email);
                ps.setString(4, password);
                ps.setString(5, avatar);
                ps.setString(6, role);
                ps.setString(7, status);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }

        boolean updatePassword = password != null && !password.isBlank();
        String sql = updatePassword
                ? "UPDATE users SET first_name=?, last_name=?, email=?, password=?, role=?, status=? WHERE id=?"
                : "UPDATE users SET first_name=?, last_name=?, email=?, role=?, status=? WHERE id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, firstName);
            ps.setString(i++, lastName);
            ps.setString(i++, email);
            if (updatePassword) ps.setString(i++, password);
            ps.setString(i++, role);
            ps.setString(i++, status);
            ps.setInt(i++, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy người dùng #" + id);
            return id;
        }
    }

    public void deleteUser(int id) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Clean cart items
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM cart_items WHERE user_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                // Clean orders
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE user_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                // Clean user
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?")) {
                    ps.setInt(1, id);
                    if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy người dùng #" + id);
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public Map<String, Object> saveOrder(int id, String orderCode, String receiverName, String customerEmail,
                                         String receiverPhone, String shippingAddress, int productId,
                                         int quantity, String status) throws SQLException {
        Map<String, Object> result = new LinkedHashMap<>();
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                int userId;
                try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email=?")) {
                    ps.setString(1, customerEmail);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Email khách hàng chưa có tài khoản trong hệ thống.");
                        userId = rs.getInt("id");
                    }
                }

                if (id > 0) {
                    // Update Order Mode
                    String finalCode = (orderCode == null || orderCode.isBlank()) ? null : orderCode.trim();
                    String sql = finalCode != null
                            ? "UPDATE orders SET order_code=?, receiver_name=?, receiver_phone=?, shipping_address=?, user_id=? WHERE id=?"
                            : "UPDATE orders SET receiver_name=?, receiver_phone=?, shipping_address=?, user_id=? WHERE id=?";

                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        int idx = 1;
                        if (finalCode != null) ps.setString(idx++, finalCode);
                        ps.setString(idx++, receiverName);
                        ps.setString(idx++, receiverPhone);
                        ps.setString(idx++, shippingAddress);
                        ps.setInt(idx++, userId);
                        ps.setInt(idx++, id);
                        if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy đơn hàng #" + id);
                    }
                    conn.commit();
                    result.put("id", id);
                    result.put("orderCode", finalCode);
                    return result;
                }

                // Insert New Order Mode
                String normalizedCode = (orderCode == null || orderCode.isBlank()) ? "KH" + System.currentTimeMillis() : orderCode.trim();
                if (productId <= 0) throw new SQLException("Vui lòng chọn sản phẩm cho đơn hàng mới.");
                if (quantity < 1 || quantity > 10000) throw new SQLException("Số lượng phải từ 1 đến 10000.");

                int shopId;
                String productName;
                long unitPrice;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT id, shop_id, name, price FROM products WHERE id=? AND status='ACTIVE'")) {
                    ps.setInt(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Sản phẩm không tồn tại hoặc đang ngừng bán.");
                        shopId = rs.getInt("shop_id");
                        productName = rs.getString("name");
                        unitPrice = rs.getLong("price");
                    }
                }
                long total = Math.multiplyExact(unitPrice, (long) quantity);
                int orderId;
                String sql = "INSERT INTO orders (order_code, user_id, shop_id, product_id, variant_summary, receiver_name, receiver_phone, shipping_address, subtotal, total_amount, order_status) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, normalizedCode);
                    ps.setInt(2, userId);
                    ps.setInt(3, shopId);
                    ps.setInt(4, productId);
                    ps.setString(5, productName + " · ×" + quantity);
                    ps.setString(6, receiverName);
                    ps.setString(7, receiverPhone);
                    ps.setString(8, shippingAddress);
                    ps.setLong(9, total);
                    ps.setLong(10, total);
                    ps.setString(11, status);
                    ps.executeUpdate();
                    orderId = firstKey(ps);
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, line_total) VALUES (?, ?, ?, ?, ?, ?)")) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, productId);
                    ps.setString(3, productName);
                    ps.setInt(4, quantity);
                    ps.setLong(5, unitPrice);
                    ps.setLong(6, total);
                    ps.executeUpdate();
                }
                conn.commit();
                result.put("id", orderId);
                result.put("orderCode", normalizedCode);
                result.put("totalAmount", total);
                return result;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void deleteOrder(int id) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM order_items WHERE order_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM orders WHERE id=?")) {
                    ps.setInt(1, id);
                    if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy đơn hàng #" + id);
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public int saveProduct(int id, String name, String sku, int shopId, int categoryId,
                           long price, int stock, String status) throws SQLException {
        if (id <= 0) {
            String sql = "INSERT INTO products (shop_id, category_id, sku, name, price, stock, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, shopId);
                ps.setInt(2, categoryId);
                ps.setString(3, sku);
                ps.setString(4, name);
                ps.setLong(5, price);
                ps.setInt(6, stock);
                ps.setString(7, status);
                ps.executeUpdate();
                return firstKey(ps);
            }
        }
        String sql = "UPDATE products SET name=?, sku=?, shop_id=?, category_id=?, price=?, stock=?, status=? WHERE id=?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, sku);
            ps.setInt(3, shopId);
            ps.setInt(4, categoryId);
            ps.setLong(5, price);
            ps.setInt(6, stock);
            ps.setString(7, status);
            ps.setInt(8, id);
            if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy sản phẩm #" + id);
            return id;
        }
    }

    public boolean deleteProduct(int id) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Luôn xóa sản phẩm khỏi giỏ hàng để tránh lỗi khóa ngoại
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM cart_items WHERE product_id=?")) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }

                int references;
                String useSql = "SELECT "
                        + "(SELECT COUNT(*) FROM order_items WHERE product_id=?) + "
                        + "(SELECT COUNT(*) FROM orders WHERE product_id=?) AS ref_count";
                try (PreparedStatement ps = conn.prepareStatement(useSql)) {
                    ps.setInt(1, id);
                    ps.setInt(2, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        references = rs.getInt("ref_count");
                    }
                }

                if (references > 0) {
                    try (PreparedStatement ps = conn.prepareStatement("UPDATE products SET status='INACTIVE' WHERE id=?")) {
                        ps.setInt(1, id);
                        if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy sản phẩm #" + id);
                    }
                    conn.commit();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE id=?")) {
                    ps.setInt(1, id);
                    if (ps.executeUpdate() == 0) throw new SQLException("Không tìm thấy sản phẩm #" + id);
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private String initials(String firstName, String lastName) {
        String first = firstName == null || firstName.isBlank() ? "K" : firstName.trim().substring(0, 1);
        String last = lastName == null || lastName.isBlank() ? "H" : lastName.trim().substring(0, 1);
        return (first + last).toUpperCase();
    }
}