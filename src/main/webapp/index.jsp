<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.ProductDAO.CategoryStat" %>
<%@ page import="dao.ShopDAO" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%
    ProductDAO homeProductDAO = new ProductDAO();
    ShopDAO homeShopDAO = new ShopDAO();

    List<CategoryStat> categories = homeProductDAO.getAllCategoriesWithCount();
    int totalProducts = homeProductDAO.getTotalActiveProductsCount();
    List<Shop> allShops = homeShopDAO.searchShops(null, null, null, "popular");
    List<Shop> topWorkshops = homeShopDAO.searchShops(null, "workshop", null, "rating");
    List<Product> bestSellers = homeProductDAO.filterProducts(null, null, null, null, null, null, null, null, null, null, null, null, "best_selling");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KeebHub - Sàn thương mại điện tử bàn phím cơ custom</title>
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container home-page">
    <div class="hero-top-grid">
        <!-- Cột trái: Danh mục lấy trực tiếp từ bảng categories & products -->
        <aside class="sidebar-categories">
            <ul class="sidebar-list">
                <% for (int i = 0; i < categories.size(); i++) {
                    CategoryStat c = categories.get(i);
                %>
                <li class="<%= i == 0 ? "active" : "" %>">
                    <a href="category?cat=<%= c.getId() %>">
                        <span class="icon"><%= c.getIcon() %></span>
                        <%= c.getName() %>
                        <span class="count"><%= c.getProductCount() %></span>
                    </a>
                </li>
                <% } %>
                <li><a href="category?custom=1"><span class="icon">📦</span> Hỗ trợ gia công <span class="count"><%= totalProducts %></span></a></li>
                <li class="highlight"><a href="shops?type=workshop"><span class="icon">🛠️</span> Xưởng gia công <span class="count"><%= topWorkshops.size() %></span></a></li>
            </ul>
        </aside>

        <div class="main-banner">
            <div class="banner-text">
                <p class="subtitle">Sàn bàn phím custom số 1 Việt Nam</p>
                <h2>Tự build bàn phím<br>đúng gu của bạn</h2>
                <p class="desc">Chọn kit, switch, keycap và gói gia công trong một luồng duy nhất. Hệ thống tự kiểm tra tương thích trước khi bạn đặt hàng.</p>
                <div class="banner-buttons">
                    <a href="custom-builder" class="btn btn-orange">⚙️ Bắt đầu build ngay</a>
                    <a href="product-detail?id=1" class="btn btn-white">Xem build mẫu</a>
                </div>
                <div class="banner-stats">
                    <div class="stat-item"><strong><%= totalProducts %></strong><span>Sản phẩm trên sàn</span></div>
                    <div class="stat-item"><strong><%= allShops.size() %></strong><span>Gian hàng & Xưởng</span></div>
                    <div class="stat-item"><strong>100%</strong><span>Kiểm tra tương thích</span></div>
                </div>
            </div>
            <div class="banner-keeb-graphic">
                <div class="keeb-mockup">
                    <div class="keeb-row">
                        <span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span>
                    </div>
                    <div class="keeb-row">
                        <span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span>
                    </div>
                    <div class="keeb-row">
                        <span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span>
                    </div>
                    <div class="keeb-row">
                        <span class="k-key"></span><span class="k-key"></span><span class="k-key space accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="side-banners">
            <div class="small-banner group-buy-banner">
                <h4>Keycap Cao Cấp<br>GMK Olivia++</h4>
                <p>Hàng chính hãng Đức tại KeebHub</p>
                <a href="product-detail?id=3" class="link-arrow">Xem chi tiết →</a>
            </div>
            <div class="small-banner service-banner">
                <h4>Gói lube trọn bộ<br>chỉ 750.000đ</h4>
                <p>Xưởng thẩm định, bảo hành 6 tháng</p>
                <a href="product-detail?id=94" class="link-arrow green">Đặt dịch vụ →</a>
            </div>
        </div>
    </div>

    <div class="trust-bar">
        <div class="trust-item">
            <div class="trust-icon orange-bg">🚚</div>
            <div>
                <strong>Miễn phí vận chuyển</strong>
                <p>Đơn từ 500.000đ</p>
            </div>
        </div>
        <div class="trust-item">
            <div class="trust-icon red-bg">🛡️</div>
            <div>
                <strong>Bảo hành 12 tháng</strong>
                <p>Đổi mới trong 7 ngày</p>
            </div>
        </div>
        <div class="trust-item">
            <div class="trust-icon yellow-bg">🔒</div>
            <div>
                <strong>Thanh toán an toàn</strong>
                <p>Sàn giữ tiền tới khi nhận hàng</p>
            </div>
        </div>
        <div class="trust-item">
            <div class="trust-icon blue-bg">🛠️</div>
            <div>
                <strong>Xưởng gia công thẩm định</strong>
                <p><%= allShops.size() %> gian hàng đã xác minh</p>
            </div>
        </div>
    </div>

    <!-- Danh mục nổi bật lấy động từ Database -->
    <section class="home-section">
        <div class="section-head">
            <h3>Danh mục nổi bật</h3>
            <a href="category" class="view-all-link">Xem tất cả (<%= totalProducts %> sản phẩm) →</a>
        </div>
        <div class="featured-cat-grid">
            <% String[] circleColors = {"blue", "orange", "yellow", "green", "purple", "gray"};
                for (int i = 0; i < categories.size(); i++) {
                    CategoryStat c = categories.get(i);
                    String colorCls = circleColors[i % circleColors.length];
            %>
            <a href="category?cat=<%= c.getId() %>" class="cat-box">
                <div class="cat-icon-circle <%= colorCls %>"><%= c.getIcon() %></div>
                <strong><%= c.getName() %></strong>
                <span><%= c.getProductCount() %> sản phẩm</span>
            </a>
            <% } %>
        </div>
    </section>

    <section class="builder-promo-box">
        <div class="builder-promo-left">
            <span class="tag-exclusive">Tính năng độc quyền</span>
            <h3>Custom Builder — ráp phím<br>không sợ lệch linh kiện</h3>
            <p>Mỗi lựa chọn được đối chiếu tức thì với cơ sở dữ liệu tương thích: chân switch, kiểu mount stabilizer, profile keycap, độ dày plate. Sai một chi tiết là hệ thống báo ngay, kèm gợi ý thay thế.</p>
            <div class="builder-steps-pills">
                <span>1 · <strong>Kit</strong></span>
                <span>2 · <strong>Switch</strong></span>
                <span>3 · <strong>Keycap</strong></span>
                <span>4 · <strong>Gia công</strong></span>
                <span>5 · <strong>Xem lại</strong></span>
            </div>
            <div class="builder-promo-actions">
                <a href="custom-builder" class="btn btn-blue">Mở Custom Builder</a>
                <a href="category?custom=1" class="btn btn-outline-gray">Xem linh kiện tương thích</a>
            </div>
        </div>
        <div class="builder-promo-right">
            <div class="mini-build-card">
                <div class="mini-build-head">
                    <strong>Cấu hình mẫu gợi ý</strong>
                    <span class="compat-ok">✓ Tương thích</span>
                </div>
                <ul class="mini-build-list">
                    <li><span>Kit · Tofu60 2.0</span><strong>2.690.000đ</strong></li>
                    <li><span>Switch · Oil King ×70</span><strong>890.000đ</strong></li>
                    <li><span>Keycap · GMK Olivia</span><strong>4.150.000đ</strong></li>
                    <li><span>Stab · Durock V2</span><strong>420.000đ</strong></li>
                    <li><span>Gia công · Full lube</span><strong>750.000đ</strong></li>
                </ul>
                <div class="mini-build-total">
                    <span>Tổng cộng</span>
                    <strong class="total-orange">8.900.000đ</strong>
                </div>
                <div class="mini-build-hold">
                    🔒 Đã giữ chỗ tồn kho · còn <strong id="homeHoldTimer">14:22</strong>
                </div>
            </div>
        </div>
    </section>

    <!-- Flash Sale có đồng hồ đếm ngược chạy thực tế -->
    <div class="flash-sale-banner">
        <div>
            <span class="fs-subtitle">FLASH SALE ĐANG DIỄN RA</span>
            <h3>Ưu đãi giảm tới 24% Kit nhôm, Switch & Keycap</h3>
        </div>
        <div class="fs-right">
            <span class="fs-label">Kết thúc sau</span>
            <div class="fs-timer">
                <span id="fsHour">04</span> : <span id="fsMin">12</span> : <span id="fsSec">38</span>
            </div>
            <a href="category?sort=price_asc" class="btn btn-white-orange">Xem deal ngay</a>
        </div>
    </div>

    <!-- Sản phẩm bán chạy lấy trực tiếp từ bảng products trong Database -->
    <section class="home-section">
        <div class="section-head">
            <h3>Sản phẩm bán chạy trên sàn</h3>
            <a href="category?sort=best_selling" class="view-all-link">Xem tất cả <%= totalProducts %> sản phẩm →</a>
        </div>
        <div class="product-grid-6">
            <% int maxDisplay = Math.min(12, bestSellers.size());
                for (int i = 0; i < maxDisplay; i++) {
                    Product p = bestSellers.get(i);
            %>
            <a href="product-detail?id=<%= p.getId() %>" class="p-card">
                <% if (p.getBadge() != null && !p.getBadge().isEmpty()) { %>
                <span class="p-badge <%= p.getBadge().contains("%") ? "discount" : "new" %>"><%= p.getBadge() %></span>
                <% } %>
                <span class="p-wish">♡</span>
                <div class="p-thumb">
                    <% if (p.getCategoryId() == 1) { %>
                    <div class="illus-kit"></div>
                    <% } else if (p.getCategoryId() == 2) { %>
                    <div class="illus-switch yellow"></div>
                    <% } else if (p.getCategoryId() == 3) { %>
                    <div class="illus-keycap"></div>
                    <% } else { %>
                    <div class="illus-switch purple"></div>
                    <% } %>
                </div>
                <div class="p-Shop"><span class="dot-green"></span> <%= p.getShopName() %></div>
                <h4 class="p-name"><%= p.getName() %></h4>
                <div class="p-price">
                    <%= p.getFormattedPrice() %>
                    <% if (p.getOldPrice() > 0) { %>
                    <del><%= p.getFormattedOldPrice() %></del>
                    <% } %>
                </div>
                <div class="p-meta">
                    <span class="stars">★★★★★ <%= p.getRatingAvg() %></span>
                    <span>Đã bán <%= p.getFormattedSoldCount() %></span>
                </div>
            </a>
            <% } %>
        </div>
    </section>

    <!-- Danh sách Xưởng gia công uy tín lấy trực tiếp từ 30 shops trong Database -->
    <section class="home-section">
        <div class="section-head">
            <h3>Xưởng gia công uy tín (<%= topWorkshops.size() %> xưởng)</h3>
            <a href="shops" class="view-all-link">Xem tất cả <%= allShops.size() %> gian hàng →</a>
        </div>
        <div class="shop-cards-grid">
            <% int maxShops = Math.min(8, topWorkshops.size());
                for (int i = 0; i < maxShops; i++) {
                    Shop s = topWorkshops.get(i);
            %>
            <a href="shop?id=<%= s.getId() %>" class="shop-mini-card">
                <div class="shop-avatar" style="background:<%= s.getAvatarColor() != null ? s.getAvatarColor() : "#1B64F2" %>;"><%= s.getAvatarText() %></div>
                <div class="shop-mini-info">
                    <strong><%= s.getShopName() %></strong>
                    <p>★ <%= s.getRatingAvg() %> · <%= s.getFormattedFollowers() %> theo dõi · <%= s.getProductCount() %> SP</p>
                    <div class="shop-badges">
                        <% if (s.isVerified()) { %>
                        <span class="s-badge verified">Đã xác minh</span>
                        <% } %>
                        <% if (s.isWorkshop()) { %>
                        <span class="s-badge workshop">Xưởng gia công</span>
                        <% } %>
                    </div>
                </div>
            </a>
            <% } %>
        </div>
    </section>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    // 1. Đồng hồ đếm ngược Flash Sale chạy thực tế
    (function() {
        let fsTotalSeconds = 4 * 3600 + 12 * 60 + 38;
        const hEl = document.getElementById('fsHour');
        const mEl = document.getElementById('fsMin');
        const sEl = document.getElementById('fsSec');
        if (hEl && mEl && sEl) {
            setInterval(() => {
                if (fsTotalSeconds > 0) fsTotalSeconds--;
                else fsTotalSeconds = 4 * 3600;
                const h = Math.floor(fsTotalSeconds / 3600);
                const m = Math.floor((fsTotalSeconds % 3600) / 60);
                const s = fsTotalSeconds % 60;
                hEl.textContent = String(h).padStart(2, '0');
                mEl.textContent = String(m).padStart(2, '0');
                sEl.textContent = String(s).padStart(2, '0');
            }, 1000);
        }

        // 2. Đồng hồ giữ chỗ tồn kho trên thẻ Cấu hình mẫu
        let holdSeconds = 14 * 60 + 22;
        const holdEl = document.getElementById('homeHoldTimer');
        if (holdEl) {
            setInterval(() => {
                if (holdSeconds > 0) holdSeconds--;
                else holdSeconds = 15 * 60;
                const m = Math.floor(holdSeconds / 60);
                const s = holdSeconds % 60;
                holdEl.textContent = String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
            }, 1000);
        }
    })();
</script>
</body>
</html>