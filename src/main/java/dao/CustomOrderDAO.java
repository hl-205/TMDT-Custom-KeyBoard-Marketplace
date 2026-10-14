package dao;

import java.sql.*;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class CustomOrderDAO {

    private static boolean dbNormalized = false;

    public static String formatVND(long amount) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.getDefault());
        symbols.setGroupingSeparator('.');
        return new DecimalFormat("#,###", symbols).format(amount) + "₫";
    }

    public static class ServicePackage {
        private int id;
        private int shopId;
        private String serviceName;
        private long price;
        private String durationText;
        private String description;
        private boolean popular;
        private int soldMonth;
        private String status;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getShopId() { return shopId; }
        public void setShopId(int shopId) { this.shopId = shopId; }
        public String getServiceName() { return serviceName; }
        public void setServiceName(String serviceName) { this.serviceName = serviceName; }
        public long getPrice() { return price; }
        public void setPrice(long price) { this.price = price; }
        public String getDurationText() { return durationText; }
        public void setDurationText(String durationText) { this.durationText = durationText; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public boolean isPopular() { return popular; }
        public void setPopular(boolean popular) { this.popular = popular; }
        public int getSoldMonth() { return soldMonth; }
        public void setSoldMonth(int soldMonth) { this.soldMonth = soldMonth; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }

        public String getFormattedPrice() { return formatVND(price); }
        public String[] getFeatureLines() {
            if (description == null || description.isBlank()) return new String[0];
            return description.split(";");
        }
    }

    public static class CustomOrder {
        private int id;
        private String orderCode;
        private int userId;
        private int shopId;
        private String shopName;
        private int productId;
        private String productName;
        private String variantSummary;
        private String receiverName;
        private String receiverPhone;
        private String shippingAddress;
        private boolean customOrder;
        private long subtotal;
        private long customFee;
        private long shippingFee;
        private long discountAmount;
        private long totalAmount;
        private String paymentMethod;
        private String orderStatus;
        private int progressPercent;
        private String customerNote;
        private int committedDays;
        private Timestamp createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getOrderCode() { return orderCode; }
        public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
        public int getUserId() { return userId; }
        public void setUserId(int userId) { this.userId = userId; }
        public int getShopId() { return shopId; }
        public void setShopId(int shopId) { this.shopId = shopId; }
        public String getShopName() { return shopName != null ? shopName : "SwitchHouse"; }
        public void setShopName(String shopName) { this.shopName = shopName; }
        public int getProductId() { return productId > 0 ? productId : 1; }
        public void setProductId(int productId) { this.productId = productId; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public String getVariantSummary() { return variantSummary; }
        public void setVariantSummary(String variantSummary) { this.variantSummary = variantSummary; }
        public String getReceiverName() { return receiverName; }
        public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
        public String getReceiverPhone() { return receiverPhone; }
        public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }
        public String getShippingAddress() { return shippingAddress; }
        public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
        public boolean isCustomOrder() { return customOrder; }
        public void setCustomOrder(boolean customOrder) { this.customOrder = customOrder; }
        public long getSubtotal() { return subtotal; }
        public void setSubtotal(long subtotal) { this.subtotal = subtotal; }
        public long getCustomFee() { return customFee; }
        public void setCustomFee(long customFee) { this.customFee = customFee; }
        public long getShippingFee() { return shippingFee; }
        public void setShippingFee(long shippingFee) { this.shippingFee = shippingFee; }
        public long getDiscountAmount() { return discountAmount; }
        public void setDiscountAmount(long discountAmount) { this.discountAmount = discountAmount; }
        public long getTotalAmount() { return totalAmount; }
        public void setTotalAmount(long totalAmount) { this.totalAmount = totalAmount; }
        public String getPaymentMethod() { return paymentMethod; }
        public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
        public String getOrderStatus() { return orderStatus; }
        public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }
        public int getProgressPercent() { return progressPercent; }
        public void setProgressPercent(int progressPercent) { this.progressPercent = progressPercent; }
        public String getCustomerNote() { return customerNote; }
        public void setCustomerNote(String customerNote) { this.customerNote = customerNote; }
        public int getCommittedDays() { return committedDays; }
        public void setCommittedDays(int committedDays) { this.committedDays = committedDays; }
        public Timestamp getCreatedAt() { return createdAt; }
        public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

        public String getFormattedSubtotal() { return formatVND(subtotal); }
        public String getFormattedCustomFee() { return formatVND(customFee); }
        public String getFormattedShippingFee() { return formatVND(shippingFee); }
        public String getFormattedDiscount() { return formatVND(discountAmount); }
        public String getFormattedTotal() { return formatVND(totalAmount); }
        public String getFormattedPlatformFee() { return formatVND(Math.round(totalAmount * 0.05)); }
        public String getFormattedPaymentFee() { return formatVND(Math.round(totalAmount * 0.011)); }
        public String getFormattedNetShopReceive() {
            long net = totalAmount - Math.round(totalAmount * 0.05) - Math.round(totalAmount * 0.011);
            return formatVND(net);
        }

        public String getBuildCode() {
            return "Build #B-" + (7700 + id);
        }

        public String getProductSummary() {
            if (productName != null && !productName.isBlank()) {
                return productName.length() > 38 ? productName.substring(0, 38) + "..." : productName;
            }
            return getBuildCode();
        }
    }

    public static class ProgressStep {
        private int id;
        private int orderId;
        private int stepNumber;
        private String stepTitle;
        private String stepDesc;
        private String status;
        private String updatedTime;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getOrderId() { return orderId; }
        public void setOrderId(int orderId) { this.orderId = orderId; }
        public int getStepNumber() { return stepNumber; }
        public void setStepNumber(int stepNumber) { this.stepNumber = stepNumber; }
        public String getStepTitle() { return stepTitle; }
        public void setStepTitle(String stepTitle) { this.stepTitle = stepTitle; }
        public String getStepDesc() { return stepDesc; }
        public void setStepDesc(String stepDesc) { this.stepDesc = stepDesc; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getUpdatedTime() { return updatedTime; }
        public void setUpdatedTime(String updatedTime) { this.updatedTime = updatedTime; }
    }

    // Tự động chuẩn hóa CSDL: tách đánh giá mẫu khỏi user_id=1 và đảm bảo bảng orders có cột product_id
    public synchronized void ensureDatabaseNormalized() {
        if (dbNormalized) return;
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {

            // 1. Gỡ user_id = 1 khỏi 2 đánh giá mẫu của Nguyễn Minh và Trần Hoàng để không bị gắn nhầm vào tài khoản đăng nhập
            st.executeUpdate("UPDATE reviews SET user_id = NULL WHERE reviewer_name IN ('Nguyễn Minh', 'Trần Hoàng')");

            // 2. Thêm cột product_id và variant_summary vào bảng orders nếu chưa có
            try {
                st.executeUpdate("ALTER TABLE orders ADD COLUMN product_id INT DEFAULT 1");
            } catch (SQLException ignored) {}
            try {
                st.executeUpdate("ALTER TABLE orders ADD COLUMN variant_summary VARCHAR(255) DEFAULT 'Phân loại: Tiêu chuẩn · ×1'");
            } catch (SQLException ignored) {}

            // 3. Nếu bảng orders chưa có dữ liệu thì khởi tạo dữ liệu đơn hàng trong DB
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM orders")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    String insertOrder = "INSERT INTO orders (order_code, user_id, shop_id, product_id, variant_summary, receiver_name, receiver_phone, shipping_address, "
                            + "is_custom_order, subtotal, custom_fee, shipping_fee, discount_amount, total_amount, payment_method, "
                            + "order_status, progress_percent, customer_note, committed_days) VALUES "
                            + "('KH-284193', 1, 2, 1, 'Kit Tofu60 2.0 · Oil King ×70 · GMK Olivia · Full lube', 'Khách hàng ID #1', '0987 654 321', '128 Nguyễn Văn Cừ, Quận 5, TP.HCM', 1, 8500000, 750000, 30000, 790000, 8490000, 'VNPAY', 'PROCESSING', 60, 'Lube kỹ phím dài giúp em, ưu tiên âm trầm thocky.', 7),"
                            + "('KH-281044', 1, 3, 7, 'Phân loại: Black & Pink · ×1', 'Khách hàng ID #1', '0987 654 321', '128 Nguyễn Văn Cừ, Quận 5, TP.HCM', 0, 690000, 0, 0, 0, 690000, 'MoMo', 'COMPLETED', 100, '', 3),"
                            + "('KH-284170', 2, 2, 4, 'Keychron Q1 Pro · Boba U4T ×84 · Gói Premium', 'Nguyễn Minh', '0938 111 222', 'Quận Bình Thạnh, TP.HCM', 1, 5890000, 1250000, 0, 0, 7140000, 'VNPAY', 'PENDING', 0, 'Em muốn tape mod + PE foam nếu shop làm được. Stab thì clip chân với band-aid giúp em.', 7),"
                            + "('KH-284169', 2, 2, 1, 'Kit Tofu60 2.0 · Akko Cream Yellow · Gói Full lube', 'Vũ Thành', '0905 888 777', 'Quận 1, TP.HCM', 1, 4140000, 750000, 0, 0, 4890000, 'ZaloPay', 'PENDING', 0, 'Nhờ shop test kỹ từng socket hotswap trước khi lắp switch.', 6)";
                    st.executeUpdate(insertOrder);
                }
            }

            // 4. Đảm bảo đơn #KH-281044 (sản phẩm 7) tồn tại trong DB cho user_id = 1 để test đánh giá từ DB
            try (ResultSet rs = st.executeQuery("SELECT id FROM orders WHERE order_code = 'KH-281044'")) {
                if (!rs.next()) {
                    st.executeUpdate("INSERT INTO orders (order_code, user_id, shop_id, product_id, variant_summary, receiver_name, receiver_phone, shipping_address, "
                            + "is_custom_order, subtotal, custom_fee, shipping_fee, discount_amount, total_amount, payment_method, "
                            + "order_status, progress_percent, customer_note, committed_days) VALUES "
                            + "('KH-281044', 1, 3, 7, 'Phân loại: Black & Pink · ×1', 'Khách hàng', '0987 654 321', 'TP.HCM', 0, 690000, 0, 0, 0, 690000, 'MoMo', 'COMPLETED', 100, '', 3)");
                }
            }

            // Cập nhật product_id chuẩn cho các đơn hiện có trong bảng orders
            st.executeUpdate("UPDATE orders SET product_id = 7, shop_id = 3, variant_summary = 'Phân loại: Black & Pink · ×1' WHERE order_code = 'KH-281044'");
            st.executeUpdate("UPDATE orders SET product_id = 1, variant_summary = 'Kit Tofu60 2.0 · Oil King ×70 · GMK Olivia · Full lube' WHERE order_code = 'KH-284193'");
            st.executeUpdate("UPDATE orders SET product_id = 4, variant_summary = 'Keychron Q1 Pro · Boba U4T ×84 · Gói Premium' WHERE order_code = 'KH-284170'");

            // Gán các đơn mẫu ban đầu (trừ đơn của user_id=1) sang user_id=2 để user_id=1 chỉ thấy đúng đơn của mình
            st.executeUpdate("UPDATE orders SET user_id = 2 WHERE order_code IN ('KH-284188', 'KH-284170', 'KH-284169', 'KH-284166', 'KH-284140')");

            // Khởi tạo 5 bước tiến độ trong bảng order_progress nếu chưa có
            CustomOrder ord193 = getOrderByCode("KH-284193");
            if (ord193 != null && getProgressSteps(ord193.getId()).isEmpty()) {
                seedProgressStepsForOrder193(conn, ord193.getId());
            }
            CustomOrder ord170 = getOrderByCode("KH-284170");
            if (ord170 != null && getProgressSteps(ord170.getId()).isEmpty()) {
                createInitialFiveSteps(conn, ord170.getId());
            }
            CustomOrder ord169 = getOrderByCode("KH-284169");
            if (ord169 != null && getProgressSteps(ord169.getId()).isEmpty()) {
                createInitialFiveSteps(conn, ord169.getId());
            }

            dbNormalized = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void seedProgressStepsForOrder193(Connection conn, int orderId) throws SQLException {
        String sql = "INSERT INTO order_progress (order_id, step_number, step_title, step_desc, status, updated_time) VALUES "
                + "(?, 1, 'Rã hàn & kiểm tra PCB', 'Đã tháo switch cũ, đo thông mạch toàn bộ 61 socket. PCB không lỗi, tất cả socket nhận tín hiệu bình thường.', 'COMPLETED', '22/09 · 09:20'),"
                + "(?, 2, 'Lube switch (70/70)', 'Lube Krytox 205g0 cho housing và lò xo, film Deskeys cho toàn bộ 70 switch. Đã test âm thanh mẫu 5 nút.', 'COMPLETED', '23/09 · 16:40'),"
                + "(?, 3, 'Cân stabilizer', 'Clip + lube Durock V2 cho phím Space, Enter, Backspace, 2 Shift. Đã band-aid mod, hết rattle.', 'COMPLETED', '25/09 · 11:05'),"
                + "(?, 4, 'Lắp ráp & test toàn phím', 'Lắp switch, gắn keycap, test từng phím bằng phần mềm.', 'IN_PROGRESS', 'Dự kiến 27/09'),"
                + "(?, 5, 'Đóng gói & bàn giao vận chuyển', 'Quay video test cuối, đóng thùng chống sốc.', 'PENDING', 'Dự kiến 28/09')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) ps.setInt(i, orderId);
            ps.executeUpdate();
        }
    }

    public void createInitialFiveSteps(Connection conn, int orderId) throws SQLException {
        String del = "DELETE FROM order_progress WHERE order_id = ?";
        try (PreparedStatement psDel = conn.prepareStatement(del)) {
            psDel.setInt(1, orderId);
            psDel.executeUpdate();
        }
        String sql = "INSERT INTO order_progress (order_id, step_number, step_title, step_desc, status, updated_time) VALUES "
                + "(?, 1, 'Rã hàn & kiểm tra PCB', 'Đo thông mạch toàn bộ socket và kiểm tra LED trên PCB trước khi mod.', 'IN_PROGRESS', 'Đang thực hiện'),"
                + "(?, 2, 'Lube switch (toàn bộ)', 'Lube Krytox 205g0 cho housing và lò xo, gắn switch film.', 'PENDING', 'Chờ thực hiện'),"
                + "(?, 3, 'Cân stabilizer', 'Clip chân, lube wire và cân chỉnh chống lọc xọc các phím dài.', 'PENDING', 'Chờ thực hiện'),"
                + "(?, 4, 'Lắp ráp & test toàn phím', 'Lắp switch, gắn keycap, test keymap và âm gõ toàn phím.', 'PENDING', 'Chờ thực hiện'),"
                + "(?, 5, 'Đóng gói & bàn giao vận chuyển', 'Quay video soundtest bàn giao và đóng gói chống sốc.', 'PENDING', 'Chờ thực hiện')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) ps.setInt(i, orderId);
            ps.executeUpdate();
        }
    }

    // Lấy danh sách đơn hàng của đúng User đang đăng nhập từ bảng orders
    public List<CustomOrder> getOrdersByUserId(int userId) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        String sql = "SELECT o.*, s.shop_name, p.name AS product_name "
                + "FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id "
                + "WHERE o.user_id = ? ORDER BY o.id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("product_name"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy danh sách các đơn đã COMPLETED của User nhưng chưa được User đó đánh giá trong bảng reviews
    public List<CustomOrder> getPendingReviewOrdersByUser(int userId) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        String sql = "SELECT o.*, s.shop_name, p.name AS product_name "
                + "FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id "
                + "WHERE o.user_id = ? AND o.order_status = 'COMPLETED' "
                + "AND o.product_id NOT IN (SELECT r.product_id FROM reviews r WHERE r.user_id = ?) "
                + "ORDER BY o.id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("product_name"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Đếm số lượng đơn theo trạng thái trong DB cho Seller KPI & Sidebar badge
    public int countOrdersByStatus(String status, boolean onlyCustom) {
        ensureDatabaseNormalized();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM orders WHERE 1=1 ");
        if (status != null && !"ALL".equals(status)) {
            sql.append("AND order_status = ? ");
        }
        if (onlyCustom) {
            sql.append("AND is_custom_order = 1 ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (status != null && !"ALL".equals(status)) {
                ps.setString(1, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ServicePackage> getAllServicesByShop(int shopId) {
        ensureDatabaseNormalized();
        List<ServicePackage> list = new ArrayList<>();
        String sql = "SELECT * FROM custom_services WHERE shop_id = ? ORDER BY price ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ServicePackage sp = new ServicePackage();
                    sp.setId(rs.getInt("id"));
                    sp.setShopId(rs.getInt("shop_id"));
                    sp.setServiceName(rs.getString("service_name"));
                    sp.setPrice(rs.getLong("price"));
                    sp.setDurationText(rs.getString("duration_text"));
                    sp.setDescription(rs.getString("description"));
                    sp.setPopular(rs.getInt("is_popular") == 1);
                    sp.setSoldMonth(rs.getInt("sold_month"));
                    sp.setStatus(rs.getString("status"));
                    list.add(sp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addServicePackage(int shopId, String name, long price, String duration, String desc, boolean popular) {
        String sql = "INSERT INTO custom_services (shop_id, service_name, price, duration_text, description, is_popular, sold_month, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0, 'ACTIVE')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            ps.setString(2, name.trim());
            ps.setLong(3, price);
            ps.setString(4, duration.trim());
            ps.setString(5, desc.trim());
            ps.setInt(6, popular ? 1 : 0);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateServicePackage(int id, String name, long price, String duration, String desc, boolean popular) {
        String sql = "UPDATE custom_services SET service_name = ?, price = ?, duration_text = ?, description = ?, is_popular = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setLong(2, price);
            ps.setString(3, duration.trim());
            ps.setString(4, desc.trim());
            ps.setInt(5, popular ? 1 : 0);
            ps.setInt(6, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleServiceStatus(int id) {
        String sql = "UPDATE custom_services SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteServicePackage(int id) {
        String sql = "DELETE FROM custom_services WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<CustomOrder> getOrdersForSeller(String statusFilter, boolean onlyCustom) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, s.shop_name, p.name AS product_name FROM orders o "
                        + "LEFT JOIN shops s ON o.shop_id = s.id "
                        + "LEFT JOIN products p ON o.product_id = p.id WHERE 1=1 "
        );
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
            sql.append("AND o.order_status = ? ");
        }
        if (onlyCustom) {
            sql.append("AND o.is_custom_order = 1 ");
        }
        sql.append("ORDER BY o.id ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("product_name"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CustomOrder getOrderById(int id) {
        ensureDatabaseNormalized();
        String sql = "SELECT o.*, s.shop_name, p.name AS product_name FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("product_name"));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public CustomOrder getOrderByCode(String code) {
        String sql = "SELECT o.*, s.shop_name, p.name AS product_name FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id WHERE o.order_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("product_name"));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean acceptCustomOrder(int orderId, int committedDays, String shopNote, long extraFee) {
        String sql = "UPDATE orders SET order_status = 'PROCESSING', progress_percent = 20, committed_days = ?, "
                + "custom_fee = custom_fee + ?, total_amount = total_amount + ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, committedDays);
            ps.setLong(2, extraFee);
            ps.setLong(3, extraFee);
            ps.setInt(4, orderId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                List<ProgressStep> existing = getProgressSteps(orderId);
                if (existing.isEmpty()) {
                    createInitialFiveSteps(conn, orderId);
                }
            }
            return updated;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectCustomOrder(int orderId) {
        String sql = "UPDATE orders SET order_status = 'CANCELLED', progress_percent = 0 WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ProgressStep> getProgressSteps(int orderId) {
        List<ProgressStep> list = new ArrayList<>();
        String sql = "SELECT * FROM order_progress WHERE order_id = ? ORDER BY step_number ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProgressStep st = new ProgressStep();
                    st.setId(rs.getInt("id"));
                    st.setOrderId(rs.getInt("order_id"));
                    st.setStepNumber(rs.getInt("step_number"));
                    st.setStepTitle(rs.getString("step_title"));
                    st.setStepDesc(rs.getString("step_desc"));
                    st.setStatus(rs.getString("status"));
                    st.setUpdatedTime(rs.getString("updated_time"));
                    list.add(st);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateProgressStep(int orderId, int stepNumber, String stepDesc, boolean markCompleted) {
        String nowStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM · HH:mm"));
        try (Connection conn = DBContext.getConnection()) {
            if (markCompleted) {
                String sql = "UPDATE order_progress SET step_desc = ?, status = 'COMPLETED', updated_time = ? "
                        + "WHERE order_id = ? AND step_number = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, stepDesc.trim());
                    ps.setString(2, nowStr);
                    ps.setInt(3, orderId);
                    ps.setInt(4, stepNumber);
                    ps.executeUpdate();
                }

                if (stepNumber < 5) {
                    String nextSql = "UPDATE order_progress SET status = 'IN_PROGRESS' "
                            + "WHERE order_id = ? AND step_number = ? AND status = 'PENDING'";
                    try (PreparedStatement psNext = conn.prepareStatement(nextSql)) {
                        psNext.setInt(1, orderId);
                        psNext.setInt(2, stepNumber + 1);
                        psNext.executeUpdate();
                    }
                }

                String cntSql = "SELECT COUNT(*) FROM order_progress WHERE order_id = ? AND status = 'COMPLETED'";
                int completedCount = 0;
                try (PreparedStatement psCnt = conn.prepareStatement(cntSql)) {
                    psCnt.setInt(1, orderId);
                    try (ResultSet rs = psCnt.executeQuery()) {
                        if (rs.next()) completedCount = rs.getInt(1);
                    }
                }
                int newPercent = Math.min(100, completedCount * 20);
                String newOrderStatus = (newPercent >= 100) ? "SHIPPING" : "PROCESSING";

                String upOrd = "UPDATE orders SET progress_percent = ?, order_status = ? WHERE id = ?";
                try (PreparedStatement psOrd = conn.prepareStatement(upOrd)) {
                    psOrd.setInt(1, newPercent);
                    psOrd.setString(2, newOrderStatus);
                    psOrd.setInt(3, orderId);
                    psOrd.executeUpdate();
                }
            } else {
                String draftSql = "UPDATE order_progress SET step_desc = ? WHERE order_id = ? AND step_number = ?";
                try (PreparedStatement ps = conn.prepareStatement(draftSql)) {
                    ps.setString(1, stepDesc.trim());
                    ps.setInt(2, orderId);
                    ps.setInt(3, stepNumber);
                    ps.executeUpdate();
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private CustomOrder mapOrder(ResultSet rs) throws SQLException {
        CustomOrder o = new CustomOrder();
        o.setId(rs.getInt("id"));
        o.setOrderCode(rs.getString("order_code"));
        o.setUserId(rs.getInt("user_id"));
        o.setShopId(rs.getInt("shop_id"));
        try { o.setProductId(rs.getInt("product_id")); } catch (SQLException ignored) { o.setProductId(1); }
        try { o.setVariantSummary(rs.getString("variant_summary")); } catch (SQLException ignored) { o.setVariantSummary("Phân loại: Tiêu chuẩn · ×1"); }
        o.setReceiverName(rs.getString("receiver_name"));
        o.setReceiverPhone(rs.getString("receiver_phone"));
        o.setShippingAddress(rs.getString("shipping_address"));
        o.setCustomOrder(rs.getInt("is_custom_order") == 1);
        o.setSubtotal(rs.getLong("subtotal"));
        o.setCustomFee(rs.getLong("custom_fee"));
        o.setShippingFee(rs.getLong("shipping_fee"));
        o.setDiscountAmount(rs.getLong("discount_amount"));
        o.setTotalAmount(rs.getLong("total_amount"));
        o.setPaymentMethod(rs.getString("payment_method"));
        o.setOrderStatus(rs.getString("order_status"));
        o.setProgressPercent(rs.getInt("progress_percent"));
        o.setCustomerNote(rs.getString("customer_note"));
        o.setCommittedDays(rs.getInt("committed_days"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}