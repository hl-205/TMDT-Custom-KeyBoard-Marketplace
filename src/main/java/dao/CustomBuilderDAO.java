package dao;

import model.Product;
import model.Product.ProductCompatibility;
import model.Shop;
import model.Shop.CustomServiceItem;

import java.sql.*;
import java.util.*;

/**
 * DAO cho chức năng Custom Builder (Customer):
 * - Lấy danh sách sản phẩm theo từng nhóm linh kiện (Kit, Switch, Keycap, Stabilizer, ...)
 * - Lấy danh sách gói gia công từ các shop xưởng
 * - Kiểm tra độ tương thích giữa các linh kiện đã chọn
 * - Tạo đơn custom từ cấu hình đã chọn
 */
public class CustomBuilderDAO {

    // ===================== Inner Classes =====================

    /** Đại diện cho 1 linh kiện trong Custom Builder */
    public static class BuilderProduct {
        private int id;
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
        public String getShopName() { return shopName; }
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
        /** Tên rút gọn dùng trong card */
        public String getShortName() {
            return name != null && name.length() > 50 ? name.substring(0, 50) + "…" : name;
        }
    }

    /** Kết quả kiểm tra tương thích giữa 2 linh kiện */
    public static class CompatResult {
        private String title;
        private String message;
        private boolean compatible;
        /** "OK" / "WARN" / "ERROR" */
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

    /** Thông tin cấu hình build của Customer khi gửi form */
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

    // ===================== Methods =====================

