<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%
    List<Shop> shops      = (List<Shop>) request.getAttribute("shops");
    String keyword        = (String)  request.getAttribute("keyword");
    String type           = (String)  request.getAttribute("type");
    String sort           = (String)  request.getAttribute("sort");
    Double minRating      = (Double)  request.getAttribute("minRating");
    int    totalShops     = (Integer) request.getAttribute("totalShops");
    if (keyword  == null) keyword  = "";
    if (type     == null) type     = "";
    if (sort     == null) sort     = "popular";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tìm kiếm gian hàng - KeebHub</title>
    <meta name="description" content="Khám phá tất cả gian hàng và xưởng gia công bàn phím custom uy tín trên KeebHub.">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
    <link rel="stylesheet" href="assets/css/shops.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <!-- Breadcrumb -->
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <strong>Tìm kiếm gian hàng</strong>
    </div>

    <!-- Hero Banner -->
    <div class="shops-hero-banner">
        <div class="shops-hero-text">
            <h2>🏪 Gian hàng & Xưởng gia công</h2>
            <p>Khám phá <%= totalShops %> gian hàng uy tín chuyên về bàn phím custom — từ kit nhôm CNC, switch, keycap đến dịch vụ lube và gia công chuyên nghiệp.</p>
            <div class="shops-hero-pills">
                <span>✓ Đã xác minh</span>
                <span>🛠️ Xưởng gia công</span>
                <span>⭐ Đánh giá cao</span>
                <span>📦 Hàng chính hãng</span>
            </div>
        </div>
        <div class="shops-hero-stat">
            <div class="shops-stat-box"><strong><%= totalShops %></strong><span>Gian hàng</span></div>
            <div class="shops-stat-box"><strong>4.8★</strong><span>TB đánh giá</span></div>
            <div class="shops-stat-box"><strong>98%</strong><span>Phản hồi chat</span></div>
        </div>
    </div>

    <!-- Search + Filter Bar -->
    <div class="shops-search-bar-wrap">
        <form action="shops" method="GET" id="shopsSearchForm" class="shops-search-form">
            <!-- Thanh tìm kiếm -->
            <div class="shops-search-field">
                <span class="shops-search-icon">🔍</span>
                <input type="text"
                       id="shopKeywordInput"
                       name="keyword"
                       class="shops-search-input"
                       placeholder="Tên gian hàng, địa chỉ, loại sản phẩm..."
                       value="<%= keyword %>"
                       autocomplete="off">
                <% if (!keyword.isEmpty()) { %>
                <button type="button" class="shops-clear-btn" onclick="clearSearch()">✕</button>
                <% } %>
            </div>

            <!-- Lọc nhanh -->
            <div class="shops-filter-pills">
                <span class="shops-filter-label">Loại:</span>
                <a href="shops?keyword=<%= keyword %>&sort=<%= sort %>"
                   class="shops-fpill <%= type.isEmpty() ? "active" : "" %>">Tất cả</a>
                <a href="shops?keyword=<%= keyword %>&type=workshop&sort=<%= sort %>"
                   class="shops-fpill <%= "workshop".equals(type) ? "active" : "" %>">🛠️ Xưởng gia công</a>
                <a href="shops?keyword=<%= keyword %>&type=verified&sort=<%= sort %>"
                   class="shops-fpill <%= "verified".equals(type) ? "active" : "" %>">✓ Đã xác minh</a>
            </div>

            <!-- Đánh giá tối thiểu -->
            <div class="shops-filter-pills">
                <span class="shops-filter-label">Đánh giá tối thiểu:</span>
                <a href="shops?keyword=<%= keyword %>&type=<%= type %>&sort=<%= sort %>"
                   class="shops-fpill <%= minRating == null ? "active" : "" %>">Tất cả</a>
                <a href="shops?keyword=<%= keyword %>&type=<%= type %>&minRating=4.5&sort=<%= sort %>"
                   class="shops-fpill <%= minRating != null && minRating == 4.5 ? "active" : "" %>">★ 4.5+</a>
                <a href="shops?keyword=<%= keyword %>&type=<%= type %>&minRating=4.8&sort=<%= sort %>"
                   class="shops-fpill <%= minRating != null && minRating == 4.8 ? "active" : "" %>">★ 4.8+</a>
                <a href="shops?keyword=<%= keyword %>&type=<%= type %>&minRating=5.0&sort=<%= sort %>"
                   class="shops-fpill <%= minRating != null && minRating == 5.0 ? "active" : "" %>">★ 5.0</a>
            </div>
        </form>
    </div>

    <!-- Sort bar + kết quả -->
    <div class="shops-result-header">
        <div class="shops-result-count">
            <% if (!keyword.isEmpty()) { %>
            Kết quả tìm kiếm cho "<strong><%= keyword %></strong>":
            <% } %>
            <strong style="color:#1B64F2"><%= totalShops %></strong> gian hàng
        </div>
        <div class="shops-sort-pills">
            <span class="shops-filter-label">Sắp xếp:</span>
            <a href="shops?keyword=<%= keyword %>&type=<%= type %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=popular"
               class="sort-pill-btn <%= "popular".equals(sort) ? "active" : "" %>">🔥 Phổ biến</a>
            <a href="shops?keyword=<%= keyword %>&type=<%= type %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=rating"
               class="sort-pill-btn <%= "rating".equals(sort) ? "active" : "" %>">⭐ Đánh giá cao</a>
            <a href="shops?keyword=<%= keyword %>&type=<%= type %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=followers"
               class="sort-pill-btn <%= "followers".equals(sort) ? "active" : "" %>">👥 Nhiều người theo dõi</a>
            <a href="shops?keyword=<%= keyword %>&type=<%= type %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=newest"
               class="sort-pill-btn <%= "newest".equals(sort) ? "active" : "" %>">🆕 Mới nhất</a>
        </div>
    </div>

    <!-- Active Filters display -->
    <% boolean hasActiveFilter = !keyword.isEmpty() || !type.isEmpty() || minRating != null; %>
    <% if (hasActiveFilter) { %>
    <div class="active-filter-bar" style="margin-bottom:16px;">
        <span class="af-label">Đang lọc:</span>
        <% if (!keyword.isEmpty()) { %>
        <span class="af-tag">🔍 "<%= keyword %>" <a href="shops?type=<%= type %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=<%= sort %>" style="color:#1B64F2;margin-left:4px;">✕</a></span>
        <% } %>
        <% if ("workshop".equals(type)) { %>
        <span class="af-tag">🛠️ Xưởng gia công <a href="shops?keyword=<%= keyword %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=<%= sort %>" style="color:#1B64F2;margin-left:4px;">✕</a></span>
        <% } else if ("verified".equals(type)) { %>
        <span class="af-tag">✓ Đã xác minh <a href="shops?keyword=<%= keyword %><%= minRating != null ? "&minRating=" + minRating : "" %>&sort=<%= sort %>" style="color:#1B64F2;margin-left:4px;">✕</a></span>
        <% } %>
        <% if (minRating != null) { %>
        <span class="af-tag">★ <%= minRating %>+ <a href="shops?keyword=<%= keyword %>&type=<%= type %>&sort=<%= sort %>" style="color:#1B64F2;margin-left:4px;">✕</a></span>
        <% } %>
        <a href="shops" class="af-clear">Xóa tất cả bộ lọc</a>
    </div>
    <% } %>

    <!-- Danh sách gian hàng -->
    <% if (shops == null || shops.isEmpty()) { %>
    <div class="shops-empty-state">
        <div class="shops-empty-icon">🏪</div>
        <h3>Không tìm thấy gian hàng nào</h3>
        <p>Thử thay đổi từ khóa hoặc xóa bộ lọc để xem thêm kết quả.</p>
        <a href="shops" class="btn-apply-filter" style="display:inline-block;padding:10px 24px;text-decoration:none;border-radius:8px;">Xem tất cả gian hàng</a>
    </div>
    <% } else { %>
    <div class="shops-grid">
        <% for (Shop s : shops) { %>
        <a href="shop?id=<%= s.getId() %>" class="shop-card-link">
            <div class="shop-card">
                <!-- Avatar + Badge -->
                <div class="shop-card-top">
                    <div class="shop-card-avatar" style="background:<%= s.getAvatarColor() != null ? s.getAvatarColor() : "#1B64F2" %>;">
                        <%= s.getAvatarText() %>
                    </div>
                    <div class="shop-card-badges">
                        <% if (s.isVerified()) { %>
                        <span class="sc-badge verified">✓ Xác minh</span>
                        <% } %>
                        <% if (s.isWorkshop()) { %>
                        <span class="sc-badge workshop">🛠️ Xưởng</span>
                        <% } %>
                    </div>
                    <div class="shop-card-rating">
                        <span class="sc-star">★</span> <%= s.getRatingAvg() %>
                        <span class="sc-rating-count">(<%= s.getFormattedRatingCount() %>)</span>
                    </div>
                </div>

                <!-- Info -->
                <div class="shop-card-body">
                    <h3 class="shop-card-name"><%= s.getShopName() %></h3>
                    <p class="shop-card-desc"><%= s.getDescription() != null ? (s.getDescription().length() > 85 ? s.getDescription().substring(0, 85) + "…" : s.getDescription()) : "" %></p>
                    <% if (s.getAddress() != null && !s.getAddress().isEmpty()) { %>
                    <div class="shop-card-address">📍 <%= s.getAddress() %></div>
                    <% } %>
                </div>

                <!-- KPIs -->
                <div class="shop-card-kpis">
                    <div class="shop-card-kpi">
                        <strong><%= s.getProductCount() %></strong>
                        <span>Sản phẩm</span>
                    </div>
                    <div class="shop-card-kpi">
                        <strong><%= s.getFormattedFollowers() %></strong>
                        <span>Theo dõi</span>
                    </div>
                    <div class="shop-card-kpi">
                        <strong><%= s.getResponseRate() %>%</strong>
                        <span>Phản hồi</span>
                    </div>
                    <div class="shop-card-kpi">
                        <strong><%= s.getOnTimeRate() %>%</strong>
                        <span>Đúng hẹn</span>
                    </div>
                </div>

                <!-- Footer -->
                <div class="shop-card-footer">
                    <span class="shop-card-joined">Tham gia <%= s.getJoinedDate() %></span>
                    <span class="shop-card-cta">Xem gian hàng →</span>
                </div>
            </div>
        </a>
        <% } %>
    </div>
    <% } %>

</main>

<jsp:include page="includes/footer.jsp" />

<script>
function clearSearch() {
    var input = document.getElementById('shopKeywordInput');
    if (input) {
        input.value = '';
        document.getElementById('shopsSearchForm').submit();
    }
}

// Live search với debounce
(function() {
    var input = document.getElementById('shopKeywordInput');
    if (!input) return;
    var timer;
    input.addEventListener('input', function() {
        clearTimeout(timer);
        timer = setTimeout(function() {
            document.getElementById('shopsSearchForm').submit();
        }, 500);
    });
})();
</script>

</body>
</html>
