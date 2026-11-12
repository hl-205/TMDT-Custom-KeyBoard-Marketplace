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

    private static boolean schemaChecked = false;

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

    public static class SellerProductItem {
        private int id;
        private int shopId;
        private int categoryId;
        private String categoryName;
        private String sku;
        private String name;
        private String brand;
        private String shortDesc;
        private String description;
        private long price;
        private long oldPrice;
        private int stock;
        private int soldCount;
        private boolean supportCustom;
        private String switchType;
        private String actuationForce;
        private String pinType;
        private String layout;
        private String mountType;
        private String status;
        private int specCount;
        private int compatCount;
        private String specsText;
        private String compatText;
        private Timestamp createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getShopId() { return shopId; }
        public void setShopId(int shopId) { this.shopId = shopId; }
        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
        public String getCategoryName() { return categoryName != null ? categoryName : "Linh kiện"; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
        public String getSku() { return sku != null ? sku : ""; }
        public void setSku(String sku) { this.sku = sku; }
        public String getName() { return name != null ? name : ""; }
        public void setName(String name) { this.name = name; }
        public String getBrand() { return brand != null ? brand : ""; }
        public void setBrand(String brand) { this.brand = brand; }
        public String getShortDesc() { return shortDesc != null ? shortDesc : ""; }
        public void setShortDesc(String shortDesc) { this.shortDesc = shortDesc; }
        public String getDescription() { return description != null ? description : ""; }
        public void setDescription(String description) { this.description = description; }
        public long getPrice() { return price; }
        public void setPrice(long price) { this.price = price; }
        public long getOldPrice() { return oldPrice; }
        public void setOldPrice(long oldPrice) { this.oldPrice = oldPrice; }
        public int getStock() { return stock; }
        public void setStock(int stock) { this.stock = stock; }
        public int getSoldCount() { return soldCount; }
        public void setSoldCount(int soldCount) { this.soldCount = soldCount; }
        public boolean isSupportCustom() { return supportCustom; }
        public void setSupportCustom(boolean supportCustom) { this.supportCustom = supportCustom; }
        public String getSwitchType() { return switchType != null ? switchType : ""; }
        public void setSwitchType(String switchType) { this.switchType = switchType; }
        public String getActuationForce() { return actuationForce != null ? actuationForce : ""; }
        public void setActuationForce(String actuationForce) { this.actuationForce = actuationForce; }
        public String getPinType() { return pinType != null ? pinType : ""; }
        public void setPinType(String pinType) { this.pinType = pinType; }
        public String getLayout() { return layout != null ? layout : ""; }
        public void setLayout(String layout) { this.layout = layout; }
        public String getMountType() { return mountType != null ? mountType : ""; }
        public void setMountType(String mountType) { this.mountType = mountType; }
        public String getStatus() { return status != null ? status : "PENDING"; }
        public void setStatus(String status) { this.status = status; }
        public int getSpecCount() { return specCount; }
        public void setSpecCount(int specCount) { this.specCount = specCount; }
        public int getCompatCount() { return compatCount; }
        public void setCompatCount(int compatCount) { this.compatCount = compatCount; }
        public String getSpecsText() { return specsText != null ? specsText : ""; }
        public void setSpecsText(String specsText) { this.specsText = specsText; }
        public String getCompatText() { return compatText != null ? compatText : ""; }
        public void setCompatText(String compatText) { this.compatText = compatText; }
        public Timestamp getCreatedAt() { return createdAt; }
        public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

        public String getFormattedPrice() { return formatVND(price); }
        public boolean isAutoPassModeration() {
            return !getSku().isBlank() && !getBrand().isBlank() && price > 0
                    && getDescription().length() >= 100 && specCount >= 3 && compatCount >= 1;
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
        private String shopNote;
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
        public String getShopNote() { return shopNote; }
        public void setShopNote(String shopNote) { this.shopNote = shopNote; }
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
            return isCustomOrder() ? ("Build #B-" + (7700 + id)) : ("Đơn bán lẻ #" + orderCode);
        }

        public String getProductSummary() {
            if (productName != null && !productName.isBlank()) {
                return productName.length() > 42 ? productName.substring(0, 42) + "..." : productName;
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

    public synchronized void ensureDatabaseNormalized() {
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {

            if (!schemaChecked) {
                try { st.executeUpdate("ALTER TABLE orders ADD COLUMN product_id INT DEFAULT 1"); } catch (SQLException ignored) {}
                try { st.executeUpdate("ALTER TABLE orders ADD COLUMN variant_summary VARCHAR(255) DEFAULT 'Phân loại: Tiêu chuẩn · ×1'"); } catch (SQLException ignored) {}
                try { st.executeUpdate("ALTER TABLE orders ADD COLUMN shop_note TEXT"); } catch (SQLException ignored) {}
                schemaChecked = true;
            }

            String syncItemsSql = "UPDATE orders o "
                    + "JOIN order_items oi ON o.id = oi.order_id "
                    + "SET o.product_id = oi.product_id, "
                    + "    o.variant_summary = CONCAT('Số lượng: ×', oi.quantity, ' · Đơn giá: ', FORMAT(oi.unit_price, 0), '₫') "
                    + "WHERE o.is_custom_order = 0 AND (o.variant_summary IS NULL OR o.variant_summary = 'Phân loại: Tiêu chuẩn · ×1')";
            try { st.executeUpdate(syncItemsSql); } catch (SQLException ignored) {}

        } catch (Exception e) {
            e.printStackTrace();
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

    public List<CustomOrder> getOrdersByUserId(int userId) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        String sql = "SELECT o.*, s.shop_name, "
                + "COALESCE((SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.id LIMIT 1), p.name) AS resolved_product_name "
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
                    o.setProductName(rs.getString("resolved_product_name"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomOrder> getPendingReviewOrdersByUser(int userId) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        String sql = "SELECT o.*, s.shop_name, "
                + "COALESCE((SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.id LIMIT 1), p.name) AS resolved_product_name "
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
                    o.setProductName(rs.getString("resolved_product_name"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countOrdersByStatus(String status, boolean onlyCustom) {
        return countOrdersByShopAndStatus(null, status, onlyCustom);
    }

    public int countOrdersByShopAndStatus(Integer shopId, String status, boolean onlyCustom) {
        ensureDatabaseNormalized();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM orders WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (shopId != null && shopId > 0) {
            sql.append("AND shop_id = ? ");
            params.add(shopId);
        }
        if (status != null && !"ALL".equals(status)) {
            sql.append("AND order_status = ? ");
            params.add(status);
        }
        if (onlyCustom) {
            sql.append("AND is_custom_order = 1 ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
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
        String sql = "SELECT * FROM custom_services WHERE shop_id = ? ORDER BY id DESC";
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

    // Gói dịch vụ mới do Seller tạo sẽ có status = 'PENDING' để gửi sang Admin kiểm duyệt
    public boolean addServicePackage(int shopId, String name, long price, String duration, String desc, boolean popular) {
        String sql = "INSERT INTO custom_services (shop_id, service_name, price, duration_text, description, is_popular, sold_month, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0, 'PENDING')";
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

    // Nếu gói dịch vụ đang bị REJECTED hoặc NEEDS_EDIT, khi Seller sửa sẽ chuyển về PENDING để Admin duyệt lại
    public boolean updateServicePackage(int id, String name, long price, String duration, String desc, boolean popular) {
        String sql = "UPDATE custom_services SET service_name = ?, price = ?, duration_text = ?, description = ?, is_popular = ?, "
                + "status = CASE WHEN status IN ('REJECTED', 'NEEDS_EDIT') THEN 'PENDING' ELSE status END "
                + "WHERE id = ?";
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

    // Chỉ cho phép bật/tắt khi gói dịch vụ đã được Admin duyệt (ACTIVE hoặc INACTIVE)
    public boolean toggleServiceStatus(int id) {
        String sql = "UPDATE custom_services SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END "
                + "WHERE id = ? AND status IN ('ACTIVE', 'INACTIVE')";
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

    // ===================== QUẢN LÝ & ĐĂNG SẢN PHẨM CỦA SELLER (GỬI ADMIN DUYỆT) =====================

    public List<SellerProductItem> getSellerProductsByShop(int shopId, String statusFilter) {
        List<SellerProductItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, c.name AS category_name, "
                        + "(SELECT COUNT(*) FROM product_specs ps WHERE ps.product_id = p.id) AS spec_cnt, "
                        + "(SELECT COUNT(*) FROM product_compatibilities pc WHERE pc.product_id = p.id) AS compat_cnt "
                        + "FROM products p "
                        + "LEFT JOIN categories c ON p.category_id = c.id "
                        + "WHERE p.shop_id = ? "
        );
        if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND p.status = ? ");
        }
        sql.append("ORDER BY p.id DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, shopId);
            if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SellerProductItem item = mapSellerProduct(rs);
                    item.setSpecsText(loadSpecsText(conn, item.getId()));
                    item.setCompatText(loadCompatText(conn, item.getId()));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countSellerProductsByStatus(int shopId, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products WHERE shop_id = ? ");
        if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
            sql.append("AND status = ? ");
        }
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, shopId);
            if (statusFilter != null && !statusFilter.isBlank() && !"ALL".equalsIgnoreCase(statusFilter)) {
                ps.setString(2, statusFilter.trim().toUpperCase());
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean saveSellerProduct(int productId, int shopId, int categoryId, String sku, String name, String brand,
                                     long price, long oldPrice, int stock, boolean supportCustom,
                                     String layout, String mountType, String pinType, String switchType, String actuationForce,
                                     String shortDesc, String description, String specsText, String compatText) {
        int discountPercent = 0;
        if (oldPrice > price && oldPrice > 0) {
            discountPercent = (int) Math.round(((oldPrice - price) * 100.0) / oldPrice);
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int targetProductId = productId;
                if (productId <= 0) {
                    String ins = "INSERT INTO products (shop_id, category_id, sku, name, brand, short_desc, description, "
                            + "price, old_price, discount_percent, stock, sold_count, rating_avg, rating_count, badge, "
                            + "support_custom, switch_type, actuation_force, pin_type, layout, mount_type, status) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 5.0, 0, 'Mới', ?, ?, ?, ?, ?, ?, 'PENDING')";
                    try (PreparedStatement ps = conn.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, shopId);
                        ps.setInt(2, categoryId);
                        ps.setString(3, sku.trim());
                        ps.setString(4, name.trim());
                        ps.setString(5, brand.trim());
                        ps.setString(6, shortDesc != null ? shortDesc.trim() : "");
                        ps.setString(7, description != null ? description.trim() : "");
                        ps.setLong(8, price);
                        ps.setLong(9, oldPrice);
                        ps.setInt(10, discountPercent);
                        ps.setInt(11, stock);
                        ps.setInt(12, supportCustom ? 1 : 0);
                        ps.setString(13, emptyToNull(switchType));
                        ps.setString(14, emptyToNull(actuationForce));
                        ps.setString(15, emptyToNull(pinType));
                        ps.setString(16, emptyToNull(layout));
                        ps.setString(17, emptyToNull(mountType));
                        ps.executeUpdate();
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) targetProductId = rs.getInt(1);
                        }
                    }
                } else {
                    String upd = "UPDATE products SET category_id = ?, sku = ?, name = ?, brand = ?, short_desc = ?, "
                            + "description = ?, price = ?, old_price = ?, discount_percent = ?, stock = ?, "
                            + "support_custom = ?, switch_type = ?, actuation_force = ?, pin_type = ?, layout = ?, mount_type = ?, "
                            + "status = 'PENDING' WHERE id = ? AND shop_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(upd)) {
                        ps.setInt(1, categoryId);
                        ps.setString(2, sku.trim());
                        ps.setString(3, name.trim());
                        ps.setString(4, brand.trim());
                        ps.setString(5, shortDesc != null ? shortDesc.trim() : "");
                        ps.setString(6, description != null ? description.trim() : "");
                        ps.setLong(7, price);
                        ps.setLong(8, oldPrice);
                        ps.setInt(9, discountPercent);
                        ps.setInt(10, stock);
                        ps.setInt(11, supportCustom ? 1 : 0);
                        ps.setString(12, emptyToNull(switchType));
                        ps.setString(13, emptyToNull(actuationForce));
                        ps.setString(14, emptyToNull(pinType));
                        ps.setString(15, emptyToNull(layout));
                        ps.setString(16, emptyToNull(mountType));
                        ps.setInt(17, productId);
                        ps.setInt(18, shopId);
                        ps.executeUpdate();
                    }
                }

                if (targetProductId > 0) {
                    replaceProductSpecs(conn, targetProductId, specsText);
                    replaceProductCompatibilities(conn, targetProductId, compatText);
                }

                syncShopAndCategoryActiveCounts(conn);
                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleSellerProductStatus(int productId, int shopId) {
        String sql = "UPDATE products SET status = CASE WHEN status = 'ACTIVE' THEN 'INACTIVE' ELSE 'ACTIVE' END "
                + "WHERE id = ? AND shop_id = ? AND status IN ('ACTIVE', 'INACTIVE')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, shopId);
            boolean ok = ps.executeUpdate() > 0;
            if (ok) syncShopAndCategoryActiveCounts(conn);
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteSellerProduct(int productId, int shopId) {
        try (Connection conn = DBContext.getConnection()) {
            String checkRef = "SELECT (SELECT COUNT(*) FROM order_items WHERE product_id = ?) + "
                    + "(SELECT COUNT(*) FROM orders WHERE product_id = ?) AS cnt";
            int refs = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkRef)) {
                ps.setInt(1, productId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) refs = rs.getInt(1);
                }
            }
            if (refs > 0) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE products SET status = 'INACTIVE' WHERE id = ? AND shop_id = ?")) {
                    ps.setInt(1, productId);
                    ps.setInt(2, shopId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE id = ? AND shop_id = ?")) {
                    ps.setInt(1, productId);
                    ps.setInt(2, shopId);
                    ps.executeUpdate();
                }
            }
            syncShopAndCategoryActiveCounts(conn);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private void replaceProductSpecs(Connection conn, int productId, String specsText) throws SQLException {
        try (PreparedStatement del = conn.prepareStatement("DELETE FROM product_specs WHERE product_id = ?")) {
            del.setInt(1, productId);
            del.executeUpdate();
        }
        if (specsText == null || specsText.isBlank()) return;
        String[] lines = specsText.split("[;\\r\\n]+");
        String ins = "INSERT INTO product_specs (product_id, spec_name, spec_value, display_order) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(ins)) {
            int order = 1;
            for (String line : lines) {
                String trimmed = line.trim();
                if (trimmed.isEmpty()) continue;
                int colon = trimmed.indexOf(':');
                String k = (colon > 0) ? trimmed.substring(0, colon).trim() : ("Thông số " + order);
                String v = (colon > 0) ? trimmed.substring(colon + 1).trim() : trimmed;
                if (!k.isEmpty() && !v.isEmpty()) {
                    ps.setInt(1, productId);
                    ps.setString(2, k);
                    ps.setString(3, v);
                    ps.setInt(4, order++);
                    ps.addBatch();
                }
            }
            ps.executeBatch();
        }
    }

    private void replaceProductCompatibilities(Connection conn, int productId, String compatText) throws SQLException {
        try (PreparedStatement del = conn.prepareStatement("DELETE FROM product_compatibilities WHERE product_id = ?")) {
            del.setInt(1, productId);
            del.executeUpdate();
        }
        if (compatText == null || compatText.isBlank()) return;
        String[] lines = compatText.split("[;\\r\\n]+");
        String ins = "INSERT INTO product_compatibilities (product_id, title, description, is_compatible) VALUES (?, ?, ?, 1)";
        try (PreparedStatement ps = conn.prepareStatement(ins)) {
            for (String line : lines) {
                String trimmed = line.trim();
                if (trimmed.isEmpty()) continue;
                int colon = trimmed.indexOf(':');
                String title = (colon > 0) ? trimmed.substring(0, colon).trim() : "Tương thích hệ thống";
                String desc = (colon > 0) ? trimmed.substring(colon + 1).trim() : trimmed;
                if (!title.isEmpty() && !desc.isEmpty()) {
                    ps.setInt(1, productId);
                    ps.setString(2, title);
                    ps.setString(3, desc);
                    ps.addBatch();
                }
            }
            ps.executeBatch();
        }
    }

    private String loadSpecsText(Connection conn, int productId) {
        StringBuilder sb = new StringBuilder();
        String sql = "SELECT spec_name, spec_value FROM product_specs WHERE product_id = ? ORDER BY display_order ASC, id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (sb.length() > 0) sb.append("; ");
                    sb.append(rs.getString("spec_name")).append(": ").append(rs.getString("spec_value"));
                }
            }
        } catch (SQLException ignored) {}
        return sb.toString();
    }

    private String loadCompatText(Connection conn, int productId) {
        StringBuilder sb = new StringBuilder();
        String sql = "SELECT title, description FROM product_compatibilities WHERE product_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (sb.length() > 0) sb.append("; ");
                    sb.append(rs.getString("title")).append(": ").append(rs.getString("description"));
                }
            }
        } catch (SQLException ignored) {}
        return sb.toString();
    }

    private void syncShopAndCategoryActiveCounts(Connection conn) {
        try (Statement st = conn.createStatement()) {
            st.executeUpdate("UPDATE categories c SET product_count = (SELECT COUNT(*) FROM products p WHERE p.category_id = c.id AND p.status = 'ACTIVE')");
            st.executeUpdate("UPDATE shops s SET product_count = (SELECT COUNT(*) FROM products p WHERE p.shop_id = s.id AND p.status = 'ACTIVE')");
        } catch (SQLException ignored) {}
    }

    private String emptyToNull(String val) {
        return (val == null || val.trim().isEmpty()) ? null : val.trim();
    }

    private SellerProductItem mapSellerProduct(ResultSet rs) throws SQLException {
        SellerProductItem p = new SellerProductItem();
        p.setId(rs.getInt("id"));
        p.setShopId(rs.getInt("shop_id"));
        p.setCategoryId(rs.getInt("category_id"));
        try { p.setCategoryName(rs.getString("category_name")); } catch (SQLException ignored) {}
        p.setSku(rs.getString("sku"));
        p.setName(rs.getString("name"));
        p.setBrand(rs.getString("brand"));
        p.setShortDesc(rs.getString("short_desc"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getLong("price"));
        p.setOldPrice(rs.getLong("old_price"));
        p.setStock(rs.getInt("stock"));
        p.setSoldCount(rs.getInt("sold_count"));
        p.setSupportCustom(rs.getInt("support_custom") == 1);
        p.setSwitchType(rs.getString("switch_type"));
        p.setActuationForce(rs.getString("actuation_force"));
        p.setPinType(rs.getString("pin_type"));
        p.setLayout(rs.getString("layout"));
        p.setMountType(rs.getString("mount_type"));
        p.setStatus(rs.getString("status"));
        try { p.setSpecCount(rs.getInt("spec_cnt")); } catch (SQLException ignored) {}
        try { p.setCompatCount(rs.getInt("compat_cnt")); } catch (SQLException ignored) {}
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    public List<CustomOrder> getOrdersForSeller(String statusFilter, boolean onlyCustom) {
        return getOrdersForSellerByShop(null, statusFilter, onlyCustom);
    }

    public List<CustomOrder> getOrdersForSellerByShop(Integer shopId, String statusFilter, boolean onlyCustom) {
        ensureDatabaseNormalized();
        List<CustomOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, s.shop_name, "
                        + "COALESCE((SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.id LIMIT 1), p.name) AS resolved_product_name "
                        + "FROM orders o "
                        + "LEFT JOIN shops s ON o.shop_id = s.id "
                        + "LEFT JOIN products p ON o.product_id = p.id WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();
        if (shopId != null && shopId > 0) {
            sql.append("AND o.shop_id = ? ");
            params.add(shopId);
        }
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
            sql.append("AND o.order_status = ? ");
            params.add(statusFilter);
        }
        if (onlyCustom) {
            sql.append("AND o.is_custom_order = 1 ");
        }
        sql.append("ORDER BY o.id DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("resolved_product_name"));
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
        String sql = "SELECT o.*, s.shop_name, "
                + "COALESCE((SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.id LIMIT 1), p.name) AS resolved_product_name "
                + "FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id WHERE o.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("resolved_product_name"));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public CustomOrder getOrderByCode(String code) {
        ensureDatabaseNormalized();
        String sql = "SELECT o.*, s.shop_name, "
                + "COALESCE((SELECT oi.product_name FROM order_items oi WHERE oi.order_id = o.id LIMIT 1), p.name) AS resolved_product_name "
                + "FROM orders o "
                + "LEFT JOIN shops s ON o.shop_id = s.id "
                + "LEFT JOIN products p ON o.product_id = p.id WHERE o.order_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomOrder o = mapOrder(rs);
                    o.setShopName(rs.getString("shop_name"));
                    o.setProductName(rs.getString("resolved_product_name"));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Hỗ trợ lập Phiếu Báo Giá & Xác nhận đơn cho cả Đơn Custom lẫn Đơn Mua sẵn / Bán lẻ
    public boolean acceptCustomOrder(int orderId, int committedDays, String shopNote, long extraFee) {
        CustomOrder current = getOrderById(orderId);
        boolean isCustom = (current != null && current.isCustomOrder());
        long oldTotal = (current != null) ? current.getTotalAmount() : 0;
        long newTotal = oldTotal + extraFee;

        String quotationText;
        if (shopNote != null && !shopNote.isBlank()) {
            quotationText = shopNote.trim();
        } else if (extraFee > 0) {
            quotationText = "Phiếu báo giá từ shop: Giá tạm tính ban đầu " + formatVND(oldTotal)
                    + " + Phụ phí điều chỉnh " + formatVND(extraFee)
                    + " = Tổng chốt " + formatVND(newTotal) + ". Cam kết bàn giao trong " + committedDays + " ngày.";
        } else {
            quotationText = "Phiếu báo giá từ shop: Xác nhận mức giá chốt " + formatVND(oldTotal)
                    + " (Không phát sinh phụ phí). Cam kết bàn giao trong " + committedDays + " ngày.";
        }

        String nextStatus = isCustom ? "PROCESSING" : "SHIPPING";
        int nextProgress = isCustom ? 20 : 80;

        String sql = "UPDATE orders SET order_status = ?, progress_percent = ?, committed_days = ?, "
                + "shop_note = ?, custom_fee = custom_fee + ?, total_amount = total_amount + ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nextStatus);
            ps.setInt(2, nextProgress);
            ps.setInt(3, committedDays);
            ps.setString(4, quotationText);
            ps.setLong(5, extraFee);
            ps.setLong(6, extraFee);
            ps.setInt(7, orderId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated && isCustom) {
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

    public boolean rejectCustomOrder(int orderId, String reasonNote) {
        String note = (reasonNote != null && !reasonNote.isBlank())
                ? "Shop từ chối nhận đơn: " + reasonNote.trim()
                : "Shop từ chối nhận đơn do quá tải công suất hoặc hết vật tư.";
        String sql = "UPDATE orders SET order_status = 'CANCELLED', progress_percent = 0, shop_note = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, note);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean rejectCustomOrder(int orderId) {
        return rejectCustomOrder(orderId, null);
    }

    public boolean markOrderShipping(int orderId) {
        String sql = "UPDATE orders SET order_status = 'SHIPPING', progress_percent = 90 WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markOrderCompleted(int orderId) {
        String sql = "UPDATE orders SET order_status = 'COMPLETED', progress_percent = 100 WHERE id = ?";
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
        try { o.setShopNote(rs.getString("shop_note")); } catch (SQLException ignored) {}
        o.setCommittedDays(rs.getInt("committed_days"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }
}