    /**
     * Lấy tất cả sản phẩm thuộc 1 category (dùng cho từng bước chọn linh kiện).
     * categoryId: 1=Kit, 2=Switch, 3=Keycap, 4=Stabilizer, 5=Phụ kiện
     */
    public List<BuilderProduct> getProductsByCategory(int categoryId) {
        List<BuilderProduct> list = new ArrayList<>();
        String sql = "SELECT p.*, s.shop_name, c.slug AS cat_slug "
                + "FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "WHERE p.category_id = ? "
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

        // Bổ sung các sản phẩm chuẩn theo thiết kế Figma nếu DB chưa có
        if (categoryId == 1) { // Kits
            boolean hasTofu = list.stream().anyMatch(p -> p.getId() == 1 || p.getName().contains("Tofu60"));
            if (!hasTofu) {
                BuilderProduct tf = new BuilderProduct();
                tf.setId(1);
                tf.setName("Kit Tofu60 2.0 Aluminium — Hotswap, gasket mount, foam sẵn");
                tf.setBrand("KBDfans");
                tf.setPrice(2690000);
                tf.setOldPrice(3280000);
                tf.setCategoryId(1);
                tf.setLayout("60%");
                tf.setPinType("5-pin");
                tf.setMountType("Gasket mount");
                tf.setShopName("KeebLab Store");
                tf.setRatingAvg(4.9);
                tf.setSoldCount(1200);
                tf.setStockText("còn 38");
                tf.setOptionSpecs("Silver · Brass plate");
                list.add(0, tf);
            }
        } else if (categoryId == 2) { // Switches
            // Đảm bảo đủ các switch theo đúng Figma: Gateron Oil King, Akko Cream Yellow, HMX Xinhai, Gateron Ink Black, Boba U4T, Kailh Box Jade
            Set<String> existingNames = new HashSet<>();
            for (BuilderProduct p : list) existingNames.add(p.getName());

            // 1. Gateron Oil King
            Optional<BuilderProduct> oilKing = list.stream().filter(p -> p.getName().contains("Oil King")).findFirst();
            if (oilKing.isPresent()) {
                oilKing.get().setSwitchColor("black");
                oilKing.get().setStockText("còn 120");
                oilKing.get().setShopName("SwitchHouse");
                oilKing.get().setOptionSpecs("Linear 55g · lube nhà máy");
                oilKing.get().setCompatible(true);
            }

            // 2. Akko Cream Yellow
            Optional<BuilderProduct> akkoCy = list.stream().filter(p -> p.getName().contains("Cream Yellow")).findFirst();
            if (akkoCy.isPresent()) {
                akkoCy.get().setSwitchColor("yellow");
                akkoCy.get().setStockText("còn 260");
                akkoCy.get().setShopName("Akko Official");
                akkoCy.get().setOptionSpecs("Linear 50g · stem POM");
                akkoCy.get().setCompatible(true);
            }

            // 3. HMX Xinhai (Linear 52g)
            if (!existingNames.contains("Switch HMX Xinhai — Linear 52g, lube sẵn")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(901);
                p.setName("HMX Xinhai — Linear 52g, lube sẵn");
                p.setBrand("HMX");
                p.setPrice(540000);
                p.setCategoryId(2);
                p.setSwitchType("Linear");
                p.setPinType("5-pin");
                p.setShopName("Tiệm Switch Nhỏ");
                p.setRatingAvg(4.9);
                p.setSoldCount(310);
                p.setStockText("còn 88");
                p.setSwitchColor("cyan");
                p.setOptionSpecs("Linear 52g · lube sẵn");
                p.setCompatible(true);
                list.add(p);
            }

            // 4. Gateron Ink Black V2 (Linear 60g)
            if (!existingNames.contains("Gateron Ink Black V2 — Linear 60g")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(902);
                p.setName("Gateron Ink Black V2 — Linear 60g");
                p.setBrand("Gateron");
                p.setPrice(1150000);
                p.setCategoryId(2);
                p.setSwitchType("Linear");
                p.setPinType("5-pin");
                p.setShopName("SwitchHouse");
                p.setRatingAvg(4.9);
                p.setSoldCount(480);
                p.setStockText("còn 42");
                p.setSwitchColor("smoky");
                p.setOptionSpecs("Linear 60g · vỏ khói");
                p.setCompatible(true);
                list.add(p);
            }

            // 5. Boba U4T Thocky (Tactile 62g)
            if (!existingNames.contains("Boba U4T Thocky — Tactile 62g")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(903);
                p.setName("Boba U4T Thocky — Tactile 62g");
                p.setBrand("Gazzew");
                p.setPrice(980000);
                p.setCategoryId(2);
                p.setSwitchType("Tactile");
                p.setPinType("5-pin");
                p.setShopName("KeebLab Store");
                p.setRatingAvg(4.9);
                p.setSoldCount(740);
                p.setStockText("còn 74");
                p.setSwitchColor("purple");
                p.setOptionSpecs("Tactile 62g · âm trầm thocky");
                p.setCompatible(true);
                list.add(p);
            }

            // 6. Kailh Box Jade (Clicky 50g, chân 3 pin đời cũ - KHÔNG TƯƠNG THÍCH)
            if (!existingNames.contains("Kailh Box Jade — Clicky 50g, chân 3 pin đời cũ")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(904);
                p.setName("Kailh Box Jade — Clicky 50g, chân 3 pin đời cũ");
                p.setBrand("Kailh");
                p.setPrice(410000);
                p.setCategoryId(2);
                p.setSwitchType("Clicky");
                p.setPinType("3-pin-old");
                p.setShopName("Phím Cơ 24h");
                p.setRatingAvg(4.5);
                p.setSoldCount(190);
                p.setStockText("còn 30");
                p.setSwitchColor("green");
                p.setOptionSpecs("Clicky 50g · chân to");
                p.setCompatible(false);
                p.setIncompatReason("✕ Chân switch đời cũ dày hơn chuẩn MX, cắm vào socket hotswap của Tofu60 2.0 sẽ làm hỏng chân đồng.");
                list.add(p);
            }
        } else if (categoryId == 3) { // Keycaps
            // Đảm bảo đủ các keycap theo đúng Figma
            Set<String> existingNames = new HashSet<>();
            for (BuilderProduct p : list) existingNames.add(p.getName());

            Optional<BuilderProduct> gmk = list.stream().filter(p -> p.getName().contains("Olivia")).findFirst();
            if (gmk.isPresent()) {
                gmk.get().setStockText("còn 15");
                gmk.get().setShopName("Keycap Đông Nam");
                gmk.get().setOptionSpecs("Cherry profile · 137 phím");
                gmk.get().setCompatible(true);
            }

            Optional<BuilderProduct> akko = list.stream().filter(p -> p.getName().contains("Black & Pink")).findFirst();
            if (akko.isPresent()) {
                akko.get().setStockText("còn 85");
                akko.get().setShopName("Akko Official");
                akko.get().setOptionSpecs("ASA profile · 158 phím");
                akko.get().setCompatible(true);
            }

            if (!existingNames.contains("Keycap PBT Retro 61 phím OEM profile")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(911);
                p.setName("Keycap PBT Retro White/Grey 61 phím — OEM profile");
                p.setBrand("PBT Retro");
                p.setPrice(350000);
                p.setCategoryId(3);
                p.setLayout("60%");
                p.setShopName("KeebLab Store");
                p.setRatingAvg(4.7);
                p.setStockText("còn 40");
                p.setOptionSpecs("OEM profile · 61 phím");
                p.setCompatible(true);
                list.add(p);
            }

            if (!existingNames.contains("Keycap Vintage Apple ISO 104 phím")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(912);
                p.setName("Keycap Vintage Apple ISO 104 phím (Layout Châu Âu)");
                p.setBrand("Vintage");
                p.setPrice(520000);
                p.setCategoryId(3);
                p.setLayout("ISO 104");
                p.setShopName("Vintage Keeb");
                p.setRatingAvg(4.3);
                p.setStockText("còn 12");
                p.setOptionSpecs("ISO profile · Enter to");
                p.setCompatible(false);
                p.setIncompatReason("✕ Layout ISO có phím Enter hình chữ L ngược và Shift trái ngắn, không vừa layout ANSI của kit Tofu60.");
                list.add(p);
            }
        } else if (categoryId == 4) { // Stabilizers
            Set<String> existingNames = new HashSet<>();
            for (BuilderProduct p : list) existingNames.add(p.getName());

            Optional<BuilderProduct> dr = list.stream().filter(p -> p.getName().contains("Durock V2")).findFirst();
            if (dr.isPresent()) {
                dr.get().setStockText("còn 54");
                dr.get().setShopName("SwitchHouse");
                dr.get().setOptionSpecs("PCB-mount · đã lube");
                dr.get().setCompatible(true);
            }

            if (!existingNames.contains("Stabilizer TX AP PCB-mount v4 — clip sẵn")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(921);
                p.setName("Stabilizer TX AP PCB-mount v4 — clip sẵn");
                p.setBrand("TX Keyboard");
                p.setPrice(490000);
                p.setCategoryId(4);
                p.setMountType("PCB-mount");
                p.setShopName("KeebLab Store");
                p.setRatingAvg(4.9);
                p.setStockText("còn 32");
                p.setOptionSpecs("PCB clip-in v4 · chống rung");
                p.setCompatible(true);
                list.add(p);
            }

            if (!existingNames.contains("Stabilizer Plate-mount Cherry OEM")) {
                BuilderProduct p = new BuilderProduct();
                p.setId(922);
                p.setName("Stabilizer Plate-mount Cherry OEM (Gắn trên Plate)");
                p.setBrand("Cherry");
                p.setPrice(120000);
                p.setCategoryId(4);
                p.setMountType("Plate-mount");
                p.setShopName("OEM Parts");
                p.setRatingAvg(4.2);
                p.setStockText("còn 60");
                p.setOptionSpecs("Plate-mount");
                p.setCompatible(false);
                p.setIncompatReason("✕ Kit Tofu60 2.0 sử dụng cấu trúc Gasket mount và mạch khoét lỗ PCB-mount screw-in, không gắn được stab plate-mount.");
                list.add(p);
            }
        }

        return list;
    }

