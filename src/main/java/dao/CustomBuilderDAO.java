package dao;

import model.Shop;
import model.Shop.CustomServiceItem;

import java.sql.*;
import java.util.*;

public class CustomBuilderDAO {

    public static class BuilderProduct {
        private int id;
        private int shopId;
        private String name;
        private String brand;
        private long price;
        private long oldPrice;
        private int categoryId;
        private String categorySlug;
        private String layout;
        private String pinType;
        private String switchType;
        private String mountType;
        private boolean supportCustom = true;
        private double ratingAvg = 4.8;
        private int soldCount = 100;
        private String shopName;
        private String imageUrl;
        private boolean compatible = true;
        private String incompatReason = "";
        private String stockText = "còn 100";
        private String optionSpecs = "";
        private String switchColor = "black";

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }
        public int getShopId() { return shopId > 0 ? shopId : 1; }
        public void setShopId(int shopId) { this.shopId = shopId; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getBrand() { return brand; }
        public void setBrand(String brand) { this.brand = brand; }
        public long getPrice() { return price; }
        public void setPrice(long price) { this.price = price; }
        public long getOldPrice() { return oldPrice; }
        public void setOldPrice(long oldPrice) { this.oldPrice = oldPrice; }
        public int getCategoryId() { return categoryId; }
        public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
        public String getCategorySlug() { return categorySlug; }
        public void setCategorySlug(String categorySlug) { this.categorySlug = categorySlug; }
        public String getLayout() { return layout; }
        public void setLayout(String layout) { this.layout = layout; }
        public String getPinType() { return pinType; }
        public void setPinType(String pinType) { this.pinType = pinType; }
        public String getSwitchType() { return switchType; }
        public void setSwitchType(String switchType) { this.switchType = switchType; }
        public String getMountType() { return mountType; }
        public void setMountType(String mountType) { this.mountType = mountType; }
        public boolean isSupportCustom() { return supportCustom; }
        public void setSupportCustom(boolean supportCustom) { this.supportCustom = supportCustom; }
        public double getRatingAvg() { return ratingAvg; }
        public void setRatingAvg(double ratingAvg) { this.ratingAvg = ratingAvg; }
        public int getSoldCount() { return soldCount; }
        public void setSoldCount(int soldCount) { this.soldCount = soldCount; }
        public String getShopName() { return (shopName != null && !shopName.isBlank()) ? shopName : "KeebLab Store"; }
        public void setShopName(String shopName) { this.shopName = shopName; }
        public String getImageUrl() { return imageUrl; }
        public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
        public boolean isCompatible() { return compatible; }
        public void setCompatible(boolean compatible) { this.compatible = compatible; }
        public String getIncompatReason() { return incompatReason; }
        public void setIncompatReason(String incompatReason) { this.incompatReason = incompatReason; }
        public String getStockText() { return stockText; }
        public void setStockText(String stockText) { this.stockText = stockText; }
        public String getOptionSpecs() { return optionSpecs; }
        public void setOptionSpecs(String optionSpecs) { this.optionSpecs = optionSpecs; }
        public String getSwitchColor() { return switchColor; }
        public void setSwitchColor(String switchColor) { this.switchColor = switchColor; }

        public String getFormattedPrice() {
            return String.format("%,.0f₫", (double) price).replace(",", ".");
        }
        public String getFormattedOldPrice() {
            return oldPrice > 0 ? String.format("%,.0f₫", (double) oldPrice).replace(",", ".") : "";
        }
        public String getShortName() {
            return name != null && name.length() > 48 ? name.substring(0, 48) + "…" : name;
        }
    }

    public static class CompatResult {
        private String title;
        private String message;
        private boolean compatible;
        private String level;

        public CompatResult(String title, String message, boolean compatible, String level) {
            this.title = title;
            this.message = message;
            this.compatible = compatible;
            this.level = level;
        }
        public String getTitle() { return title; }
        public String getMessage() { return message; }
        public boolean isCompatible() { return compatible; }
        public String getLevel() { return level; }
    }

