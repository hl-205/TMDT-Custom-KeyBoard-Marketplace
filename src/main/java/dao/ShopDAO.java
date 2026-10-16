package dao;

import model.Shop;
import model.Shop.CustomServiceItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ShopDAO {

    public Shop getShopById(int id) {
        String sql = "SELECT * FROM shops WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapShop(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Shop getShopByOwnerId(int ownerId) {
        String sql = "SELECT * FROM shops WHERE owner_id = ? LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapShop(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return getShopById(2);
    }

    public List<Shop> getAllShops() {
        return searchShops(null, null, null, "popular");
    }

    public List<Shop> searchShops(String keyword, String type, Double minRating, String sort) {
        List<Shop> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM shops WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (shop_name LIKE ? OR description LIKE ? OR address LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if ("workshop".equals(type)) {
            sql.append("AND is_workshop = 1 ");
        } else if ("verified".equals(type)) {
            sql.append("AND is_verified = 1 ");
        }
        if (minRating != null && minRating > 0) {
            sql.append("AND rating_avg >= ? ");
            params.add(minRating);
        }

        if ("rating".equals(sort)) {
            sql.append("ORDER BY rating_avg DESC, rating_count DESC");
        } else if ("newest".equals(sort)) {
            sql.append("ORDER BY id DESC");
        } else if ("followers".equals(sort)) {
            sql.append("ORDER BY follower_count DESC");
        } else {
            sql.append("ORDER BY product_count DESC, follower_count DESC");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapShop(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CustomServiceItem> getServicesByShopId(int shopId) {
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

    private Shop mapShop(ResultSet rs) throws Exception {
        Shop s = new Shop();
        s.setId(rs.getInt("id"));
        s.setShopName(rs.getString("shop_name"));
        s.setSlug(rs.getString("slug"));
        s.setAvatarText(rs.getString("avatar_text"));
        s.setAvatarColor(rs.getString("avatar_color"));
        s.setDescription(rs.getString("description"));
        s.setAddress(rs.getString("address"));
        s.setWorkingHours(rs.getString("working_hours"));
        s.setVerified(rs.getInt("is_verified") == 1);
        s.setWorkshop(rs.getInt("is_workshop") == 1);
        s.setRatingAvg(rs.getDouble("rating_avg"));
        s.setRatingCount(rs.getInt("rating_count"));
        s.setFollowerCount(rs.getInt("follower_count"));
        s.setProductCount(rs.getInt("product_count"));
        s.setResponseRate(rs.getInt("response_rate"));
        s.setResponseTime(rs.getString("response_time"));
        s.setOnTimeRate(rs.getDouble("on_time_rate"));
        s.setCancelRate(rs.getDouble("cancel_rate"));
        s.setReturnRate(rs.getDouble("return_rate"));
        s.setJoinedDate(rs.getString("joined_date"));
        return s;
    }
}