    /**
     * Lấy sản phẩm theo id (tìm trong DB hoặc trong danh sách demo).
     */
    public BuilderProduct getProductById(int id) {
        String sql = "SELECT p.*, s.shop_name, c.slug AS cat_slug "
                + "FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "WHERE p.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapBuilderProduct(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Tìm trong demo items
        for (int cat = 1; cat <= 4; cat++) {
            for (BuilderProduct bp : getProductsByCategory(cat)) {
                if (bp.getId() == id) return bp;
            }
        }
        return null;
    }

    /**
     * Lấy danh sách shop là xưởng gia công (is_workshop = 1) cùng các gói dịch vụ.
     */
    public List<Shop> getWorkshopShops() {
        List<Shop> list = new ArrayList<>();
        String sql = "SELECT * FROM shops WHERE is_workshop = 1 AND is_verified = 1 ORDER BY rating_avg DESC";
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

    /**
     * Lấy danh sách gói dịch vụ gia công của 1 shop.
     */
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

    // ===================== Kiểm tra tương thích =====================

    /**
     * Áp dụng kiểm tra độ tương thích động cho toàn bộ danh sách Switch, Keycap, Stabilizer
     * dựa theo Kit bàn phím đã chọn.
     */
    public void applyCompatibility(BuilderProduct kit, List<BuilderProduct> switches,
                                   List<BuilderProduct> keycaps, List<BuilderProduct> stabs) {
        if (kit == null) return;
        String kitLayout = kit.getLayout() != null ? kit.getLayout().trim() : "60%";
        String kitMount  = kit.getMountType() != null ? kit.getMountType().trim() : "Gasket mount";
        String kitPin    = kit.getPinType() != null ? kit.getPinType().trim() : "5-pin";
        String kitName   = kit.getShortName();

        // 1. Áp dụng cho Switch
        if (switches != null) {
            for (BuilderProduct sw : switches) {
                String swPin = sw.getPinType() != null ? sw.getPinType() : "5-pin";
                String swName = sw.getName();
                if ("3-pin-old".equalsIgnoreCase(swPin) || (swName != null && swName.contains("Box Jade") && swPin.contains("3-pin"))) {
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

        // 2. Áp dụng cho Keycap
        if (keycaps != null) {
            for (BuilderProduct kc : keycaps) {
                if (kc.getId() == 0) { // Tự mua riêng
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

        // 3. Áp dụng cho Stabilizer
        if (stabs != null) {
            for (BuilderProduct st : stabs) {
                if (st.getId() == 0) { // Tự mua riêng
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

    /**
     * Kiểm tra tổng thể độ tương thích giữa kit, switch, keycap và stabilizer đã chọn.
     * Trả về danh sách CompatResult chuẩn xác theo cấu hình thực tế.
     */
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

        // ── 1. Kiểm tra Kit ↔ Switch (chân cắm Socket) ────────────────
        if (sw != null) {
            String swPin = sw.getPinType() != null ? sw.getPinType() : "5-pin";
            String swName = sw.getShortName();
            if ("3-pin-old".equalsIgnoreCase(swPin) || (sw.getName() != null && sw.getName().contains("Box Jade") && swPin.contains("3-pin"))) {
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

            // Gợi ý đặc tính âm thanh theo Switch Type
            if (sw.getSwitchType() != null) {
                String tip;
                switch (sw.getSwitchType().toUpperCase()) {
                    case "LINEAR":
                        tip = "Switch Linear (" + swName + ") cho cảm giác gõ mượt, phản hồi đều và âm thanh êm tai."; break;
                    case "TACTILE":
                        tip = "Switch Tactile (" + swName + ") có khấc phản hồi xúc giác rõ nét, lý tưởng cho làm việc và lập trình."; break;
                    case "CLICKY":
                        tip = "Switch Clicky (" + swName + ") phát âm thanh click đanh vang, phù hợp không gian riêng tư."; break;
                    default:
                        tip = "Đặc tính switch: " + sw.getSwitchType();
                }
                results.add(new CompatResult(
                        "Đặc tính cảm giác gõ: " + sw.getSwitchType(),
                        tip,
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

        // ── 2. Kiểm tra Kit ↔ Keycap (Layout bàn phím) ────────────────
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

        // ── 3. Kiểm tra Kit ↔ Stabilizer (Kiểu mount) ─────────────────
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

        // ── 4. Đèn LED & Profile Keycap ──────────────────────────────
        results.add(new CompatResult(
                "Đèn LED ↔ Keycap: South-facing LED",
                "Mạch south-facing của kit " + kitName + " không cấn cạnh với profile Cherry của keycap, ánh sáng LED tỏa đều và cho âm gõ chuẩn nhất.",
                true, "OK"
        ));

        return results;
    }

    // ===================== Tạo đơn custom =====================

    /**
     * Tạo đơn hàng custom từ cấu hình build của Customer.
     * Tự động thêm order_items và khởi tạo order_progress để seller và customer có thể theo dõi.
     * @return orderCode nếu thành công, null nếu thất bại
     */
    public String createCustomOrder(int userId, BuildConfig cfg,
                                    String receiverName, String receiverPhone,
                                    String shippingAddress, String paymentMethod,
                                    long subtotal, long customFee) {
        String orderCode = "KH-" + (280000 + (int)(Math.random() * 9999));
        long totalAmount = subtotal + customFee + 30000; // +30k phí ship

        BuilderProduct kit = cfg.getKitId() > 0 ? getProductById(cfg.getKitId()) : null;
        BuilderProduct sw  = cfg.getSwitchId() > 0 ? getProductById(cfg.getSwitchId()) : null;
        BuilderProduct kc  = cfg.getKeycapId() > 0 ? getProductById(cfg.getKeycapId()) : null;
        BuilderProduct st  = cfg.getStabId() > 0 ? getProductById(cfg.getStabId()) : null;

        // Tạo variant summary từ các linh kiện đã chọn
        StringBuilder variantSb = new StringBuilder();
        if (kit != null) variantSb.append(kit.getShortName()).append(" · ");
        if (sw != null) variantSb.append(sw.getBrand()).append(" Switch ×").append(cfg.getSwitchQty()).append(" · ");
        if (kc != null) variantSb.append(kc.getBrand()).append(" Keycap · ");
        if (st != null) variantSb.append(st.getShortName()).append(" · ");
        String variantSummary = variantSb.length() > 3
                ? variantSb.substring(0, variantSb.length() - 3)
                : "Custom Build";

        // Lấy shop_id từ service đã chọn (shop xưởng gia công)
        int shopId = 2; // mặc định SwitchHouse
        if (cfg.getServiceId() > 0) {
            String shopSql = "SELECT shop_id FROM custom_services WHERE id = ?";
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement(shopSql)) {
                ps.setInt(1, cfg.getServiceId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) shopId = rs.getInt("shop_id");
                }
            } catch (Exception ignored) {}
        }

        String sql = "INSERT INTO orders (order_code, user_id, shop_id, product_id, variant_summary, "
                + "receiver_name, receiver_phone, shipping_address, "
                + "is_custom_order, subtotal, custom_fee, shipping_fee, discount_amount, total_amount, "
                + "payment_method, order_status, progress_percent, customer_note, committed_days) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, 30000, 0, ?, ?, 'PENDING', 0, ?, 7)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, orderCode);
            ps.setInt(2, userId);
            ps.setInt(3, shopId);
            ps.setInt(4, kit != null ? kit.getId() : 1);
            ps.setString(5, variantSummary);
            ps.setString(6, receiverName);
            ps.setString(7, receiverPhone);
            ps.setString(8, shippingAddress);
            ps.setLong(9, subtotal);
            ps.setLong(10, customFee);
            ps.setLong(11, totalAmount);
            ps.setString(12, paymentMethod != null ? paymentMethod : "VNPAY");
            ps.setString(13, cfg.getCustomNote() != null ? cfg.getCustomNote() : "");
            int rows = ps.executeUpdate();
            if (rows > 0) {
                int orderId = 0;
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) orderId = gk.getInt(1);
                }
                if (orderId > 0) {
                    // Thêm order_items
                    String itemSql = "INSERT INTO order_items (order_id, product_id, product_name, quantity, unit_price, line_total) VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement itemPs = conn.prepareStatement(itemSql)) {
                        if (kit != null) {
                            itemPs.setInt(1, orderId);
                            itemPs.setInt(2, kit.getId());
                            itemPs.setString(3, kit.getName());
                            itemPs.setInt(4, 1);
                            itemPs.setLong(5, kit.getPrice());
                            itemPs.setLong(6, kit.getPrice());
                            itemPs.executeUpdate();
                        }
                        if (sw != null) {
                            itemPs.setInt(1, orderId);
                            itemPs.setInt(2, sw.getId());
                            itemPs.setString(3, sw.getName());
                            itemPs.setInt(4, cfg.getSwitchQty());
                            itemPs.setLong(5, sw.getPrice());
                            itemPs.setLong(6, sw.getPrice());
                            itemPs.executeUpdate();
                        }
                        if (kc != null) {
                            itemPs.setInt(1, orderId);
                            itemPs.setInt(2, kc.getId());
                            itemPs.setString(3, kc.getName());
                            itemPs.setInt(4, 1);
                            itemPs.setLong(5, kc.getPrice());
                            itemPs.setLong(6, kc.getPrice());
                            itemPs.executeUpdate();
                        }
                        if (st != null) {
                            itemPs.setInt(1, orderId);
                            itemPs.setInt(2, st.getId());
                            itemPs.setString(3, st.getName());
                            itemPs.setInt(4, 1);
                            itemPs.setLong(5, st.getPrice());
                            itemPs.setLong(6, st.getPrice());
                            itemPs.executeUpdate();
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }

                    // Khởi tạo 5 công đoạn order_progress cho đơn custom
                    String progSql = "INSERT INTO order_progress (order_id, step_number, step_title, step_desc, status, updated_time) VALUES (?, ?, ?, ?, 'PENDING', ?)";
                    try (PreparedStatement progPs = conn.prepareStatement(progSql)) {
                        String[][] steps = {
                            {"1", "Rã hàn & kiểm tra PCB", "Đo thông mạch toàn bộ socket hotswap và bóng LED của kit " + (kit != null ? kit.getShortName() : ""), "Chờ xử lý"},
                            {"2", "Lube switch (" + cfg.getSwitchQty() + "/" + cfg.getSwitchQty() + ")", "Lube housing Krytox 205g0 và lò xo GPL 105 cho " + cfg.getSwitchQty() + " switch " + (sw != null ? sw.getBrand() : ""), "Chờ xử lý"},
                            {"3", "Cân stabilizer", "Căn thẳng thanh wire, cân housing và mod stab " + (st != null ? st.getShortName() : ""), "Chờ xử lý"},
                            {"4", "Lắp ráp & test toàn phím", "Lắp switch, keycap, test phím trên VIA và kiểm tra âm thanh gõ", "Chờ xử lý"},
                            {"5", "Đóng gói & bàn giao vận chuyển", "Quay video soundtest gửi khách và đóng thùng chống sốc", "Chờ xử lý"}
                        };
                        for (String[] stp : steps) {
                            progPs.setInt(1, orderId);
                            progPs.setInt(2, Integer.parseInt(stp[0]));
                            progPs.setString(3, stp[1]);
                            progPs.setString(4, stp[2]);
                            progPs.setString(5, stp[3]);
                            progPs.executeUpdate();
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
                return orderCode;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ===================== Helper =====================

    private BuilderProduct mapBuilderProduct(ResultSet rs) throws SQLException {
        BuilderProduct p = new BuilderProduct();
        p.setId(rs.getInt("id"));
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
        if (p.getSwitchType() != null) {
            String st = p.getSwitchType().toLowerCase();
            if (st.contains("linear")) {
                if (p.getName().toLowerCase().contains("oil")) p.setSwitchColor("black");
                else if (p.getName().toLowerCase().contains("yellow")) p.setSwitchColor("yellow");
                else p.setSwitchColor("cyan");
            } else if (st.contains("tactile")) {
                p.setSwitchColor("purple");
            } else if (st.contains("clicky")) {
                p.setSwitchColor("green");
            }
        }
        return p;
    }
}
