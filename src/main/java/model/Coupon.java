package model;

import java.math.BigDecimal;
import java.sql.Date;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

public class Coupon {
    private int id;
    private String code;
    private String description;
    private String discountType; // "PERCENT" hoặc "FIXED"
    private BigDecimal discountValue;
    private BigDecimal maxDiscount;
    private BigDecimal minOrderAmount;
    private int usageLimit;
    private int usedCount;
    private Date startDate;
    private Date endDate;
    private boolean isActive;

    public Coupon() {}

    public Coupon(int id, String code, String description, String discountType,
                  BigDecimal discountValue, BigDecimal maxDiscount, BigDecimal minOrderAmount) {
        this.id = id;
        this.code = code;
        this.description = description;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxDiscount = maxDiscount;
        this.minOrderAmount = minOrderAmount;
        this.isActive = true;
    }

    public static String formatVND(BigDecimal amount) {
        if (amount == null) return "0₫";
        DecimalFormatSymbols symbols = new DecimalFormatSymbols(Locale.getDefault());
        symbols.setGroupingSeparator('.');
        return new DecimalFormat("#,###", symbols).format(amount) + "₫";
    }

    public String getFormattedDiscount() {
        if ("PERCENT".equalsIgnoreCase(discountType)) {
            return "-" + discountValue.intValue() + "%" +
                    (maxDiscount != null && maxDiscount.compareTo(BigDecimal.ZERO) > 0 ? " (tối đa " + formatVND(maxDiscount) + ")" : "");
        }
        return "-" + formatVND(discountValue);
    }

    public String getFormattedMinOrder() {
        if (minOrderAmount == null || minOrderAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return "Đơn từ 0₫";
        }
        return "Đơn từ " + formatVND(minOrderAmount);
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }

    public BigDecimal getMaxDiscount() { return maxDiscount; }
    public void setMaxDiscount(BigDecimal maxDiscount) { this.maxDiscount = maxDiscount; }

    public BigDecimal getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public int getUsageLimit() { return usageLimit; }
    public void setUsageLimit(int usageLimit) { this.usageLimit = usageLimit; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
