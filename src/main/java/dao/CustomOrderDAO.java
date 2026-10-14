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

    public static String formatVND(long amount) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.getDefault());
        symbols.setGroupingSeparator('.');
        return new DecimalFormat("#,###", symbols).format(amount) + "₫";
    }

    // DTO Gói dịch vụ Custom (Frame 26)
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

    // DTO Đơn hàng & Yêu cầu gia công (Frame 20, 21, 22, 15)
    public static class CustomOrder {
        private int id;
        private String orderCode;
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
        private String orderStatus; // PENDING, PROCESSING, SHIPPING, COMPLETED, CANCELLED
        private int progressPercent;
        private String customerNote;
        private int committedDays;
        private Timestamp createdAt;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public String getOrderCode() { return orderCode; }
        public void setOrderCode(String orderCode) { this.orderCode = orderCode; }
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
            if ("KH-284193".equals(orderCode)) return "Build #B-7742";
            if ("KH-284170".equals(orderCode)) return "Build #B-7738";
            if ("KH-284169".equals(orderCode)) return "Build #B-7737";
            if ("KH-284140".equals(orderCode)) return "Build #B-7731";
            return "Build #B-7750";
        }

        public String getProductSummary() {
            if ("KH-284193".equals(orderCode)) return "Build #B-7742";
            if ("KH-284188".equals(orderCode)) return "Switch Oil King ×2";
            if ("KH-284170".equals(orderCode)) return "Build #B-7738";
            if ("KH-284169".equals(orderCode)) return "Build #B-7737";
            if ("KH-284166".equals(orderCode)) return "Durock V2 ×3";
            if ("KH-284152".equals(orderCode)) return "Keycap GMK Olivia";
            if ("KH-284140".equals(orderCode)) return "Build #B-7731";
            return "Switch HMX Xinhai ×1";
        }
    }

    // DTO Bước tiến độ gia công (Frame 22 & 15)
    public static class ProgressStep {
        private int id;
        private int orderId;
        private int stepNumber;
        private String stepTitle;
        private String stepDesc;
        private String status; // COMPLETED, IN_PROGRESS, PENDING
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

    // Tự động khởi tạo dữ liệu đơn hàng mẫu khớp Figma 20, 21, 22 nếu bảng orders đang trống
    public void ensureSampleOrdersSeeded() {
        String checkSql = "SELECT COUNT(*) FROM orders";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getInt(1) > 0) {
                return;
            }
            String insertOrder = "INSERT INTO orders (order_code, user_id, shop_id, receiver_name, receiver_phone, shipping_address, "
                    + "is_custom_order, subtotal, custom_fee, shipping_fee, discount_amount, total_amount, payment_method, "
                    + "order_status, progress_percent, customer_note, committed_days) VALUES "
                    + "('KH-284193', 1, 2, 'Lê Tùng Dương', '0987 654 321', '128 Nguyễn Văn Cừ, Phường 2, Quận 5, TP. Hồ Chí Minh', 1, 8500000, 750000, 30000, 790000, 8490000, 'VNPAY', 'PROCESSING', 60, 'Lube kỹ phím dài giúp em, ưu tiên âm trầm thocky.', 7),"
                    + "('KH-284188', 1, 2, 'Phạm Vũ', '0912 345 678', 'Quận Cầu Giấy, Hà Nội', 0, 1780000, 0, 0, 0, 1780000, 'MoMo', 'SHIPPING', 100, '', 3),"
                    + "('KH-284170', 1, 2, 'Nguyễn Minh', '0938 111 222', 'Quận Bình Thạnh, TP. Hồ Chí Minh', 1, 5890000, 1250000, 0, 0, 7140000, 'VNPAY', 'PENDING', 0, 'Em muốn tape mod + PE foam nếu shop làm được. Stab thì clip chân với band-aid giúp em. Space không cần lube quá nặng, em thích tiếng hơi thocky. Cảm ơn shop!', 7),"
                    + "('KH-284169', 1, 2, 'Vũ Thành', '0905 888 777', 'Quận 1, TP. Hồ Chí Minh', 1, 4140000, 750000, 0, 0, 4890000, 'ZaloPay', 'PENDING', 0, 'Nhờ shop test kỹ từng socket hotswap trước khi lắp switch.', 6),"
                    + "('KH-284166', 1, 2, 'Trần Hoàng', '0977 222 333', 'Quận Hải Châu, Đà Nẵng', 0, 1260000, 0, 0, 0, 1260000, 'COD', 'COMPLETED', 100, '', 3),"
                    + "('KH-284140', 1, 2, 'Bùi Khánh', '0944 666 111', 'Quận 7, TP. Hồ Chí Minh', 1, 5670000, 750000, 0, 0, 6420000, 'VNPAY', 'COMPLETED', 100, '', 7)";

            try (PreparedStatement psIns = conn.prepareStatement(insertOrder)) {
                psIns.executeUpdate();
            }

            // Tạo sẵn 5 công đoạn cho đơn #KH-284193 (Đang ở bước 4 - 60% chuẩn Frame 22 & 15)
            CustomOrder ord193 = getOrderByCode("KH-284193");
            if (ord193 != null) {
                seedProgressStepsForOrder193(conn, ord193.getId());
            }
            // Tạo sẵn 5 công đoạn chờ cho đơn #KH-284170 và #KH-284169
            CustomOrder ord170 = getOrderByCode("KH-284170");
            if (ord170 != null) {
                createInitialFiveSteps(conn, ord170.getId());
            }
            CustomOrder ord169 = getOrderByCode("KH-284169");
            if (ord169 != null) {
                createInitialFiveSteps(conn, ord169.getId());
            }
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

    // --- CHỨC NĂNG ĐẶC TRƯNG 1: QUẢN LÝ DỊCH VỤ CUSTOM (FRAME 26) ---
    public List<ServicePackage> getAllServicesByShop(int shopId) {
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

    // --- CHỨC NĂNG ĐẶC TRƯNG 2: TIẾP NHẬN YÊU CẦU GIA CÔNG (FRAME 20 & 21) ---
    public List<CustomOrder> getOrdersForSeller(String statusFilter, boolean onlyCustom) {
        ensureSampleOrdersSeeded();
        List<CustomOrder> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM orders WHERE 1=1 ");
        if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
            sql.append("AND order_status = ? ");
        }
        if (onlyCustom) {
            sql.append("AND is_custom_order = 1 ");
        }
        sql.append("ORDER BY id ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.isEmpty() && !"ALL".equals(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CustomOrder getOrderById(int id) {
        ensureSampleOrdersSeeded();
        String sql = "SELECT * FROM orders WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapOrder(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public CustomOrder getOrderByCode(String code) {
        String sql = "SELECT * FROM orders WHERE order_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapOrder(rs);
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

    // --- CHỨC NĂNG ĐẶC TRƯNG 3: CẬP NHẬT TIẾN ĐỘ GIA CÔNG (FRAME 22 & 15) ---
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

                // Kích hoạt bước tiếp theo sang IN_PROGRESS
                if (stepNumber < 5) {
                    String nextSql = "UPDATE order_progress SET status = 'IN_PROGRESS' "
                            + "WHERE order_id = ? AND step_number = ? AND status = 'PENDING'";
                    try (PreparedStatement psNext = conn.prepareStatement(nextSql)) {
                        psNext.setInt(1, orderId);
                        psNext.setInt(2, stepNumber + 1);
                        psNext.executeUpdate();
                    }
                }

                // Tính lại phần trăm tiến độ (mỗi bước = 20%)
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
                // Chỉ lưu nháp ghi chú công đoạn
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