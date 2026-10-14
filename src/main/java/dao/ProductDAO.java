package dao;

import model.Product;
import model.Product.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public Product getProductById(int id) {
        String sql = "SELECT p.*, c.name AS category_name, "
                + "s.shop_name, s.avatar_text, s.avatar_color, s.address, s.is_verified, "
                + "s.rating_avg AS shop_rating, s.follower_count, s.response_rate, s.response_time "
                + "FROM products p "
                + "JOIN categories c ON p.category_id = c.id "
                + "JOIN shops s ON p.shop_id = s.id "
                + "WHERE p.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapProduct(rs);
                    p.setCategoryName(rs.getString("category_name"));
                    p.setShopName(rs.getString("shop_name"));
                    p.setShopAvatarText(rs.getString("avatar_text"));
                    p.setShopAvatarColor(rs.getString("avatar_color"));
                    p.setShopAddress(rs.getString("address"));
                    p.setShopVerified(rs.getInt("is_verified") == 1);
                    p.setShopRating(rs.getDouble("shop_rating"));
                    p.setShopFollowers(rs.getInt("follower_count"));
                    p.setShopResponseRate(rs.getInt("response_rate"));
                    p.setShopResponseTime(rs.getString("response_time"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ProductOption> getOptionsByGroup(int productId, String group) {
        List<ProductOption> list = new ArrayList<>();
        String sql = "SELECT * FROM product_options WHERE product_id = ? AND option_group = ? ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, group);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ProductOption(
                            rs.getInt("id"),
                            rs.getString("option_group"),
                            rs.getString("option_name"),
                            rs.getLong("extra_price"),
                            rs.getInt("is_available") == 1
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Nếu xem sản phẩm số 2..8 chưa có option riêng thì lấy mẫu của sản phẩm 1 để hiển thị đầy đủ
        if (list.isEmpty() && productId != 1) {
            return getOptionsByGroup(1, group);
        }
        return list;
    }

    public List<ProductSpec> getSpecsByProductId(int productId) {
        List<ProductSpec> list = new ArrayList<>();
        String sql = "SELECT * FROM product_specs WHERE product_id = ? ORDER BY display_order ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ProductSpec(rs.getString("spec_name"), rs.getString("spec_value")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (list.isEmpty() && productId != 1) {
            return getSpecsByProductId(1);
        }
        return list;
    }

    public List<ProductCompatibility> getCompatibilitiesByProductId(int productId) {
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
        if (list.isEmpty() && productId != 1) {
            return getCompatibilitiesByProductId(1);
        }
        return list;
    }

    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT * FROM reviews WHERE product_id = ? ORDER BY id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Review(
                            rs.getString("reviewer_name"),
                            rs.getString("avatar_text"),
                            rs.getInt("rating"),
                            rs.getString("variant_info"),
                            rs.getString("comment"),
                            rs.getInt("helpful_count"),
                            rs.getString("review_date")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (list.isEmpty() && productId != 1) {
            return getReviewsByProductId(1);
        }
        return list;
    }

    public List<Product> getSimilarProducts(int excludeProductId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, s.shop_name FROM products p "
                + "JOIN shops s ON p.shop_id = s.id "
                + "WHERE p.id <> ? ORDER BY p.id ASC LIMIT ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, excludeProductId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapProduct(rs);
                    p.setShopName(rs.getString("shop_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Product mapProduct(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setShopId(rs.getInt("shop_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setSku(rs.getString("sku"));
        p.setName(rs.getString("name"));
        p.setBrand(rs.getString("brand"));
        p.setShortDesc(rs.getString("short_desc"));
        p.setDescription(rs.getString("description"));
        p.setPrice(rs.getLong("price"));
        p.setOldPrice(rs.getLong("old_price"));
        p.setDiscountPercent(rs.getInt("discount_percent"));
        p.setStock(rs.getInt("stock"));
        p.setSoldCount(rs.getInt("sold_count"));
        p.setRatingAvg(rs.getDouble("rating_avg"));
        p.setRatingCount(rs.getInt("rating_count"));
        p.setBadge(rs.getString("badge"));
        p.setSupportCustom(rs.getInt("support_custom") == 1);
        p.setLayout(rs.getString("layout"));
        p.setMountType(rs.getString("mount_type"));
        return p;
    }
}