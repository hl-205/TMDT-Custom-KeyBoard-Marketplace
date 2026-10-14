package model;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

public class Product {
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
    private int discountPercent;
    private int stock;
    private int soldCount;
    private double ratingAvg;
    private int ratingCount;
    private String badge;
    private boolean supportCustom;
    private String layout;
    private String mountType;

    // Thông tin Shop đi kèm sản phẩm
    private String shopName;
    private String shopAvatarText;
    private String shopAvatarColor;
    private String shopAddress;
    private boolean shopVerified;
    private double shopRating;
    private int shopFollowers;
    private int shopResponseRate;
    private String shopResponseTime;

    public static String formatVND(long amount) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.getDefault());
        symbols.setGroupingSeparator('.');
        DecimalFormat df = new DecimalFormat("#,###", symbols);
        return df.format(amount) + "₫";
    }

    public String getFormattedPrice() {
        return formatVND(this.price);
    }

    public String getFormattedOldPrice() {
        return oldPrice > 0 ? formatVND(this.oldPrice) : "";
    }

    public String getFormattedSavedAmount() {
        if (oldPrice > price) {
            return formatVND(oldPrice - price);
        }
        return "0₫";
    }

    public String getFormattedSoldCount() {
        if (soldCount >= 1000) {
            return String.format(Locale.US, "%.1fk", soldCount / 1000.0);
        }
        return String.valueOf(soldCount);
    }

    public String getFormattedShopFollowers() {
        if (shopFollowers >= 1000) {
            return String.format(Locale.US, "%.1fk", shopFollowers / 1000.0);
        }
        return String.valueOf(shopFollowers);
    }

    // Các Class con biểu diễn Tuỳ chọn, Thông số, Tương thích, Đánh giá
    public static class ProductOption {
        private int id;
        private String optionGroup;
        private String optionName;
        private long extraPrice;
        private boolean available;

        public ProductOption(int id, String optionGroup, String optionName, long extraPrice, boolean available) {
            this.id = id;
            this.optionGroup = optionGroup;
            this.optionName = optionName;
            this.extraPrice = extraPrice;
            this.available = available;
        }
        public int getId() { return id; }
        public String getOptionGroup() { return optionGroup; }
        public String getOptionName() { return optionName; }
        public long getExtraPrice() { return extraPrice; }
        public boolean isAvailable() { return available; }
    }

    public static class ProductSpec {
        private String specName;
        private String specValue;

        public ProductSpec(String specName, String specValue) {
            this.specName = specName;
            this.specValue = specValue;
        }
        public String getSpecName() { return specName; }
        public String getSpecValue() { return specValue; }
    }

    public static class ProductCompatibility {
        private String title;
        private String description;
        private boolean compatible;

        public ProductCompatibility(String title, String description, boolean compatible) {
            this.title = title;
            this.description = description;
            this.compatible = compatible;
        }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public boolean isCompatible() { return compatible; }
    }

    public static class Review {
        private String reviewerName;
        private String avatarText;
        private int rating;
        private String variantInfo;
        private String comment;
        private int helpfulCount;
        private String reviewDate;

        public Review(String reviewerName, String avatarText, int rating, String variantInfo,
                      String comment, int helpfulCount, String reviewDate) {
            this.reviewerName = reviewerName;
            this.avatarText = avatarText;
            this.rating = rating;
            this.variantInfo = variantInfo;
            this.comment = comment;
            this.helpfulCount = helpfulCount;
            this.reviewDate = reviewDate;
        }
        public String getReviewerName() { return reviewerName; }
        public String getAvatarText() { return avatarText; }
        public int getRating() { return rating; }
        public String getVariantInfo() { return variantInfo; }
        public String getComment() { return comment; }
        public int getHelpfulCount() { return helpfulCount; }
        public String getReviewDate() { return reviewDate; }
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getShopId() { return shopId; }
    public void setShopId(int shopId) { this.shopId = shopId; }
    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getShortDesc() { return shortDesc; }
    public void setShortDesc(String shortDesc) { this.shortDesc = shortDesc; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public long getPrice() { return price; }
    public void setPrice(long price) { this.price = price; }
    public long getOldPrice() { return oldPrice; }
    public void setOldPrice(long oldPrice) { this.oldPrice = oldPrice; }
    public int getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(int discountPercent) { this.discountPercent = discountPercent; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public int getSoldCount() { return soldCount; }
    public void setSoldCount(int soldCount) { this.soldCount = soldCount; }
    public double getRatingAvg() { return ratingAvg; }
    public void setRatingAvg(double ratingAvg) { this.ratingAvg = ratingAvg; }
    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }
    public String getBadge() { return badge; }
    public void setBadge(String badge) { this.badge = badge; }
    public boolean isSupportCustom() { return supportCustom; }
    public void setSupportCustom(boolean supportCustom) { this.supportCustom = supportCustom; }
    public String getLayout() { return layout; }
    public void setLayout(String layout) { this.layout = layout; }
    public String getMountType() { return mountType; }
    public void setMountType(String mountType) { this.mountType = mountType; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public String getShopAvatarText() { return shopAvatarText; }
    public void setShopAvatarText(String shopAvatarText) { this.shopAvatarText = shopAvatarText; }
    public String getShopAvatarColor() { return shopAvatarColor; }
    public void setShopAvatarColor(String shopAvatarColor) { this.shopAvatarColor = shopAvatarColor; }
    public String getShopAddress() { return shopAddress; }
    public void setShopAddress(String shopAddress) { this.shopAddress = shopAddress; }
    public boolean isShopVerified() { return shopVerified; }
    public void setShopVerified(boolean shopVerified) { this.shopVerified = shopVerified; }
    public double getShopRating() { return shopRating; }
    public void setShopRating(double shopRating) { this.shopRating = shopRating; }
    public int getShopFollowers() { return shopFollowers; }
    public void setShopFollowers(int shopFollowers) { this.shopFollowers = shopFollowers; }
    public int getShopResponseRate() { return shopResponseRate; }
    public void setShopResponseRate(int shopResponseRate) { this.shopResponseRate = shopResponseRate; }
    public String getShopResponseTime() { return shopResponseTime; }
    public void setShopResponseTime(String shopResponseTime) { this.shopResponseTime = shopResponseTime; }
}