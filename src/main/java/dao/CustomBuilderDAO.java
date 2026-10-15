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
     * Kiểm tra tổng thể độ tương thích giữa kit, switch và keycap đã chọn.
     * Trả về danh sách CompatResult bao gồm cả OK và cảnh báo.
     */
    public List<CompatResult> checkCompatibility(int kitId, int switchId, int keycapId, int stabId) {
        List<CompatResult> results = new ArrayList<>();

        BuilderProduct kit    = kitId    > 0 ? getProductById(kitId)    : null;
        BuilderProduct sw     = switchId > 0 ? getProductById(switchId) : null;
        BuilderProduct keycap = keycapId > 0 ? getProductById(keycapId) : null;
        BuilderProduct stab   = stabId   > 0 ? getProductById(stabId)   : null;

        // ── Kiểm tra Kit ↔ Switch (pin type) ──────────────────────────
        if (kit != null && sw != null) {
            String kitPin  = kit.getPinType();
            String swPin   = sw.getPinType();
            boolean pinOk  = kitPin == null || swPin == null
                    || kitPin.contains("5-pin") || swPin.contains("3-pin")
                    || kitPin.equalsIgnoreCase(swPin);
            if (pinOk) {
                results.add(new CompatResult(
                        "Kit ↔ Switch: Chân PCB",
                        "PCB hotswap " + (kitPin != null ? kitPin : "đa năng")
                                + " tương thích với switch " + (swPin != null ? swPin : "3/5-pin") + ".",
                        true, "OK"
                ));
            } else {
                results.add(new CompatResult(
                        "Kit ↔ Switch: Chân PCB",
                        "PCB chỉ hỗ trợ " + kitPin + " nhưng switch là " + swPin
                                + ". Cần cắt 2 chân switch trước khi lắp.",
                        false, "WARN"
                ));
            }
        }

        // ── Kiểm tra Kit ↔ Keycap (layout) ────────────────────────────
        if (kit != null && keycap != null) {
            String kitLayout  = kit.getLayout();   // VD: "60%"
            String capLayouts = keycap.getLayout();// VD: "60%, 75%, TKL" hoặc "All layout"
            boolean layoutOk  = capLayouts == null
                    || capLayouts.toLowerCase().contains("all")
                    || kitLayout == null
                    || capLayouts.contains(kitLayout.replace("%", "").trim());
            if (layoutOk) {
                results.add(new CompatResult(
                        "Kit ↔ Keycap: Layout bàn phím",
                        "Keycap " + keycap.getShortName() + " hỗ trợ layout "
                                + (kitLayout != null ? kitLayout : "tiêu chuẩn") + ".",
                        true, "OK"
                ));
            } else {
                results.add(new CompatResult(
                        "Kit ↔ Keycap: Layout bàn phím",
                        "Bộ keycap không đủ phím cho layout " + kitLayout
                                + ". Thiếu phím modifier/hàng dưới — cần mua bổ sung Novelties.",
                        false, "WARN"
                ));
            }
        }

        // ── Kiểm tra Switch type (Linear/Tactile/Clicky) thông tin ────
        if (sw != null) {
            String type = sw.getSwitchType();
            if (type != null) {
                String tip;
                switch (type.toUpperCase()) {
                    case "LINEAR":
                        tip = "Switch Linear phù hợp cho gaming & gõ nhanh, âm thanh mượt."; break;
                    case "TACTILE":
                        tip = "Switch Tactile có bump phản hồi xúc giác, phổ biến cho văn phòng."; break;
                    case "CLICKY":
                        tip = "Switch Clicky phát tiếng click — lưu ý môi trường xung quanh."; break;
                    default:
                        tip = "Loại switch: " + type + ".";
                }
                results.add(new CompatResult(
                        "Loại Switch: " + type,
                        tip,
                        true, "OK"
                ));
            }
        }

        // ── Kiểm tra Stabilizer ↔ Kit (PCB-mount) ─────────────────────
        if (kit != null && stab != null) {
            // Nếu kit là gasket mount thì stab PCB-mount screw-in thường OK
            boolean stabOk = kit.getMountType() != null && kit.getMountType().toLowerCase().contains("gasket");
            results.add(new CompatResult(
                    "Kit ↔ Stabilizer",
                    stabOk
                            ? "Kit " + kit.getMountType() + " tương thích với stabilizer PCB-mount screw-in."
                            : "Kiểm tra kỹ loại PCB (screw-in hay plate-mount) trước khi lắp stabilizer.",
                    stabOk, stabOk ? "OK" : "WARN"
            ));
        }

        // ── Kiểm tra tương thích từ DB (product_compatibilities) cho Kit ──
        if (kit != null) {
            List<ProductCompatibility> dbCompats = getCompatibilitiesFromDB(kit.getId());
            for (ProductCompatibility cp : dbCompats) {
                results.add(new CompatResult(
                        cp.getTitle(),
                        cp.getDescription(),
                        cp.isCompatible(),
                        cp.isCompatible() ? "OK" : "ERROR"
                ));
            }
        }

        // Nếu chưa chọn đủ linh kiện thì thêm gợi ý
        if (kit == null) {
            results.add(new CompatResult(
                    "Chưa chọn Kit bàn phím",
                    "Hãy chọn kit để hệ thống kiểm tra tương thích với switch và keycap.",
                    false, "WARN"
            ));
        }
        if (sw == null) {
            results.add(new CompatResult(
                    "Chưa chọn Switch",
                    "Switch là linh kiện quan trọng nhất ảnh hưởng đến cảm giác và âm thanh.",
                    false, "WARN"
            ));
        }

        return results;
    }

    /** Lấy danh sách tương thích từ bảng product_compatibilities */
    private List<ProductCompatibility> getCompatibilitiesFromDB(int productId) {
        List<ProductCompatibility> list = new ArrayList<>();
        String sql = "SELECT * FROM product_compatibilities WHERE product_id = ? ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ProductCompatibility(
                            rs.getString("title"),
                            rs.getString("description"),
                            rs.getInt("is_compatible") == 1
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ===================== Tạo đơn custom =====================

    /**
     * Tạo đơn hàng custom từ cấu hình build của Customer.
     * @return orderCode nếu thành công, null nếu thất bại
     */
    public String createCustomOrder(int userId, BuildConfig cfg,
                                    String receiverName, String receiverPhone,
                                    String shippingAddress, String paymentMethod,
                                    long subtotal, long customFee) {
        String orderCode = "KH-" + (280000 + (int)(Math.random() * 9999));
        long totalAmount = subtotal + customFee + 30000; // +30k phí ship

        // Tạo variant summary từ các linh kiện đã chọn
        StringBuilder variantSb = new StringBuilder();
        if (cfg.getKitId() > 0) {
            BuilderProduct kit = getProductById(cfg.getKitId());
            if (kit != null) variantSb.append(kit.getShortName()).append(" · ");
        }
        if (cfg.getSwitchId() > 0) {
            BuilderProduct sw = getProductById(cfg.getSwitchId());
            if (sw != null) variantSb.append(sw.getBrand()).append(" Switch ×").append(cfg.getSwitchQty()).append(" · ");
        }
        if (cfg.getKeycapId() > 0) {
            BuilderProduct kc = getProductById(cfg.getKeycapId());
            if (kc != null) variantSb.append(kc.getBrand()).append(" Keycap · ");
        }
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
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderCode);
            ps.setInt(2, userId);
            ps.setInt(3, shopId);
            ps.setInt(4, cfg.getKitId() > 0 ? cfg.getKitId() : 1);
            ps.setString(5, variantSummary);
            ps.setString(6, receiverName);
            ps.setString(7, receiverPhone);
            ps.setString(8, shippingAddress);
            ps.setLong(9, subtotal);
            ps.setLong(10, customFee);
            ps.setLong(11, totalAmount);
            ps.setString(12, paymentMethod);
            ps.setString(13, cfg.getCustomNote() != null ? cfg.getCustomNote() : "");
            int rows = ps.executeUpdate();
            return rows > 0 ? orderCode : null;
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
