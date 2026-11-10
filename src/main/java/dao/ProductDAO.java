package dao;

import model.Product;
import model.Product.ProductOption;
import model.Product.ProductSpec;
import model.Product.ProductCompatibility;
import model.Product.Review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ProductDAO {

    private static boolean reviewSchemaInitialized = false;

    public static class UserReviewItem {
        private int reviewId;
        private int productId;
        private String productName;
        private String shopName;
        private int rating;
        private String variantInfo;
        private String comment;
        private String reviewDate;
        private String imageUrls;

        public UserReviewItem(int reviewId, int productId, String productName, String shopName,
                              int rating, String variantInfo, String comment, String reviewDate) {
            this(reviewId, productId, productName, shopName, rating, variantInfo, comment, reviewDate, null);
        }

        public UserReviewItem(int reviewId, int productId, String productName, String shopName,
                              int rating, String variantInfo, String comment, String reviewDate, String imageUrls) {
            this.reviewId = reviewId;
            this.productId = productId;
            this.productName = productName;
            this.shopName = shopName;
            this.rating = rating;
            this.variantInfo = variantInfo;
            this.comment = comment;
            this.reviewDate = reviewDate;
            this.imageUrls = imageUrls;
        }

        public int getReviewId() { return reviewId; }
        public int getProductId() { return productId; }
        public String getProductName() { return productName; }
        public String getShopName() { return shopName; }
        public int getRating() { return rating; }
        public String getVariantInfo() { return variantInfo; }
        public String getComment() { return comment; }
        public String getReviewDate() { return reviewDate; }
        public String getImageUrls() { return imageUrls; }
    }

    public static class ReviewReplyItem {
        private int id;
        private int reviewId;
        private Integer userId;
        private String replierName;
        private String roleBadge;
        private String comment;
        private String createdAt;

        public ReviewReplyItem(int id, int reviewId, Integer userId, String replierName,
                               String roleBadge, String comment, String createdAt) {
            this.id = id;
            this.reviewId = reviewId;
            this.userId = userId;
            this.replierName = replierName;
            this.roleBadge = roleBadge;
            this.comment = comment;
            this.createdAt = createdAt;
        }

        public int getId() { return id; }
        public int getReviewId() { return reviewId; }
        public Integer getUserId() { return userId; }
        public String getReplierName() { return replierName; }
        public String getRoleBadge() { return roleBadge; }
        public String getComment() { return comment; }
        public String getCreatedAt() { return createdAt; }
    }

    public static class ReviewItem {
        private int id;
        private int productId;
        private Integer userId;
        private String reviewerName;
        private String avatarText;
        private int rating;
        private String variantInfo;
        private String comment;
        private int helpfulCount;
        private int unhelpfulCount;
        private String reviewDate;
        private String imageUrls;
        private boolean customService;
        private List<ReviewReplyItem> replies = new ArrayList<>();

        public ReviewItem(int id, int productId, Integer userId, String reviewerName, String avatarText,
                          int rating, String variantInfo, String comment, int helpfulCount, int unhelpfulCount,
                          String reviewDate, String imageUrls, boolean customService) {
            this.id = id;
            this.productId = productId;
            this.userId = userId;
            this.reviewerName = reviewerName;
            this.avatarText = avatarText;
            this.rating = rating;
            this.variantInfo = variantInfo;
            this.comment = comment;
            this.helpfulCount = helpfulCount;
            this.unhelpfulCount = unhelpfulCount;
            this.reviewDate = reviewDate;
            this.imageUrls = imageUrls;
            this.customService = customService;
        }

        public int getId() { return id; }
        public int getProductId() { return productId; }
        public Integer getUserId() { return userId; }
        public String getReviewerName() { return reviewerName; }
        public String getAvatarText() { return avatarText; }
        public int getRating() { return rating; }
        public String getVariantInfo() { return variantInfo; }
        public String getComment() { return comment; }
        public int getHelpfulCount() { return helpfulCount; }
        public int getUnhelpfulCount() { return unhelpfulCount; }
        public String getReviewDate() { return reviewDate; }
        public String getImageUrls() { return imageUrls; }
        public boolean isCustomService() { return customService; }
        public List<ReviewReplyItem> getReplies() { return replies; }
        public void setReplies(List<ReviewReplyItem> replies) { this.replies = replies; }

        public String[] getImageUrlArray() {
            if (imageUrls == null || imageUrls.isBlank()) return new String[0];
            return imageUrls.split("\\s*;\\s*");
        }
    }

    public static class ReviewStats {
        private int totalCount;
        private double avgRating;
        private int star5;
        private int star4;
        private int star3;
        private int star2;
        private int star1;
        private int withImagesCount;
        private int withCustomCount;

        public int getTotalCount() { return totalCount; }
        public void setTotalCount(int totalCount) { this.totalCount = totalCount; }
        public double getAvgRating() { return avgRating; }
        public void setAvgRating(double avgRating) { this.avgRating = avgRating; }
        public int getStar5() { return star5; }
        public void setStar5(int star5) { this.star5 = star5; }
        public int getStar4() { return star4; }
        public void setStar4(int star4) { this.star4 = star4; }
        public int getStar3() { return star3; }
        public void setStar3(int star3) { this.star3 = star3; }
        public int getStar2() { return star2; }
        public void setStar2(int star2) { this.star2 = star2; }
        public int getStar1() { return star1; }
        public void setStar1(int star1) { this.star1 = star1; }
        public int getWithImagesCount() { return withImagesCount; }
        public void setWithImagesCount(int withImagesCount) { this.withImagesCount = withImagesCount; }
        public int getWithCustomCount() { return withCustomCount; }
        public void setWithCustomCount(int withCustomCount) { this.withCustomCount = withCustomCount; }

        public int getPercent(int starCount) {
            if (totalCount <= 0) return 0;
            return Math.round((starCount * 100.0f) / totalCount);
        }
    }

    // Tự động nâng cấp bảng reviews, tạo bảng review_replies, nạp đánh giá thật từ các user trong DB và đồng bộ rating_count thật
    public synchronized void ensureReviewSchemaAndSeed() {
        if (reviewSchemaInitialized) return;
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {

            try { st.executeUpdate("ALTER TABLE reviews ADD COLUMN unhelpful_count INT DEFAULT 0"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE reviews ADD COLUMN image_urls TEXT"); } catch (SQLException ignored) {}
            try { st.executeUpdate("ALTER TABLE reviews ADD COLUMN is_custom_service TINYINT(1) DEFAULT 0"); } catch (SQLException ignored) {}

            st.executeUpdate("CREATE TABLE IF NOT EXISTS review_replies ("
                    + "id INT AUTO_INCREMENT PRIMARY KEY, "
                    + "review_id INT NOT NULL, "
                    + "user_id INT, "
                    + "replier_name VARCHAR(100) NOT NULL, "
                    + "role_badge VARCHAR(30) DEFAULT 'Khách hàng', "
                    + "comment TEXT NOT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
                    + "CONSTRAINT fk_replies_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE"
                    + ") ENGINE=InnoDB");

            // Kiểm tra số lượng đánh giá của sản phẩm số 1 (Kit Tofu60 2.0)
            int countProd1 = 0;
            try (ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM reviews WHERE product_id = 1")) {
                if (rs.next()) countProd1 = rs.getInt(1);
            }

            if (countProd1 < 16) {
                // Cập nhật ảnh & cờ gia công cho các review mẫu ban đầu
                st.executeUpdate("UPDATE reviews SET image_urls = 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80;https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=600&q=80', is_custom_service = 1 WHERE id = 1");
                st.executeUpdate("UPDATE reviews SET is_custom_service = 0 WHERE id = 2");

                String seedSql = "INSERT INTO reviews (product_id, user_id, reviewer_name, avatar_text, rating, variant_info, comment, helpful_count, unhelpful_count, review_date, image_urls, is_custom_service) VALUES "
                        + "(1, 35, 'Vũ Thành Đạt', 'TĐ', 5, 'Phân loại: Silver / Brass plate · Gói Full lube + tune', '[Màu đẹp đúng ảnh · Đóng gói kỹ] Mình đặt kèm gói Full lube tại xưởng, stab được cân cực chuẩn không một tiếng lọc xọc. Khung nhôm CNC cầm nặng trịch.', 19, 1, '19/09/2026', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80;https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(1, 4, 'Lê Hoàng Nam', 'LN', 5, 'Phân loại: Black / FR4 plate', 'Mạch hotswap 5-pin nhận QMK/VIA ngay lập tức. Bản Tofu60 2.0 chuyển qua Bowl Gasket gõ nhún êm hơn hẳn bản tray mount đời cũ.', 15, 0, '21/09/2026', 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=600&q=80', 0),"
                        + "(1, 5, 'Phạm Minh Đức', 'PĐ', 4, 'Phân loại: Navy / Polycarbonate', 'Màu Navy ngoài đời trầm và sang hơn trên ảnh. Trừ 1 sao vì đơn vị vận chuyển giao trễ mất 1 ngày so với dự kiến, còn chất lượng kit thì 10 điểm.', 8, 1, '22/09/2026', NULL, 0),"
                        + "(1, 6, 'Võ Quốc Huy', 'VH', 5, 'Phân loại: Silver / Brass plate · Gói Audiophile Custom', 'Shop gia công quá có tâm, gửi kèm cả video soundtest trước khi đóng hàng. Lắp Gateron Oil King lên nghe âm thocky cực kỳ gọn.', 14, 0, '23/09/2026', 'https://images.unsplash.com/photo-1541140532154-b024d705b90a?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(1, 7, 'Đặng Tuấn Kiệt', 'ĐK', 3, 'Phân loại: Black / Aluminium', 'Kit hoàn thiện tốt nhưng ốc bắt daughterboard hơi nhỏ, người mới tự lắp nếu không có tua vít chuẩn PH0 rất dễ bịờn ốc. Nên thuê xưởng lắp luôn.', 11, 2, '24/09/2026', NULL, 0),"
                        + "(1, 8, 'Bùi Thanh Tùng', 'BT', 5, 'Phân loại: Silver / FR4 plate · Gói Lube cơ bản', 'Đóng gói 3 lớp xốp nổ dày cộm. Tạ đồng phía dưới cắt CNC sắc sảo không một vết xước dăm.', 9, 0, '25/09/2026', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(1, 9, 'Hoàng Gia Bảo', 'HB', 2, 'Phân loại: Navy / Polycarbonate', 'Hộp bên ngoài bị móp nhẹ ở góc do bên giao hàng quăng quật, may mà bên trong có foam dày nên vỏ nhôm không bị cấn móp. Shop nên bọc thêm góc nhựa.', 6, 3, '26/09/2026', NULL, 0),"
                        + "(1, 10, 'Đỗ Quang Khải', 'ĐK', 1, 'Phân loại: Black / Polycarbonate', 'Mình tự lắp ở nhà cắm nhầm switch chân cong làm bung 1 chân hotswap socket, phải gửi lại xưởng hàn lại mất thêm thời gian.', 5, 8, '27/09/2026', NULL, 0),"
                        + "(1, 11, 'Ngô Đình Phong', 'NP', 5, 'Phân loại: Silver / Brass plate', 'Combo Tofu60 2.0 + Plate đồng cho âm clacky cực kỳ vang và đanh. Rất đáng tiền trong tầm giá dưới 3 triệu.', 12, 0, '28/09/2026', 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=600&q=80', 0),"
                        + "(1, 12, 'Dương Nhật Minh', 'DM', 5, 'Phân loại: Black / FR4 plate · Gói Full lube + tune', 'Thợ căn chỉnh thanh Space 6.25u êm ru, gõ code cả đêm không mỏi tay. Sẽ ủng hộ shop dài dài.', 7, 0, '29/09/2026', NULL, 1),"
                        + "(1, 13, 'Lý Thành Đạt', 'LĐ', 4, 'Phân loại: Silver / Polycarbonate', 'Foam đi kèm đầy đủ từ case foam, plate foam tới tấm PET sheet. Chỉ cần cắm switch và keycap là dùng ngon.', 6, 0, '01/10/2026', NULL, 0),"
                        + "(1, 14, 'Trịnh Hải Đăng', 'TĐ', 5, 'Phân loại: Navy / Brass plate · Gói Premium', 'Chất lượng anodize của KBDfans năm nay mịn thật sự, sờ mát lạnh không bám vân tay.', 10, 1, '03/10/2026', 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(1, 15, 'Hà Trọng Nghĩa', 'HN', 5, 'Phân loại: Silver / FR4 plate', 'Giao hàng hỏa tốc trong ngày tại TP.HCM. Đã test toàn bộ 61 socket trên VIA đều nhận tín hiệu mượt.', 4, 0, '05/10/2026', NULL, 0),"
                        + "(1, 16, 'Mai Xuân Bách', 'MB', 4, 'Phân loại: Black / Aluminium', 'Mọi thứ đều ổn, cáp USB-C tặng kèm hơi cứng một chút, mua thêm sợi Coiled Cable nữa là đẹp hết bài.', 5, 0, '07/10/2026', NULL, 0),"
                        + "(1, 17, 'Lâm Chấn Khang', 'LK', 5, 'Phân loại: Navy / FR4 plate · Gói Full lube + tune', 'Bản build ưng ý nhất từ trước tới giờ của mình trên KeebHub. Cảm ơn xưởng KeebLab và SwitchHouse!', 8, 0, '09/10/2026', 'https://images.unsplash.com/photo-1541140532154-b024d705b90a?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(1, 18, 'Phan Anh Quân', 'PQ', 5, 'Phân loại: Silver / Brass plate', 'Layout 60% gọn gàng, để trên bàn làm việc tiết kiệm diện tích để di chuột bắn CS2 cực sướng.', 9, 0, '11/10/2026', NULL, 0),"
                        + "(1, 19, 'Tạ Minh Triết', 'TT', 3, 'Phân loại: Black / Polycarbonate', 'Keymap mặc định chưa gán sẵn cụm phím mũi tên ở lớp Fn, phải mở web usevia.app lên chỉnh mất 5 phút mới quen.', 3, 1, '12/10/2026', NULL, 0),"
                        + "(1, 20, 'Châu Vĩnh Phúc', 'CP', 5, 'Phân loại: Silver / FR4 plate · Gói Lube cơ bản', 'Độ hoàn thiện CNC sắc nét từng góc cạnh, xứng đáng là kit 60% quốc dân.', 11, 0, '14/10/2026', 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(3, 33, 'Nguyễn Minh Khôi', 'MK', 5, 'Phân loại: Base 137 phím Cherry', 'Keycap GMK Olivia++ hàng chính hãng Đức, nhựa ABS dày, màu hồng Rose Gold cực kỳ chuẩn.', 16, 0, '05/10/2026', 'https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=600&q=80', 0),"
                        + "(4, 34, 'Trần Hoàng Phúc', 'HP', 5, 'Phân loại: Carbon Black · Gói Premium', 'Keychron Q1 Pro kết nối Bluetooth chuyển qua lại giữa MacBook và PC cực nhạy, núm xoay vặn rất đầm.', 21, 0, '08/10/2026', 'https://images.unsplash.com/photo-1541140532154-b024d705b90a?auto=format&fit=crop&w=600&q=80', 1),"
                        + "(5, 35, 'Vũ Thành Đạt', 'TĐ', 5, 'Phân loại: Hộp 45 nút Linear 50g', 'Switch Akko Cream Yellow V3 Pro quốc dân, stem POM gõ nổ bắp rang bơ rất vui tai.', 27, 1, '09/10/2026', NULL, 0),"
                        + "(7, 33, 'Nguyễn Minh Khôi', 'MK', 5, 'Phân loại: Black & Pink ASA 158 phím', 'Nhựa PBT dày dặn không xuyên LED nhưng bù lại ký tự Double-shot siêu nét, hộp đựng xịn.', 19, 0, '11/10/2026', 'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?auto=format&fit=crop&w=600&q=80', 0)";
                st.executeUpdate(seedSql);

                // Thêm các câu trả lời (Reply) mẫu của Chủ xưởng cho các bài đánh giá của sản phẩm 1
                st.executeUpdate("INSERT INTO review_replies (review_id, user_id, replier_name, role_badge, comment) VALUES "
                        + "(1, 4, 'Lê Hoàng Nam (KeebLab Store)', 'Chủ xưởng', 'Cảm ơn bác Minh Khôi đã tin tưởng ủng hộ KeebLab Store! Chúc bác có trải nghiệm gõ phím thật ưng ý nhé.'),"
                        + "(10, 4, 'Lê Hoàng Nam (KeebLab Store)', 'Chủ xưởng', 'Dạ shop đã tiếp nhận mạch của bạn và hỗ trợ hàn lại socket hotswap miễn phí trong gói bảo hành 12 tháng rồi ạ!')");
            }

            // Đồng bộ tuyệt đối rating_count và rating_avg của toàn bộ sản phẩm theo đúng dữ liệu thật trong bảng reviews
            st.executeUpdate("UPDATE products p SET "
                    + "rating_count = (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id), "
                    + "rating_avg = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM reviews r WHERE r.product_id = p.id), p.rating_avg)");

            reviewSchemaInitialized = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Product getProductById(int id) {
        ensureReviewSchemaAndSeed();
        String sql = "SELECT p.*, c.name AS category_name, "
                + "s.shop_name, s.avatar_text, s.avatar_color, s.address, s.is_verified, "
                + "s.rating_avg AS shop_rating, s.follower_count, s.response_rate, s.response_time "
                + "FROM products p "
                + "LEFT JOIN categories c ON p.category_id = c.id "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
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
                    p.setShopVerified(rs.getObject("is_verified") != null && rs.getInt("is_verified") == 1);
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

    public ReviewStats getReviewStatsByProduct(int productId) {
        ensureReviewSchemaAndSeed();
        ReviewStats stats = new ReviewStats();
        String sql = "SELECT COUNT(*) AS total_cnt, "
                + "COALESCE(ROUND(AVG(rating), 1), 0.0) AS avg_rt, "
                + "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS s5, "
                + "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS s4, "
                + "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) AS s3, "
                + "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) AS s2, "
                + "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) AS s1, "
                + "SUM(CASE WHEN image_urls IS NOT NULL AND TRIM(image_urls) <> '' THEN 1 ELSE 0 END) AS img_cnt, "
                + "SUM(CASE WHEN is_custom_service = 1 THEN 1 ELSE 0 END) AS cus_cnt "
                + "FROM reviews WHERE product_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalCount(rs.getInt("total_cnt"));
                    stats.setAvgRating(rs.getDouble("avg_rt"));
                    stats.setStar5(rs.getInt("s5"));
                    stats.setStar4(rs.getInt("s4"));
                    stats.setStar3(rs.getInt("s3"));
                    stats.setStar2(rs.getInt("s2"));
                    stats.setStar1(rs.getInt("s1"));
                    stats.setWithImagesCount(rs.getInt("img_cnt"));
                    stats.setWithCustomCount(rs.getInt("cus_cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }

    public int countReviewsFiltered(int productId, Integer starFilter, boolean hasImage, boolean hasCustom) {
        ensureReviewSchemaAndSeed();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM reviews WHERE product_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(productId);

        if (starFilter != null && starFilter >= 1 && starFilter <= 5) {
            sql.append("AND rating = ? ");
            params.add(starFilter);
        }
        if (hasImage) {
            sql.append("AND image_urls IS NOT NULL AND TRIM(image_urls) <> '' ");
        }
        if (hasCustom) {
            sql.append("AND is_custom_service = 1 ");
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<ReviewItem> getFilteredReviewsPaginated(int productId, Integer starFilter, boolean hasImage, boolean hasCustom, int limit, int offset) {
        ensureReviewSchemaAndSeed();
        List<ReviewItem> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM reviews WHERE product_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(productId);

        if (starFilter != null && starFilter >= 1 && starFilter <= 5) {
            sql.append("AND rating = ? ");
            params.add(starFilter);
        }
        if (hasImage) {
            sql.append("AND image_urls IS NOT NULL AND TRIM(image_urls) <> '' ");
        }
        if (hasCustom) {
            sql.append("AND is_custom_service = 1 ");
        }

        sql.append("ORDER BY id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Integer uid = (rs.getObject("user_id") != null) ? rs.getInt("user_id") : null;
                    int unhelpful = 0;
                    String imgs = null;
                    boolean isCus = false;
                    try { unhelpful = rs.getInt("unhelpful_count"); } catch (SQLException ignored) {}
                    try { imgs = rs.getString("image_urls"); } catch (SQLException ignored) {}
                    try { isCus = rs.getInt("is_custom_service") == 1; } catch (SQLException ignored) {}

                    ReviewItem item = new ReviewItem(
                            rs.getInt("id"),
                            rs.getInt("product_id"),
                            uid,
                            rs.getString("reviewer_name"),
                            rs.getString("avatar_text"),
                            rs.getInt("rating"),
                            rs.getString("variant_info"),
                            rs.getString("comment"),
                            rs.getInt("helpful_count"),
                            unhelpful,
                            rs.getString("review_date"),
                            imgs,
                            isCus
                    );
                    item.setReplies(getRepliesByReviewId(conn, item.getId()));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<ReviewReplyItem> getRepliesByReviewId(Connection conn, int reviewId) {
        List<ReviewReplyItem> replies = new ArrayList<>();
        String sql = "SELECT * FROM review_replies WHERE review_id = ? ORDER BY id ASC";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                while (rs.next()) {
                    Integer uid = (rs.getObject("user_id") != null) ? rs.getInt("user_id") : null;
                    String timeStr = (rs.getTimestamp("created_at") != null)
                            ? fmt.format(rs.getTimestamp("created_at"))
                            : "";
                    replies.add(new ReviewReplyItem(
                            rs.getInt("id"),
                            rs.getInt("review_id"),
                            uid,
                            rs.getString("replier_name"),
                            rs.getString("role_badge"),
                            rs.getString("comment"),
                            timeStr
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return replies;
    }

    public boolean voteReviewHelpful(int reviewId, boolean isHelpful) {
        ensureReviewSchemaAndSeed();
        String col = isHelpful ? "helpful_count" : "unhelpful_count";
        String sql = "UPDATE reviews SET " + col + " = " + col + " + 1 WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addReviewReply(int reviewId, Integer userId, String replierName, String roleBadge, String comment) {
        ensureReviewSchemaAndSeed();
        String sql = "INSERT INTO review_replies (review_id, user_id, replier_name, role_badge, comment) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            if (userId != null) ps.setInt(2, userId);
            else ps.setNull(2, java.sql.Types.INTEGER);
            ps.setString(3, replierName);
            ps.setString(4, roleBadge != null ? roleBadge : "Khách hàng");
            ps.setString(5, comment.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> filterProducts(Integer categoryId, String keyword, String[] brands,
                                        String[] switchTypes, String[] forces, String[] layouts,
                                        String[] mounts, Long minPrice, Long maxPrice,
                                        Boolean inStockOnly, Boolean supportCustom, Double minRating, String sort) {
        ensureReviewSchemaAndSeed();
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, s.shop_name, c.name AS category_name FROM products p "
                        + "LEFT JOIN shops s ON p.shop_id = s.id "
                        + "LEFT JOIN categories c ON p.category_id = c.id "
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
        ensureReviewSchemaAndSeed();
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, s.shop_name FROM products p "
                        + "LEFT JOIN shops s ON p.shop_id = s.id "
                        + "WHERE p.shop_id = ? AND p.status = 'ACTIVE' "
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
        } else if ("price_desc".equals(sort)) {
            sql.append("ORDER BY p.price DESC");
        } else {
            sql.append("ORDER BY p.sold_count DESC, p.rating_avg DESC");
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
        return addReview(productId, userId, reviewerName, avatarText, rating, variantInfo, comment, reviewDate, null, false);
    }

    public boolean addReview(int productId, Integer userId, String reviewerName, String avatarText,
                             int rating, String variantInfo, String comment, String reviewDate,
                             String imageUrls, boolean isCustomService) {
        ensureReviewSchemaAndSeed();
        String sql = "INSERT INTO reviews (product_id, user_id, reviewer_name, avatar_text, rating, variant_info, comment, helpful_count, unhelpful_count, review_date, image_urls, is_custom_service) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, 0, 0, ?, ?, ?)";
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
            ps.setString(9, (imageUrls != null && !imageUrls.isBlank()) ? imageUrls.trim() : null);
            ps.setInt(10, isCustomService ? 1 : 0);

            boolean inserted = ps.executeUpdate() > 0;
            if (inserted) {
                String updateStats = "UPDATE products SET "
                        + "rating_count = (SELECT COUNT(*) FROM reviews WHERE product_id = ?), "
                        + "rating_avg = COALESCE((SELECT ROUND(AVG(rating), 1) FROM reviews WHERE product_id = ?), 5.0) "
                        + "WHERE id = ?";
                try (PreparedStatement psUp = conn.prepareStatement(updateStats)) {
                    psUp.setInt(1, productId);
                    psUp.setInt(2, productId);
                    psUp.setInt(3, productId);
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
        ensureReviewSchemaAndSeed();
        List<UserReviewItem> list = new ArrayList<>();
        String sql = "SELECT r.*, p.name AS product_name, s.shop_name "
                + "FROM reviews r "
                + "LEFT JOIN products p ON r.product_id = p.id "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "WHERE r.user_id = ? ORDER BY r.id DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String imgs = null;
                    try { imgs = rs.getString("image_urls"); } catch (SQLException ignored) {}
                    list.add(new UserReviewItem(
                            rs.getInt("id"),
                            rs.getInt("product_id"),
                            rs.getString("product_name"),
                            rs.getString("shop_name"),
                            rs.getInt("rating"),
                            rs.getString("variant_info"),
                            rs.getString("comment"),
                            rs.getString("review_date"),
                            imgs
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Set<Integer> getReviewedProductIdsByUser(int userId) {
        ensureReviewSchemaAndSeed();
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
        ensureReviewSchemaAndSeed();
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
        return list;
    }

    public List<Product> getSimilarProducts(int excludeProductId, int limit) {
        ensureReviewSchemaAndSeed();
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, s.shop_name FROM products p "
                + "LEFT JOIN shops s ON p.shop_id = s.id "
                + "WHERE p.id <> ? AND p.status = 'ACTIVE' ORDER BY p.id ASC LIMIT ?";
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

    public static class CategoryStat {
        private int id;
        private String name;
        private String icon;
        private int productCount;

        public CategoryStat(int id, String name, String icon, int productCount) {
            this.id = id;
            this.name = name;
            this.icon = icon;
            this.productCount = productCount;
        }
        public int getId() { return id; }
        public String getName() { return name; }
        public String getIcon() { return icon; }
        public int getProductCount() { return productCount; }
    }

    public List<CategoryStat> getAllCategoriesWithCount() {
        List<CategoryStat> list = new ArrayList<>();
        String sql = "SELECT c.id, c.name, c.icon, COUNT(p.id) AS actual_count "
                + "FROM categories c LEFT JOIN products p ON c.id = p.category_id AND p.status = 'ACTIVE' "
                + "GROUP BY c.id, c.name, c.icon ORDER BY c.id ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new CategoryStat(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("icon"),
                        rs.getInt("actual_count")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalActiveProductsCount() {
        String sql = "SELECT COUNT(*) FROM products WHERE status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
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