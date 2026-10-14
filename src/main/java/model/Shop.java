package model;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

public class Shop {
    private int id;
    private String shopName;
    private String slug;
    private String avatarText;
    private String avatarColor;
    private String description;
    private String address;
    private String workingHours;
    private boolean verified;
    private boolean workshop;
    private double ratingAvg;
    private int ratingCount;
    private int followerCount;
    private int productCount;
    private int responseRate;
    private String responseTime;
    private double onTimeRate;
    private double cancelRate;
    private double returnRate;
    private String joinedDate;

    public static class CustomServiceItem {
        private int id;
        private String serviceName;
        private long price;
        private String durationText;
        private String description;
        private boolean popular;

        public CustomServiceItem(int id, String serviceName, long price, String durationText, String description, boolean popular) {
            this.id = id;
            this.serviceName = serviceName;
            this.price = price;
            this.durationText = durationText;
            this.description = description;
            this.popular = popular;
        }
        public int getId() { return id; }
        public String getServiceName() { return serviceName; }
        public long getPrice() { return price; }
        public String getDurationText() { return durationText; }
        public String getDescription() { return description; }
        public boolean isPopular() { return popular; }

        public String getFormattedPrice() {
            DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.getDefault());
            symbols.setGroupingSeparator('.');
            return new DecimalFormat("#,###", symbols).format(price) + "₫";
        }
    }

    public String getFormattedFollowers() {
        if (followerCount >= 1000) {
            return String.format(Locale.US, "%.1fk", followerCount / 1000.0);
        }
        return String.valueOf(followerCount);
    }

    public String getFormattedRatingCount() {
        if (ratingCount >= 1000) {
            return String.format(Locale.US, "%.1fk", ratingCount / 1000.0);
        }
        return String.valueOf(ratingCount);
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getAvatarText() { return avatarText; }
    public void setAvatarText(String avatarText) { this.avatarText = avatarText; }
    public String getAvatarColor() { return avatarColor; }
    public void setAvatarColor(String avatarColor) { this.avatarColor = avatarColor; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getWorkingHours() { return workingHours; }
    public void setWorkingHours(String workingHours) { this.workingHours = workingHours; }
    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
    public boolean isWorkshop() { return workshop; }
    public void setWorkshop(boolean workshop) { this.workshop = workshop; }
    public double getRatingAvg() { return ratingAvg; }
    public void setRatingAvg(double ratingAvg) { this.ratingAvg = ratingAvg; }
    public int getRatingCount() { return ratingCount; }
    public void setRatingCount(int ratingCount) { this.ratingCount = ratingCount; }
    public int getFollowerCount() { return followerCount; }
    public void setFollowerCount(int followerCount) { this.followerCount = followerCount; }
    public int getProductCount() { return productCount; }
    public void setProductCount(int productCount) { this.productCount = productCount; }
    public int getResponseRate() { return responseRate; }
    public void setResponseRate(int responseRate) { this.responseRate = responseRate; }
    public String getResponseTime() { return responseTime; }
    public void setResponseTime(String responseTime) { this.responseTime = responseTime; }
    public double getOnTimeRate() { return onTimeRate; }
    public void setOnTimeRate(double onTimeRate) { this.onTimeRate = onTimeRate; }
    public double getCancelRate() { return cancelRate; }
    public void setCancelRate(double cancelRate) { this.cancelRate = cancelRate; }
    public double getReturnRate() { return returnRate; }
    public void setReturnRate(double returnRate) { this.returnRate = returnRate; }
    public String getJoinedDate() { return joinedDate; }
    public void setJoinedDate(String joinedDate) { this.joinedDate = joinedDate; }
}