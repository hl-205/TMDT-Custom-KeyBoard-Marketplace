<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="dao.ProductDAO.CategoryStat" %>
<%@ page import="dao.ShopDAO" %>
<%@ page import="dao.CustomOrderDAO" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%
    ProductDAO homeProductDAO = new ProductDAO();
    ShopDAO homeShopDAO = new ShopDAO();
    CustomOrderDAO homeOrderDAO = new CustomOrderDAO();

    List<CategoryStat> categories = homeProductDAO.getAllCategoriesWithCount();
    int totalProductsCount = homeProductDAO.getTotalActiveProductsCount();
    List<Shop> allShops = homeShopDAO.getAllShops();
    List<Shop> workshopShops = homeShopDAO.searchShops(null, "workshop", null, "rating");
    int totalOrdersCount = homeOrderDAO.countOrdersByStatus("ALL", false);

    List<Product> bestSellingList = homeProductDAO.filterProducts(
            null, null, null, null, null, null, null, null, null, false, false, null, "best_selling"
    );
    List<Product> topProducts = bestSellingList.size() > 12 ? bestSellingList.subList(0, 12) : bestSellingList;
    List<Shop> featuredWorkshops = workshopShops.size() > 8 ? workshopShops.subList(0, 8) : workshopShops;

    String[] circleColors = {"blue", "orange", "yellow", "green", "purple", "gray"};
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
        <!-- Cột danh mục bên trái lấy số lượng thật từ bảng categories & products -->
        <aside class="sidebar-categories">
            <ul class="sidebar-list">
                <% for (int i = 0; i < categories.size(); i++) {
                    CategoryStat cs = categories.get(i);
                %>
                <li class="<%= i == 0 ? "active" : "" %>">
                    <a href="category?cat=<%= cs.getId() %>">
                        <span class="icon"><%= cs.getIcon() %></span>
                        <%= cs.getName() %>
                        <span class="count"><%= cs.getProductCount() %></span>
                    </a>
                </li>
                <% } %>
                <li>
                    <a href="shops">
                        <span class="icon">🏪</span> Hệ thống Gian hàng
                        <span class="count"><%= allShops.size() %></span>
                    </a>
                </li>
                <li>
                    <a href="shops?type=workshop">
                        <span class="icon">🛠️</span> Xưởng nhận Build
                        <span class="count"><%= workshopShops.size() %></span>
                    </a>
                </li>
                <li class="highlight">
                    <a href="custom-builder">
                        <span class="icon">⚙️</span> Custom Builder
                        <span class="count">5 bước</span>
                    </a>
                </li>
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
                    <div class="stat-item"><strong><%= totalProductsCount %></strong><span>Sản phẩm trong DB</span></div>
                    <div class="stat-item"><strong><%= allShops.size() %></strong><span>Gian hàng & Xưởng</span></div>
                    <div class="stat-item"><strong><%= totalOrdersCount %></strong><span>Đơn trên hệ thống</span></div>
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
                <p>Hàng chính hãng Đức tại Keycap Đông Nam</p>
                <a href="product-detail?id=3" class="link-arrow">Xem chi tiết →</a>
            </div>
            <div class="small-banner service-banner">
                <h4>Gói Full Lube + Tune<br>chỉ 750.000đ</h4>
                <p>Xưởng SwitchHouse thẩm định, BH 6 tháng</p>
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
                <p><%= workshopShops.size() %> xưởng chuyên nghiệp</p>
            </div>
        </div>
    </div>

    <!-- Danh mục nổi bật lấy trực tiếp từ bảng categories -->
    <section class="home-section">
        <div class="section-head">
            <h3>Danh mục nổi bật</h3>
            <a href="category" class="view-all-link">Xem tất cả (<%= totalProductsCount %> sản phẩm) →</a>
        </div>
        <div class="featured-cat-grid">
            <% for (int i = 0; i < categories.size(); i++) {
                CategoryStat cs = categories.get(i);
                String colorCls = circleColors[i % circleColors.length];
            %>
            <a href="category?cat=<%= cs.getId() %>" class="cat-box">
                <div class="cat-icon-circle <%= colorCls %>"><%= cs.getIcon() %></div>
                <strong><%= cs.getName() %></strong>
                <span><%= cs.getProductCount() %> sản phẩm</span>
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
                <a href="category?custom=1" class="btn btn-outline-gray">Xem linh kiện hỗ trợ Custom</a>
            </div>
        </div>
        <div class="builder-promo-right">
            <div class="mini-build-card">
                <div class="mini-build-head">
                    <strong>Cấu hình mẫu #1</strong>
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

    <!-- Flash Sale có đồng hồ đếm ngược thực tế từng giây -->
    <div class="flash-sale-banner">
        <div>
            <span class="fs-subtitle">FLASH SALE ĐANG DIỄN RA</span>
            <h3>Ưu đãi giảm giá linh kiện Switch, Keycap & Kit nhôm CNC</h3>
        </div>
        <div class="fs-right">
            <span class="fs-label">Kết thúc sau</span>
            <div class="fs-timer">
                <span id="fsHours">04</span> <span id="fsMinutes">12</span> <span id="fsSeconds">38</span>
            </div>
            <a href="category?sort=popular" class="btn btn-white-orange">Xem deal ngay</a>
        </div>
    </div>

    <!-- Sản phẩm bán chạy lấy trực tiếp Top 12 từ Database -->
    <section class="home-section">
        <div class="section-head">
            <h3>Sản phẩm bán chạy nhất</h3>
            <a href="category?sort=best_selling" class="view-all-link">Xem tất cả <%= totalProductsCount %> sản phẩm →</a>
        </div>
        <div class="product-grid-6">
            <% for (Product p : topProducts) { %>
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

    <!-- Xưởng gia công uy tín lấy trực tiếp từ bảng shops -->
    <section class="home-section">
        <div class="section-head">
            <h3>Xưởng gia công & Gian hàng tiêu biểu</h3>
            <a href="shops" class="view-all-link">Xem toàn bộ <%= allShops.size() %> gian hàng →</a>
        </div>
        <div class="shop-cards-grid">
            <% for (Shop s : featuredWorkshops) { %>
            <a href="shop?id=<%= s.getId() %>" class="shop-mini-card">
                <div class="shop-avatar" style="background:<%= s.getAvatarColor() %>;"><%= s.getAvatarText() %></div>
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
    // Đồng hồ đếm ngược Flash Sale và Giữ chỗ tồn kho chạy thực tế từng giây
    document.addEventListener("DOMContentLoaded", function() {
        let fsTotalSec = 4 * 3600 + 12 * 60 + 38;
        const hEl = document.getElementById("fsHours");
        const mEl = document.getElementById("fsMinutes");
        const sEl = document.getElementById("fsSeconds");

        let holdTotalSec = 14 * 60 + 22;
        const holdEl = document.getElementById("homeHoldTimer");

        setInterval(function() {
            if (fsTotalSec > 0) {
                fsTotalSec--;
                const h = Math.floor(fsTotalSec / 3600);
                const m = Math.floor((fsTotalSec % 3600) / 60);
                const s = fsTotalSec % 60;
                if (hEl) hEl.textContent = String(h).padStart(2, '0');
                if (mEl) mEl.textContent = String(m).padStart(2, '0');
                if (sEl) sEl.textContent = String(s).padStart(2, '0');
            }
            if (holdTotalSec > 0) {
                holdTotalSec--;
                const hm = Math.floor(holdTotalSec / 60);
                const hs = holdTotalSec % 60;
                if (holdEl) holdEl.textContent = String(hm).padStart(2, '0') + ":" + String(hs).padStart(2, '0');
            }
        }, 1000);
    });
</script>
</body>
</html>