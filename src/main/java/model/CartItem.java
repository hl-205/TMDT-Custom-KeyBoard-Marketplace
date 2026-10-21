package model;

import java.math.BigDecimal;

public class CartItem {

    private Product product;
    private int quantity;

    public CartItem() {
    }

    public CartItem(Product product, int quantity) {
        this.product = product;
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

    public BigDecimal getLineTotal() {
        if (product == null) return BigDecimal.ZERO;
        return BigDecimal.valueOf(product.getPrice()).multiply(BigDecimal.valueOf(quantity));
    }
}