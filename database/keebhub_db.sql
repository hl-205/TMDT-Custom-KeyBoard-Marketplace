DROP DATABASE IF EXISTS keebhub_db;
CREATE DATABASE keebhub_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE keebhub_db;

CREATE TABLE users (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       first_name VARCHAR(50) NOT NULL,
                       last_name VARCHAR(50) NOT NULL,
                       email VARCHAR(100) NOT NULL UNIQUE,
                       phone VARCHAR(20),
                       password VARCHAR(255) NOT NULL,
                       gender VARCHAR(10) DEFAULT 'Nam',
                       dob DATE,
                       avatar_text VARCHAR(5) DEFAULT 'KH',
                       role VARCHAR(20) DEFAULT 'CUSTOMER',
                       points INT DEFAULT 0,
                       is_verified TINYINT(1) DEFAULT 1,
                       status VARCHAR(20) DEFAULT 'ACTIVE',
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shops (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       owner_id INT,
                       shop_name VARCHAR(100) NOT NULL,
                       slug VARCHAR(100),
                       avatar_text VARCHAR(5),
                       avatar_color VARCHAR(20) DEFAULT '#1B64F2',
                       description TEXT,
                       address VARCHAR(255),
                       working_hours VARCHAR(100) DEFAULT '8h-18h, T2-T7',
                       is_verified TINYINT(1) DEFAULT 1,
                       is_workshop TINYINT(1) DEFAULT 1,
                       rating_avg DECIMAL(2,1) DEFAULT 4.9,
                       rating_count INT DEFAULT 0,
                       follower_count INT DEFAULT 0,
                       product_count INT DEFAULT 0,
                       response_rate INT DEFAULT 98,
                       response_time VARCHAR(50) DEFAULT '1 giờ',
                       on_time_rate DECIMAL(4,1) DEFAULT 96.0,
                       cancel_rate DECIMAL(4,1) DEFAULT 0.8,
                       return_rate DECIMAL(4,1) DEFAULT 1.2,
                       joined_date VARCHAR(20) DEFAULT '03/2019',
                       FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE categories (
                            id INT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(100) NOT NULL,
                            slug VARCHAR(100) NOT NULL,
                            icon VARCHAR(50),
                            product_count INT DEFAULT 0
);

CREATE TABLE products (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          shop_id INT NOT NULL,
                          category_id INT NOT NULL,
                          sku VARCHAR(50),
                          name VARCHAR(255) NOT NULL,
                          brand VARCHAR(100),
                          short_desc TEXT,
                          description TEXT,
                          price DECIMAL(12,0) NOT NULL,
                          old_price DECIMAL(12,0) DEFAULT 0,
                          discount_percent INT DEFAULT 0,
                          stock INT DEFAULT 50,
                          sold_count INT DEFAULT 0,
                          rating_avg DECIMAL(2,1) DEFAULT 4.8,
                          rating_count INT DEFAULT 0,
                          badge VARCHAR(50),
                          support_custom TINYINT(1) DEFAULT 1,
                          switch_type VARCHAR(50),
                          actuation_force VARCHAR(50),
                          pin_type VARCHAR(20),
                          layout VARCHAR(50),
                          mount_type VARCHAR(50),
                          image_url VARCHAR(255),
                          status VARCHAR(20) DEFAULT 'ACTIVE',
                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
                          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

CREATE TABLE product_options (
                                 id INT AUTO_INCREMENT PRIMARY KEY,
                                 product_id INT NOT NULL,
                                 option_group VARCHAR(50) NOT NULL,
                                 option_name VARCHAR(100) NOT NULL,
                                 extra_price DECIMAL(12,0) DEFAULT 0,
                                 is_available TINYINT(1) DEFAULT 1,
                                 FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE product_specs (
                               id INT AUTO_INCREMENT PRIMARY KEY,
                               product_id INT NOT NULL,
                               spec_name VARCHAR(100) NOT NULL,
                               spec_value VARCHAR(255) NOT NULL,
                               display_order INT DEFAULT 1,
                               FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE product_compatibilities (
                                         id INT AUTO_INCREMENT PRIMARY KEY,
                                         product_id INT NOT NULL,
                                         title VARCHAR(150) NOT NULL,
                                         description VARCHAR(255) NOT NULL,
                                         is_compatible TINYINT(1) DEFAULT 1,
                                         FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE reviews (
                         id INT AUTO_INCREMENT PRIMARY KEY,
                         product_id INT NOT NULL,
                         user_id INT,
                         reviewer_name VARCHAR(100) NOT NULL,
                         avatar_text VARCHAR(5) DEFAULT 'NM',
                         rating INT DEFAULT 5,
                         variant_info VARCHAR(150),
                         comment TEXT,
                         helpful_count INT DEFAULT 0,
                         review_date VARCHAR(20),
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE custom_services (
                                 id INT AUTO_INCREMENT PRIMARY KEY,
                                 shop_id INT NOT NULL,
                                 service_name VARCHAR(150) NOT NULL,
                                 price DECIMAL(12,0) NOT NULL,
                                 duration_text VARCHAR(50) DEFAULT '3-4 ngày làm việc',
                                 description TEXT,
                                 is_popular TINYINT(1) DEFAULT 0,
                                 sold_month INT DEFAULT 0,
                                 status VARCHAR(20) DEFAULT 'ACTIVE',
                                 FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE TABLE orders (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        order_code VARCHAR(30) NOT NULL UNIQUE,
                        user_id INT NOT NULL,
                        shop_id INT NOT NULL,
                        receiver_name VARCHAR(100) NOT NULL,
                        receiver_phone VARCHAR(20) NOT NULL,
                        shipping_address VARCHAR(255) NOT NULL,
                        is_custom_order TINYINT(1) DEFAULT 0,
                        subtotal DECIMAL(12,0) NOT NULL,
                        custom_fee DECIMAL(12,0) DEFAULT 0,
                        shipping_fee DECIMAL(12,0) DEFAULT 0,
                        discount_amount DECIMAL(12,0) DEFAULT 0,
                        total_amount DECIMAL(12,0) NOT NULL,
                        payment_method VARCHAR(50) DEFAULT 'VNPAY-QR',
                        order_status VARCHAR(30) DEFAULT 'PENDING',
                        progress_percent INT DEFAULT 0,
                        customer_note TEXT,
                        committed_days INT DEFAULT 7,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (user_id) REFERENCES users(id),
                        FOREIGN KEY (shop_id) REFERENCES shops(id)
);

CREATE TABLE order_progress (
                                id INT AUTO_INCREMENT PRIMARY KEY,
                                order_id INT NOT NULL,
                                step_number INT NOT NULL,
                                step_title VARCHAR(150) NOT NULL,
                                step_desc TEXT,
                                status VARCHAR(20) DEFAULT 'PENDING',
                                updated_time VARCHAR(50),
                                FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

INSERT INTO users (id, first_name, last_name, email, phone, password, gender, dob, avatar_text, role, points) VALUES
                                                                                                                  (1, 'Nguyễn Văn', 'A', 'nva@gmail.com', '0987654321', '123456', 'Nam', '2005-05-20', 'DT', 'CUSTOMER', 1240),
                                                                                                                  (2, 'Trần Văn', 'B', 'tvb@switchhouse.vn', '0901234567', '123456', 'Nam', '1998-10-12', 'TH', 'SELLER', 500),
                                                                                                                  (3, 'Lương Hoàng', 'Long', 'admin@keebhub.vn', '0977000111', '123456', 'Nam', '1995-01-01', 'ADMIN', 0);

INSERT INTO shops (id, owner_id, shop_name, slug, avatar_text, avatar_color, description, address, is_verified, is_workshop, rating_avg, rating_count, follower_count, product_count) VALUES
                                                                                                                                                                                          (1, 2, 'KeebLab Store', 'keeblab-store', 'KL', '#1B64F2', 'Chuyên kit nhôm CNC và dịch vụ gia công bàn phím custom. Xưởng tại Quận Bình Thạnh, TP.HCM. Hoạt động từ 2019.', 'Bình Thạnh, TP.HCM', 1, 1, 4.9, 3200, 12400, 486),
                                                                                                                                                                                          (2, 2, 'SwitchHouse', 'switchhouse', 'SH', '#EA580C', 'Xưởng lube switch, cân stab và custom bàn phím cơ chuyên nghiệp.', 'Quận 10, TP.HCM', 1, 1, 4.8, 3204, 8912, 486),
                                                                                                                                                                                          (3, 2, 'Akko Official', 'akko-official', 'AK', '#7C3AED', 'Gian hàng phân phối chính hãng sản phẩm Akko & Monsgeek tại Việt Nam.', 'Quận 3, TP.HCM', 1, 0, 4.7, 2150, 15200, 120),
                                                                                                                                                                                          (4, 2, 'Keycap Đông Nam', 'keycap-dong-nam', 'KĐ', '#4F46E5', 'Chuyên các bộ keycap GMK, Cherry, OEM, ASA cao cấp.', 'Đống Đa, Hà Nội', 1, 1, 5.0, 980, 4200, 210),
                                                                                                                                                                                          (5, 2, 'Keychron VN', 'keychron-vn', 'KC', '#0D9488', 'Đại lý bàn phím cơ custom không dây Keychron Q-Series & V-Series.', 'Cầu Giấy, Hà Nội', 1, 0, 4.8, 1450, 9300, 95),
                                                                                                                                                                                          (6, 2, 'Monsgeek VN', 'monsgeek-vn', 'MG', '#16A34A', 'Chuyên kit nhôm CNC Monsgeek giá tốt cho người mới bắt đầu.', 'Hải Châu, Đà Nẵng', 1, 1, 4.7, 890, 6100, 84);

INSERT INTO categories (id, name, slug, icon, product_count) VALUES
                                                                 (1, 'Kit bàn phím', 'kit-ban-phim', '⌨️', 1240),
                                                                 (2, 'Switch', 'switch', '⚙️', 860),
                                                                 (3, 'Keycap', 'keycap', '🎨', 1520),
                                                                 (4, 'Stabilizer', 'stabilizer', '⚖️', 310),
                                                                 (5, 'Phụ kiện', 'phu-kien', '🔌', 980),
                                                                 (6, 'Dịch vụ gia công', 'dich-vu-gia-cong', '🛠️', 142);

INSERT INTO products (id, shop_id, category_id, sku, name, brand, short_desc, description, price, old_price, discount_percent, stock, sold_count, rating_avg, rating_count, badge, support_custom, switch_type, actuation_force, pin_type, layout, mount_type) VALUES
                                                                                                                                                                                                                                                                   (1, 1, 1, 'KH-TF60-AL', 'Kit Tofu60 2.0 Aluminium — Hotswap, gasket mount, foam sẵn', 'KBDfans', 'Tofu60 2.0 giữ nguyên khối nhôm CNC đặc trưng nhưng chuyển sang gasket mount, cho cảm giác gõ mềm và đồng đều hơn hẳn bản tray mount cũ. Bộ kit đã kèm sẵn ba lớp foam và PET sheet, nên gõ ra ngay không cần mod thêm.', 'PCB hotswap 5 chân hỗ trợ QMK/VIA, đèn south-facing nên dùng được keycap Cherry profile mà không cộm. Daughterboard tách rời giúp thay cáp dễ và giảm nhiễu.', 2690000, 3280000, 18, 38, 1200, 4.9, 218, '-18%', 1, NULL, NULL, '5-pin', '60%', 'Gasket mount'),
                                                                                                                                                                                                                                                                   (2, 2, 2, 'SW-OIL-70', 'Switch Gateron Oil King — Linear 55g (bịch 70 nút)', 'Gateron', 'Switch Linear cao cấp đã được pre-lube mượt từ nhà máy, âm trầm đục.', 'Gateron Oil King là dòng switch linear nổi tiếng với housing đen tuyền, lò xo mạ đen dài 20mm cho cảm giác nhấn đầm và trả phím nhanh.', 890000, 0, 0, 120, 430, 4.7, 145, 'Mới', 1, 'Linear', '45-55g', '5-pin', NULL, NULL),
                                                                                                                                                                                                                                                                   (3, 4, 3, 'KC-GMK-OLV', 'Keycap GMK Olivia++ Cherry profile — bộ base 137 phím', 'GMK', 'Bộ keycap ABS doubleshot cao cấp tông màu hồng đen kinh điển.', 'GMK Olivia++ sử dụng nhựa ABS cao cấp sản xuất tại Đức với ký tự doubleshot sắc nét, tương thích mọi layout từ 60% đến Fullsize.', 4150000, 0, 0, 15, 86, 5.0, 42, 'Pre-order', 0, NULL, NULL, NULL, '60%, 75%, TKL', NULL),
                                                                                                                                                                                                                                                                   (4, 5, 1, 'KH-Q1-PRO', 'Kit Keychron Q1 Pro QMK/VIA — knob, hotswap, ANSI', 'Keychron', 'Kit nhôm nguyên khối CNC layout 75% có núm xoay, kết nối Bluetooth & Type-C.', 'Keychron Q1 Pro sở hữu khung nhôm 6063 CNC hoàn toàn, cấu trúc Double-Gasket mount và mạch hotswap 5-pin hỗ trợ keymap qua VIA.', 4290000, 4790000, 10, 24, 2100, 4.8, 310, '-10%', 1, NULL, NULL, '5-pin', '75%', 'Gasket mount'),
                                                                                                                                                                                                                                                                   (5, 3, 2, 'SW-AKKO-CY', 'Switch Akko Cream Yellow V3 Pro — Linear 50g (45 nút)', 'Akko', 'Switch quốc dân cho âm thanh clacky/thocky rõ nét, stem POM chống bụi.', 'Phiên bản nâng cấp V3 Pro với chân tiếp xúc hợp kim đồng bền bỉ, lò xo 50g dễ làm quen cho cả gõ văn bản và chơi game.', 320000, 420000, 24, 260, 3400, 4.6, 520, '-24%', 1, 'Linear', '45-55g', '5-pin', NULL, NULL),
                                                                                                                                                                                                                                                                   (6, 2, 4, 'ST-DRV2', 'Stabilizer Durock V2 PCB-mount — đã lube sẵn', 'Durock', 'Bộ stab screw-in tiêu chuẩn vàng chống lọc xọc, đã được thợ lube Krytox 205g0.', 'Bộ sản phẩm gồm 4 thanh 2u và 1 thanh 6.25u/7u, ốc vít mạ vàng kèm long đền chống chập mạch.', 420000, 0, 0, 54, 760, 4.8, 190, NULL, 1, NULL, NULL, NULL, NULL, NULL),
                                                                                                                                                                                                                                                                   (7, 3, 3, 'KC-AKKO-BP', 'Keycap Akko Black & Pink ASA profile — 158 phím', 'Akko', 'Keycap nhựa PBT Double-Shot dày dặn, ASA profile bầu bĩnh dễ gõ.', 'Bộ nút phím 158 nút cân được hầu hết các chuẩn layout trên thị trường hiện nay, không bị bóng nhám sau thời gian dài sử dụng.', 690000, 890000, 22, 85, 1800, 4.7, 290, '-22%', 0, NULL, NULL, NULL, 'All layout', NULL),
                                                                                                                                                                                                                                                                   (8, 6, 1, 'KH-M1W-V3', 'Kit Monsgeek M1W V3 nhôm CNC — wireless, hotswap', 'Monsgeek', 'Kit nhôm 75% 3 chế độ kết nối có núm xoay, pin 6000mAh.', 'Lựa chọn hàng đầu trong phân khúc 2 triệu đồng với vỏ nhôm аноdized mịn màng, sẵn đầy đủ foam.', 2150000, 0, 0, 40, 540, 4.5, 98, 'Mới', 1, NULL, NULL, '5-pin', '75%', 'Gasket mount');

INSERT INTO product_options (product_id, option_group, option_name, extra_price, is_available) VALUES
                                                                                                   (1, 'COLOR', 'Silver', 0, 1),
                                                                                                   (1, 'COLOR', 'Black', 0, 1),
                                                                                                   (1, 'COLOR', 'Navy', 0, 1),
                                                                                                   (1, 'COLOR', 'E-White - hết hàng', 0, 0),
                                                                                                   (1, 'PLATE', 'Brass +350.000đ', 350000, 1),
                                                                                                   (1, 'PLATE', 'Polycarbonate', 0, 1),
                                                                                                   (1, 'PLATE', 'FR4', 0, 1),
                                                                                                   (1, 'PLATE', 'Aluminium', 0, 1);

INSERT INTO product_specs (product_id, spec_name, spec_value, display_order) VALUES
                                                                                 (1, 'Layout', '60% - 61 phím - ANSI', 1),
                                                                                 (1, 'Chất liệu vỏ', 'Nhôm CNC 6063, anodized', 2),
                                                                                 (1, 'Kiểu mount', 'Gasket mount, poron gasket 3mm', 3),
                                                                                 (1, 'PCB', 'Hotswap 5-pin, QMK/VIA, RGB south-facing', 4),
                                                                                 (1, 'Plate', 'Brass / PC / FR4 (chọn khi mua)', 5),
                                                                                 (1, 'Foam', 'Case foam + plate foam + PET sheet', 6),
                                                                                 (1, 'Kết nối', 'USB-C tháo rời, daughterboard', 7),
                                                                                 (1, 'Trọng lượng', '1.420g (chưa gồm switch, keycap)', 8),
                                                                                 (1, 'Xuất xứ', 'KBDfans · hàng chính hãng', 9),
                                                                                 (1, 'Bảo hành', '12 tháng tại KeebHub', 10);

INSERT INTO product_compatibilities (product_id, title, description, is_compatible) VALUES
                                                                                        (1, 'Switch 3 chân & 5 chân', 'PCB hotswap nhận cả hai loại, không cần cắt chân.', 1),
                                                                                        (1, 'Keycap Cherry / OEM / ASA', 'Layout ANSI chuẩn, bộ base 60% dùng được hết.', 1),
                                                                                        (1, 'Stabilizer PCB-mount screw-in', 'Durock V2, C³ Equalz, TX đều lắp vừa.', 1),
                                                                                        (1, 'Stabilizer plate-mount', 'PCB không khoét lỗ plate-mount — chọn bản screw-in.', 0),
                                                                                        (1, 'Keycap ISO / layout 65%', 'Thiếu phím cho hàng dưới, không đủ bộ.', 0),
                                                                                        (1, 'Switch có LED SMD', 'PCB south-facing, không đụng keycap Cherry profile.', 1);

INSERT INTO reviews (product_id, user_id, reviewer_name, avatar_text, rating, variant_info, comment, helpful_count, review_date) VALUES
                                                                                                                                     (1, 1, 'Nguyễn Minh', 'NM', 5, 'Phân loại: Silver / Brass plate', 'Kit hoàn thiện rất tốt, anodize đều màu, không có vết xước. Gasket êm, gõ nghe chắc chứ không vang. Đã lắp Oil King lube sẵn, tiếng rất đã. Shop đóng gói kỹ, có thêm bộ ốc dự phòng.', 24, '20/09/2026'),
                                                                                                                                     (1, 1, 'Trần Hoàng', 'TH', 4, 'Phân loại: Black / PC plate', 'Chất lượng ổn trong tầm giá. PC plate mềm hơn brass nhiều, ai thích gõ êm thì chọn. Trừ 1 sao vì giao chậm 2 ngày so với hẹn.', 24, '18/09/2026');

INSERT INTO custom_services (shop_id, service_name, price, duration_text, description, is_popular, sold_month) VALUES
                                                                                                                   (2, 'Lube cơ bản', 450000, '3–4 ngày làm việc', 'Lube housing + lò xo toàn bộ switch; Lắp ráp và test từng phím; Bảo hành 3 tháng', 0, 14),
                                                                                                                   (2, 'Full lube + tune', 750000, '5–7 ngày làm việc', 'Toàn bộ gói Lube cơ bản; Film switch (Deskeys/TX); Clip + lube + band-aid stabilizer; Tape mod & PE foam theo yêu cầu; Bảo hành 6 tháng', 1, 19),
                                                                                                                   (2, 'Premium — mod đầy đủ', 1250000, '7–10 ngày làm việc', 'Toàn bộ gói Full lube + tune; Force break mod, holee mod; Cân chỉnh âm thanh theo yêu cầu; Quay video test bàn giao; Bảo hành 12 tháng', 0, 5);