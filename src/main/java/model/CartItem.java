package model;

import java.math.BigDecimal;

public class CartItem {

    private Product product;
    private int quantity;
    private long extraPrice;
    private String variantLabel = "";
    public CartItem() {
    }

    public CartItem(Product product, int quantity) {
        this(product, quantity, 0, "");
    }

    public CartItem(Product product, int quantity, long extraPrice, String variantLabel) {
        this.product = product;
        this.extraPrice = extraPrice;
        this.variantLabel = variantLabel == null ? "" : variantLabel;
        setQuantity(quantity);
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = Math.max(1, Math.min(quantity, 99));
    }

    public long getExtraPrice() {
        return extraPrice;
    }

    public void setExtraPrice(long extraPrice) {
        this.extraPrice = extraPrice;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel == null ? "" : variantLabel;
    }

    /** Đơn giá thực tế = giá gốc + phụ phí tuỳ chọn. */
    public long getUnitPrice() {
        if (product == null) return 0;
        return product.getPrice() + extraPrice;
    }

    public String getKey() {
        return makeKey(product == null ? 0 : product.getId(), variantLabel, extraPrice);
    }

    public static String makeKey(int productId, String variantLabel) {
        return makeKey(productId, variantLabel, 0);
    }

    public static String makeKey(int productId, String variantLabel, long extraPrice) {
        String base = productId + "|" + (variantLabel == null ? "" : variantLabel);
        return extraPrice == 0 ? base : base + "|extra=" + extraPrice;
    }

    public BigDecimal getLineTotal() {
        if (product == null) return BigDecimal.ZERO;
        return BigDecimal.valueOf(getUnitPrice()).multiply(BigDecimal.valueOf(quantity));
    }
}