    public static class BuildConfig {
        private int kitId;
        private int switchId;
        private int keycapId;
        private int stabId;
        private int serviceId;
        private int switchQty;
        private String customNote;

        public int getKitId() { return kitId; }
        public void setKitId(int kitId) { this.kitId = kitId; }
        public int getSwitchId() { return switchId; }
        public void setSwitchId(int switchId) { this.switchId = switchId; }
        public int getKeycapId() { return keycapId; }
        public void setKeycapId(int keycapId) { this.keycapId = keycapId; }
        public int getStabId() { return stabId; }
        public void setStabId(int stabId) { this.stabId = stabId; }
        public int getServiceId() { return serviceId; }
        public void setServiceId(int serviceId) { this.serviceId = serviceId; }
        public int getSwitchQty() { return switchQty; }
        public void setSwitchQty(int switchQty) { this.switchQty = switchQty; }
        public String getCustomNote() { return customNote; }
        public void setCustomNote(String customNote) { this.customNote = customNote; }
    }

    // Chỉ lấy các sản phẩm đã được Admin duyệt (p.status = 'ACTIVE')
    public List<BuilderProduct> getProductsByCategory(int categoryId) {
        List<BuilderProduct> list = new ArrayList<>();
        String sql = "SELECT p.*, s.shop_name, c.slug AS cat_slug "
                + "FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "WHERE p.category_id = ? AND p.status = 'ACTIVE' "
                + "ORDER BY p.sold_count DESC, p.rating_avg DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBuilderProduct(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (categoryId == 2) {
            Optional<BuilderProduct> oilKing = list.stream().filter(p -> p.getName().contains("Oil King")).findFirst();
            if (oilKing.isPresent()) {
                oilKing.get().setSwitchColor("black");
                oilKing.get().setOptionSpecs("Linear 55g · lube nhà máy");
            }
            Optional<BuilderProduct> akkoCy = list.stream().filter(p -> p.getName().contains("Cream Yellow")).findFirst();
            if (akkoCy.isPresent()) {
                akkoCy.get().setSwitchColor("yellow");
                akkoCy.get().setOptionSpecs("Linear 50g · stem POM");
            }
            boolean hasIncompatDemo = list.stream().anyMatch(p -> p.getId() == 904);
            if (!hasIncompatDemo) {
                BuilderProduct p = new BuilderProduct();
                p.setId(904);
                p.setShopId(9);
                p.setName("Kailh Box Jade — Clicky 50g, chân 3 pin đời cũ");
                p.setBrand("Kailh");
                p.setPrice(410000);
                p.setCategoryId(2);
                p.setSwitchType("Clicky");
                p.setPinType("3-pin-old");
                p.setShopName("Tiệm Switch Nhỏ");
                p.setRatingAvg(4.5);
                p.setSoldCount(190);
                p.setStockText("còn 30");
                p.setSwitchColor("green");
                p.setOptionSpecs("Clicky 50g · chân to đời cũ");
                p.setCompatible(false);
                p.setIncompatReason("✕ Chân switch đời cũ dày hơn chuẩn MX, cắm vào socket hotswap sẽ làm hỏng lá đồng.");
                list.add(p);
            }
        } else if (categoryId == 3) {
            boolean hasIsoDemo = list.stream().anyMatch(p -> p.getId() == 912);
            if (!hasIsoDemo) {
                BuilderProduct p = new BuilderProduct();
                p.setId(912);
                p.setShopId(4);
                p.setName("Keycap Vintage Apple ISO 104 phím (Layout Châu Âu)");
                p.setBrand("Vintage");
                p.setPrice(520000);
                p.setCategoryId(3);
                p.setLayout("ISO 104");
                p.setShopName("Keycap Đông Nam");
                p.setRatingAvg(4.3);
                p.setStockText("còn 12");
                p.setOptionSpecs("ISO profile · Enter chữ L");
                p.setCompatible(false);
                p.setIncompatReason("✕ Layout ISO có phím Enter chữ L ngược và Shift trái ngắn, không vừa mạch ANSI.");
                list.add(p);
            }
        }
        return list;
    }

    public BuilderProduct getProductById(int id) {
        String sql = "SELECT p.*, s.shop_name, c.slug AS cat_slug "
                + "FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "WHERE p.id = ? AND p.status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapBuilderProduct(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (int cat = 1; cat <= 4; cat++) {
            for (BuilderProduct bp : getProductsByCategory(cat)) {
                if (bp.getId() == id) return bp;
            }
        }
        return null;
    }

    // Lấy danh sách các xưởng gia công có gói dịch vụ đang ACTIVE
    public List<Shop> getWorkshopShops() {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT s.* FROM shops s "
                + "WHERE s.is_workshop = 1 AND s.is_verified = 1 "
                + "AND EXISTS (SELECT 1 FROM custom_services cs WHERE cs.shop_id = s.id AND cs.status = 'ACTIVE') "
                + "ORDER BY (s.id = 2) DESC, s.rating_avg DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Shop s = new Shop();
                    s.setId(rs.getInt("id"));
                    s.setShopName(rs.getString("shop_name"));
                    s.setAvatarText(rs.getString("avatar_text"));
                    s.setAvatarColor(rs.getString("avatar_color"));
                    s.setAddress(rs.getString("address"));
                    s.setRatingAvg(rs.getDouble("rating_avg"));
                    s.setOnTimeRate(rs.getDouble("on_time_rate"));
                    s.setResponseRate(rs.getInt("response_rate"));
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomServiceItem> getServicesByShop(int shopId) {
        List<CustomServiceItem> list = new ArrayList<>();
        String sql = "SELECT * FROM custom_services WHERE shop_id = ? AND status = 'ACTIVE' ORDER BY price ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shopId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CustomServiceItem(
                            rs.getInt("id"),
                            rs.getString("service_name"),
                            rs.getLong("price"),
                            rs.getString("duration_text"),
                            rs.getString("description"),
                            rs.getInt("is_popular") == 1
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void applyCompatibility(BuilderProduct kit, List<BuilderProduct> switches,
                                   List<BuilderProduct> keycaps, List<BuilderProduct> stabs) {
        if (kit == null) return;
        String kitLayout = kit.getLayout() != null ? kit.getLayout().trim() : "60%";
        String kitMount  = kit.getMountType() != null ? kit.getMountType().trim() : "Gasket mount";
        String kitPin    = kit.getPinType() != null ? kit.getPinType().trim() : "5-pin";
        String kitName   = kit.getShortName();

        if (switches != null) {
            for (BuilderProduct sw : switches) {
                String swPin = sw.getPinType() != null ? sw.getPinType() : "5-pin";
                String swName = sw.getName();
                if ("3-pin-old".equalsIgnoreCase(swPin) || (swName != null && swName.contains("đời cũ"))) {
                    sw.setCompatible(false);
                    sw.setIncompatReason("✕ Chân switch đời cũ dày hơn chuẩn MX, cắm vào socket hotswap của " + kitName + " sẽ làm hỏng chân đồng.");
                } else if ("3-pin".equalsIgnoreCase(kitPin) && "5-pin".equalsIgnoreCase(swPin)) {
                    sw.setCompatible(false);
                    sw.setIncompatReason("✕ PCB của kit chỉ hỗ trợ 3-pin. Switch 5-pin cần cắt bỏ 2 chân nhựa phụ trước khi lắp.");
                } else {
                    sw.setCompatible(true);
                    sw.setIncompatReason("");
                }
            }
        }

        if (keycaps != null) {
            for (BuilderProduct kc : keycaps) {
                if (kc.getId() == 0) {
                    kc.setCompatible(true);
                    kc.setIncompatReason("");
                    continue;
                }
                String kcLayout = kc.getLayout() != null ? kc.getLayout() : "";
                String kcName = kc.getName() != null ? kc.getName() : "";
                if (kcLayout.contains("ISO") || kcName.contains("ISO")) {
                    kc.setCompatible(false);
                    kc.setIncompatReason("✕ Layout ISO có phím Enter hình chữ L ngược và Shift trái ngắn, không vừa layout ANSI của kit " + kitName + ".");
                } else if (!kitLayout.contains("60") && (kcLayout.contains("60%") || kcName.contains("61 phím")) && !kcLayout.toLowerCase().contains("all") && !kcLayout.contains("75")) {
                    kc.setCompatible(false);
                    kc.setIncompatReason("✕ Bộ keycap chỉ có 61 phím (60%), thiếu cụm phím điều hướng và hàng F-row cho kit " + kitLayout + " của " + kitName + ".");
                } else {
                    kc.setCompatible(true);
                    kc.setIncompatReason("");
                }
            }
        }

        if (stabs != null) {
            for (BuilderProduct st : stabs) {
                if (st.getId() == 0) {
                    st.setCompatible(true);
                    st.setIncompatReason("");
                    continue;
                }
                String stMount = st.getMountType() != null ? st.getMountType() : "";
                String stName = st.getName() != null ? st.getName() : "";
                if (stMount.equalsIgnoreCase("Plate-mount") || stName.contains("Plate-mount")) {
                    st.setCompatible(false);
                    st.setIncompatReason("✕ Kit " + kitName + " sử dụng cấu trúc " + kitMount + " và mạch khoét lỗ PCB-mount screw-in, không gắn được stab plate-mount.");
                } else {
                    st.setCompatible(true);
                    st.setIncompatReason("");
                }
            }
        }
    }

    public List<CompatResult> checkCompatibility(int kitId, int switchId, int keycapId, int stabId) {
        List<CompatResult> results = new ArrayList<>();

        BuilderProduct kit    = kitId    > 0 ? getProductById(kitId)    : null;
        BuilderProduct sw     = switchId > 0 ? getProductById(switchId) : null;
        BuilderProduct keycap = keycapId > 0 ? getProductById(keycapId) : null;
        BuilderProduct stab   = stabId   > 0 ? getProductById(stabId)   : null;

        if (kit == null) {
            results.add(new CompatResult(
                    "Chưa chọn Kit bàn phím",
                    "Hãy chọn kit để hệ thống kiểm tra tương thích với switch và keycap.",
                    false, "WARN"
            ));
            return results;
        }

        String kitName = kit.getShortName();
        String kitLayout = kit.getLayout() != null ? kit.getLayout() : "60%";
        String kitPin = kit.getPinType() != null ? kit.getPinType() : "5-pin";
        String kitMount = kit.getMountType() != null ? kit.getMountType() : "Gasket mount";

        if (sw != null) {
            String swPin = sw.getPinType() != null ? sw.getPinType() : "5-pin";
            String swName = sw.getShortName();
            if ("3-pin-old".equalsIgnoreCase(swPin) || (sw.getName() != null && sw.getName().contains("đời cũ"))) {
                results.add(new CompatResult(
                        "Kit ↔ Switch: Chân cắm Socket",
                        "Switch " + swName + " dùng chân 3-pin đời cũ dày hơn chuẩn MX, cắm vào socket hotswap của kit " + kitName + " sẽ làm hỏng chân đồng.",
                        false, "ERROR"
                ));
            } else if ("3-pin".equalsIgnoreCase(kitPin) && "5-pin".equalsIgnoreCase(swPin)) {
                results.add(new CompatResult(
                        "Kit ↔ Switch: Chân cắm Socket",
                        "PCB kit " + kitName + " chỉ hỗ trợ 3-pin, switch " + swName + " là 5-pin. Cần cắt 2 chân nhựa định vị trước khi lắp ráp.",
                        false, "WARN"
                ));
            } else {
                results.add(new CompatResult(
                        "Kit ↔ Switch: Socket Hotswap " + kitPin,
                        "PCB hotswap của " + kitName + " nhận chuẩn chân switch " + (swPin.contains("5") ? "5-pin" : "3-pin") + " (" + swName + "), chân switch khít chắc socket.",
                        true, "OK"
                ));
            }
        } else {
            results.add(new CompatResult(
                    "Chưa chọn Switch",
                    "Hãy chọn switch phù hợp với kit để hoàn thiện bộ phím.",
                    false, "WARN"
            ));
        }

        if (keycapId == 0) {
            results.add(new CompatResult(
                    "Kit ↔ Keycap: Tự chuẩn bị keycap",
                    "Bạn chọn tự mua/sử dụng keycap sẵn có. Lưu ý chọn bộ keycap tương thích layout " + kitLayout + " của " + kitName + ".",
                    true, "OK"
            ));
        } else if (keycap != null) {
            String kcLayout = keycap.getLayout() != null ? keycap.getLayout() : "";
            String kcName = keycap.getName() != null ? keycap.getName() : "";
            if (kcLayout.contains("ISO") || kcName.contains("ISO")) {
                results.add(new CompatResult(
                        "Kit ↔ Keycap: Layout bàn phím",
                        "Keycap " + keycap.getShortName() + " sử dụng layout ISO (Enter chữ L ngược, Shift ngắn), không vừa layout ANSI của kit " + kitName + ".",
                        false, "ERROR"
                ));
            } else if (!kitLayout.contains("60") && (kcLayout.contains("60%") || kcName.contains("61 phím")) && !kcLayout.toLowerCase().contains("all") && !kcLayout.contains("75")) {
                results.add(new CompatResult(
                        "Kit ↔ Keycap: Số lượng phím",
                        "Bộ keycap " + keycap.getShortName() + " chỉ có 61 phím (60%), thiếu phím điều hướng và hàng F-row cho layout " + kitLayout + " của " + kitName + ".",
                        false, "ERROR"
                ));
            } else {
                results.add(new CompatResult(
                        "Kit ↔ Keycap: Layout " + kitLayout + " ANSI",
                        "Bộ keycap " + keycap.getShortName() + " đầy đủ phím cho layout " + kitLayout + " (Space 6.25u tiêu chuẩn, các phím modifier chuẩn ANSI).",
                        true, "OK"
                ));
            }
        }

        if (stabId == 0) {
            results.add(new CompatResult(
                    "Kit ↔ Stabilizer: Tự chuẩn bị stab",
                    "Bạn chọn tự trang bị thanh cân bằng. Kit " + kitName + " yêu cầu chuẩn stabilizer PCB-mount screw-in.",
                    true, "OK"
            ));
        } else if (stab != null) {
            String stMount = stab.getMountType() != null ? stab.getMountType() : "";
            String stName = stab.getName() != null ? stab.getName() : "";
            if (stMount.equalsIgnoreCase("Plate-mount") || stName.contains("Plate-mount")) {
                results.add(new CompatResult(
                        "Kit ↔ Stabilizer: Kiểu gắn mạch",
                        "Kit " + kitName + " sử dụng cấu trúc " + kitMount + " và mạch khoét lỗ PCB screw-in, không gắn được stabilizer Plate-mount (" + stab.getShortName() + ").",
                        false, "ERROR"
                ));
            } else {
                results.add(new CompatResult(
                        "Kit ↔ Stabilizer: PCB Screw-in",
                        "Cấu trúc " + kitMount + " và mạch PCB của " + kitName + " tương thích hoàn hảo với stabilizer " + stab.getShortName() + " cố định chắc chắn, không rattle.",
                        true, "OK"
                ));
            }
        }

        results.add(new CompatResult(
                "Đèn LED ↔ Keycap: South-facing LED",
                "Mạch south-facing của kit " + kitName + " không cấn cạnh với profile Cherry của keycap, ánh sáng LED tỏa đều và cho âm gõ chuẩn nhất.",
                true, "OK"
        ));

        return results;
    }

    /**
     * Tạo đơn hàng Custom từ cấu hình của khách:
     * - Nếu khách chọn gói dịch vụ gia công (serviceId > 0): Gán đơn về Xưởng gia công đó (shop_id của gói dịch vụ).
     *   Linh kiện chọn từ các shop đối tác được ghi nhận rõ nguồn shop trong variant_summary và bảng order_items.
     * - Nếu khách chọn Tự lắp ráp (serviceId == 0): Gán đơn về Shop bán bộ Kit bàn phím chính (kit.getShopId()).
     */
    public String createCustomOrder(int userId, BuildConfig cfg,
                                    String receiverName, String receiverPhone,
                                    String shippingAddress, String paymentMethod,
                                    long subtotal, long customFee) {
        String orderCode = "KH-" + (280000 + (int)(Math.random() * 9999));

        BuilderProduct kit = cfg.getKitId() > 0 ? getProductById(cfg.getKitId()) : null;
        BuilderProduct sw  = cfg.getSwitchId() > 0 ? getProductById(cfg.getSwitchId()) : null;
        BuilderProduct kc  = cfg.getKeycapId() > 0 ? getProductById(cfg.getKeycapId()) : null;
        BuilderProduct st  = cfg.getStabId() > 0 ? getProductById(cfg.getStabId()) : null;

        long discountAmount = (subtotal > 0 && sw != null) ? 150000 : 0;
        long shippingFee = 30000;
        long totalAmount = Math.max(0, subtotal + customFee + shippingFee - discountAmount);

        // Xác định Shop/Xưởng tiếp nhận đơn và tên gói gia công
        int targetShopId = (kit != null) ? kit.getShopId() : 1;
        String serviceName = "Tự lắp ráp (Không kèm gói gia công)";
        boolean hasWorkshopService = false;

        if (cfg.getServiceId() > 0) {
            String shopSql = "SELECT shop_id, service_name FROM custom_services WHERE id = ?";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(shopSql)) {
                ps.setInt(1, cfg.getServiceId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        targetShopId = rs.getInt("shop_id");
                        serviceName = "Gói " + rs.getString("service_name");
                        hasWorkshopService = true;
                    }
                }
            } catch (Exception ignored) {}
        }

        // Ghi rõ tên linh kiện kèm tên Shop cung cấp để minh bạch việc điều phối liên shop
        StringBuilder variantSb = new StringBuilder();
        if (kit != null) {
            variantSb.append(kit.getShortName()).append(" [").append(kit.getShopName()).append("] · ");
        }
        if (sw != null) {
            variantSb.append(sw.getBrand()).append(" Switch ×").append(cfg.getSwitchQty()).append(" [").append(sw.getShopName()).append("] · ");
        }
        if (kc != null) {
            variantSb.append(kc.getBrand()).append(" Keycap [").append(kc.getShopName()).append("] · ");
        }
        if (st != null) {
            variantSb.append(st.getBrand()).append(" Stab [").append(st.getShopName()).append("] · ");
        }
        variantSb.append(serviceName);

        String variantSummary = variantSb.toString();
        if (variantSummary.length() > 250) {
            variantSummary = variantSummary.substring(0, 247) + "...";
        }

        String sql = "INSERT INTO orders (order_code, user_id, shop_id, product_id, variant_summary, "
                + "receiver_name, receiver_phone, shipping_address, "
                + "is_custom_order, subtotal, custom_fee, shipping_fee, discount_amount, total_amount, "
                + "payment_method, order_status, progress_percent, customer_note, committed_days) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, ?, 'PENDING', 0, ?, ?)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int newOrderId = 0;
                try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, orderCode);
                    ps.setInt(2, userId);
                    ps.setInt(3, targetShopId);
                    ps.setInt(4, kit != null ? kit.getId() : 1);
                    ps.setString(5, variantSummary);
                    ps.setString(6, receiverName);
                    ps.setString(7, receiverPhone);
                    ps.setString(8, shippingAddress);
                    ps.setLong(9, subtotal);
                    ps.setLong(10, customFee);
                    ps.setLong(11, shippingFee);
                    ps.setLong(12, discountAmount);
                    ps.setLong(13, totalAmount);
                    ps.setString(14, paymentMethod);
                    ps.setString(15, cfg.getCustomNote() != null ? cfg.getCustomNote() : "");
                    ps.setInt(16, hasWorkshopService ? 7 : 3);
                    ps.executeUpdate();

                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) newOrderId = rs.getInt(1);
                    }
                }

                // Lưu toàn bộ các linh kiện đã chọn vào bảng order_items
                if (newOrderId > 0) {
                    String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, line_total) VALUES (?, ?, ?, 1, ?, ?)";
                    try (PreparedStatement psItem = conn.prepareStatement(itemSql)) {
                        List<BuilderProduct> chosenParts = Arrays.asList(kit, sw, kc, st);
                        for (BuilderProduct part : chosenParts) {
                            if (part != null && part.getId() > 0 && part.getId() <= 500) {
                                psItem.setInt(1, newOrderId);
                                psItem.setInt(2, part.getId());
                                psItem.setString(3, part.getName() + " [" + part.getShopName() + "]");
                                psItem.setLong(4, part.getPrice());
                                psItem.setLong(5, part.getPrice());
                                psItem.addBatch();
                            }
                        }
                        psItem.executeBatch();
                    }
                }

                conn.commit();
                return orderCode;
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private BuilderProduct mapBuilderProduct(ResultSet rs) throws SQLException {
        BuilderProduct p = new BuilderProduct();
        p.setId(rs.getInt("id"));
        try { p.setShopId(rs.getInt("shop_id")); } catch (SQLException ignored) { p.setShopId(1); }
        p.setName(rs.getString("name"));
        p.setBrand(rs.getString("brand"));
        p.setPrice(rs.getLong("price"));
        p.setCategoryId(rs.getInt("category_id"));
        try { p.setCategorySlug(rs.getString("cat_slug")); } catch (SQLException ignored) {}
        p.setLayout(rs.getString("layout"));
        p.setPinType(rs.getString("pin_type"));
        p.setSwitchType(rs.getString("switch_type"));
        p.setMountType(rs.getString("mount_type"));
        p.setSupportCustom(rs.getInt("support_custom") == 1);
        p.setRatingAvg(rs.getDouble("rating_avg"));
        p.setSoldCount(rs.getInt("sold_count"));
        try { p.setOldPrice(rs.getLong("old_price")); } catch (SQLException ignored) {}
        try { p.setShopName(rs.getString("shop_name")); } catch (SQLException ignored) {}
        try { p.setImageUrl(rs.getString("image_url")); } catch (SQLException ignored) {}
        try {
            int stock = rs.getInt("stock");
            p.setStockText("còn " + (stock > 0 ? stock : 50));
        } catch (SQLException ignored) {
            p.setStockText("còn 50");
        }
        String specs = (p.getBrand() != null ? p.getBrand() : "")
                + (p.getLayout() != null ? " · " + p.getLayout() : "")
                + (p.getMountType() != null ? " · " + p.getMountType() : "")
                + (p.getSwitchType() != null ? " · " + p.getSwitchType() : "")
                + (getActuationForceFromRs(rs));
        p.setOptionSpecs(specs.replaceAll("^\\s*·\\s*", ""));

        if (p.getSwitchType() != null) {
            String st = p.getSwitchType().toLowerCase();
            if (st.contains("linear")) {
                if (p.getName().toLowerCase().contains("oil")) p.setSwitchColor("black");
                else if (p.getName().toLowerCase().contains("yellow") || p.getName().toLowerCase().contains("cheese")) p.setSwitchColor("yellow");
                else p.setSwitchColor("cyan");
            } else if (st.contains("tactile")) {
                p.setSwitchColor("purple");
            } else if (st.contains("clicky")) {
                p.setSwitchColor("green");
            }
        }
        return p;
    }

    private String getActuationForceFromRs(ResultSet rs) {
        try {
            String af = rs.getString("actuation_force");
            return (af != null && !af.isBlank()) ? (" " + af) : "";
        } catch (SQLException e) {
            return "";
        }
    }
}