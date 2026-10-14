package dao;

import model.Product;
import model.Product.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ProductDAO {

    public static class UserReviewItem {
        private int reviewId;
        private int productId;
        private String productName;
        private String shopName;
        private int rating;
        private String variantInfo;
        private String comment;
        private String reviewDate;

        public UserReviewItem(int reviewId, int productId, String productName, String shopName,
                              int rating, String variantInfo, String comment, String reviewDate) {
            this.reviewId = reviewId;
            this.productId = productId;
            this.productName = productName;
            this.shopName = shopName;
            this.rating = rating;
            this.variantInfo = variantInfo;
            this.comment = comment;
            this.reviewDate = reviewDate;
        }
        public int getReviewId() { return reviewId; }
        public int getProductId() { return productId; }
        public String getProductName() { return productName; }
        public String getShopName() { return shopName; }
        public int getRating() { return rating; }
        public String getVariantInfo() { return variantInfo; }
        public String getComment() { return comment; }
        public String getReviewDate() { return reviewDate; }
    }

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

    public List<Product> filterProducts(Integer categoryId, String keyword, String[] brands,
                                        String[] switchTypes, String[] forces, String[] layouts,
                                        String[] mounts, Long minPrice, Long maxPrice,
                                        Boolean inStockOnly, Boolean supportCustom, Double minRating, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, s.shop_name, c.name AS category_name FROM products p "
                        + "JOIN shops s ON p.shop_id = s.id "
                        + "JOIN categories c ON p.category_id = c.id "
                        + "WHERE p.status = 'ACTIVE' "
        );
        List<Object> params = new ArrayList<>();

        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (p.name LIKE ? OR p.brand LIKE ? OR s.shop_name LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (brands != null && brands.length > 0) {
            sql.append("AND p.brand IN (");
            for (int i = 0; i < brands.length; i++) {
                sql.append(i == 0 ? "?" : ",?");
                params.add(brands[i]);
            }
            sql.append(") ");
        }
        if (switchTypes != null && switchTypes.length > 0) {
            sql.append("AND p.switch_type IN (");
            for (int i = 0; i < switchTypes.length; i++) {
                sql.append(i == 0 ? "?" : ",?");
                params.add(switchTypes[i]);
            }
            sql.append(") ");
        }
        if (forces != null && forces.length > 0) {
            sql.append("AND p.actuation_force IN (");
            for (int i = 0; i < forces.length; i++) {
                sql.append(i == 0 ? "?" : ",?");
                params.add(forces[i]);
            }
            sql.append(") ");
        }
        if (layouts != null && layouts.length > 0) {
            sql.append("AND (");
            for (int i = 0; i < layouts.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("p.layout LIKE ?");
                params.add("%" + layouts[i] + "%");
            }
            sql.append(") ");
        }
        if (mounts != null && mounts.length > 0) {
            sql.append("AND p.mount_type IN (");
            for (int i = 0; i < mounts.length; i++) {
                sql.append(i == 0 ? "?" : ",?");
                params.add(mounts[i]);
            }
            sql.append(") ");
        }
        if (minPrice != null && minPrice > 0) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice != null && maxPrice > 0) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }
        if (inStockOnly != null && inStockOnly) {
            sql.append("AND p.stock > 0 ");
        }
        if (supportCustom != null && supportCustom) {
            sql.append("AND p.support_custom = 1 ");
        }
        if (minRating != null && minRating > 0) {
            sql.append("AND p.rating_avg >= ? ");
            params.add(minRating);
        }

        if ("newest".equals(sort)) {
            sql.append("ORDER BY p.id DESC");
        } else if ("best_selling".equals(sort)) {
            sql.append("ORDER BY p.sold_count DESC");
        } else if ("price_asc".equals(sort)) {
            sql.append("ORDER BY p.price ASC");
        } else if ("price_desc".equals(sort)) {
            sql.append("ORDER BY p.price DESC");
        } else {
            sql.append("ORDER BY p.sold_count DESC, p.rating_avg DESC");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapProduct(rs);
                    p.setShopName(rs.getString("shop_name"));
                    p.setCategoryName(rs.getString("category_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getProductsByShop(int shopId, Integer categoryId, String sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, s.shop_name FROM products p "
                        + "JOIN shops s ON p.shop_id = s.id "
                        + "WHERE p.shop_id = ? "
        );
        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
        }
        if ("newest".equals(sort)) {
            sql.append("ORDER BY p.id DESC");
        } else if ("best_selling".equals(sort)) {
            sql.append("ORDER BY p.sold_count DESC");
        } else if ("price_asc".equals(sort)) {
            sql.append("ORDER BY p.price ASC");
        } else {
            sql.append("ORDER BY p.sold_count DESC");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, shopId);
            if (categoryId != null && categoryId > 0) {
                ps.setInt(2, categoryId);
            }
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

    public boolean addReview(int productId, Integer userId, String reviewerName, String avatarText,
                             int rating, String variantInfo, String comment, String reviewDate) {
        String sql = "INSERT INTO reviews (product_id, user_id, reviewer_name, avatar_text, rating, variant_info, comment, helpful_count, review_date) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            if (userId != null) ps.setInt(2, userId);
            else ps.setNull(2, java.sql.Types.INTEGER);
            ps.setString(3, reviewerName);
            ps.setString(4, avatarText);
            ps.setInt(5, rating);
            ps.setString(6, variantInfo);
            ps.setString(7, comment);
            ps.setString(8, reviewDate);
            boolean inserted = ps.executeUpdate() > 0;
            if (inserted) {
                String updateCount = "UPDATE products SET rating_count = rating_count + 1 WHERE id = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateCount)) {
                    psUp.setInt(1, productId);
                    psUp.executeUpdate();
                }
                if (userId != null) {
                    String updatePoints = "UPDATE users SET points = points + 50 WHERE id = ?";
                    try (PreparedStatement psPt = conn.prepareStatement(updatePoints)) {
                        psPt.setInt(1, userId);
                        psPt.executeUpdate();
                    }
                }
            }
            return inserted;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<UserReviewItem> getReviewsByUserId(int userId) {
        List<UserReviewItem> list = new ArrayList<>();
        String sql = "SELECT r.*, p.name AS product_name, s.shop_name "
                + "FROM reviews r "
                + "JOIN products p ON r.product_id = p.id "
                + "JOIN shops s ON p.shop_id = s.id "
                + "WHERE r.user_id = ? ORDER BY r.id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new UserReviewItem(
                            rs.getInt("id"),
                            rs.getInt("product_id"),
                            rs.getString("product_name"),
                            rs.getString("shop_name"),
                            rs.getInt("rating"),
                            rs.getString("variant_info"),
                            rs.getString("comment"),
                            rs.getString("review_date")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Set<Integer> getReviewedProductIdsByUser(int userId) {
        Set<Integer> set = new HashSet<>();
        String sql = "SELECT DISTINCT product_id FROM reviews WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    set.add(rs.getInt("product_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return set;
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
        String sql = "SELECT * FROM reviews WHERE product_id = ? ORDER BY id DESC";
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