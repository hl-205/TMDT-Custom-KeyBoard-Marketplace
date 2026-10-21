package dao;

import context.DBContext;
import model.CartItem;
import model.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

public class CartDAO extends DBContext {

    public Map<Integer, CartItem> getCartByUserId(int userId) {
        Map<Integer, CartItem> cart = new LinkedHashMap<>();
        String sql = "SELECT c.quantity, p.* FROM cart_items c " +
                "JOIN products p ON c.product_id = p.id " +
                "WHERE c.user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product product = new Product();
                    product.setId(rs.getInt("id"));
                    product.setShopId(rs.getInt("shop_id"));
                    product.setCategoryId(rs.getInt("category_id"));
                    product.setSku(rs.getString("sku"));
                    product.setName(rs.getString("name"));
                    product.setBrand(rs.getString("brand"));
                    product.setShortDesc(rs.getString("short_desc"));
                    product.setDescription(rs.getString("description"));

                    // Dùng rs.getLong() để sửa lỗi "possible lossy conversion from double to long"
                    product.setPrice(rs.getLong("price"));
                    product.setOldPrice(rs.getLong("old_price"));

                    product.setDiscountPercent(rs.getInt("discount_percent"));
                    product.setStock(rs.getInt("stock"));
                    product.setSoldCount(rs.getInt("sold_count"));
                    product.setImageUrl(rs.getString("image_url"));

                    int quantity = rs.getInt("quantity");
                    cart.put(product.getId(), new CartItem(product, quantity));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cart;
    }

    public void saveOrUpdateItem(int userId, int productId, int quantity) {
        String sql = "INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE quantity = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setInt(4, quantity);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void removeItem(int userId, int productId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ? AND product_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void clearCart(int userId) {
        String sql = "DELETE FROM cart_items WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}