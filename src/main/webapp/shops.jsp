<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.ShopDAO" %>
<%@ page import="java.util.List" %>
<%
    List<Shop> shops = (List<Shop>) request.getAttribute("shops");
    String keyword = (String) request.getAttribute("keyword");
    Boolean workshopOnly = (Boolean) request.getAttribute("workshopOnly");
    Boolean verifiedOnly = (Boolean) request.getAttribute("verifiedOnly");
    String sort = (String) request.getAttribute("sort");

    if (shops == null) {
        keyword = request.getParameter("keyword");
        workshopOnly = "1".equals(request.getParameter("workshop"));
        verifiedOnly = "1".equals(request.getParameter("verified"));
        sort = request.getParameter("sort");
        if (sort == null || sort.isEmpty()) sort = "rating";

        ShopDAO sDao = new ShopDAO();
        shops = sDao.searchShops(keyword, workshopOnly, verifiedOnly, sort);
    }
    if (sort == null || sort.isEmpty()) sort = "rating";
    if (workshopOnly == null) workshopOnly = false;
    if (verifiedOnly == null) verifiedOnly = false;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tìm kiếm gian hàng & Xưởng gia công - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <strong>Tìm kiếm Gian hàng & Xưởng gia công</strong>
    </div>

    <!-- Hero Banner Gian hàng -->
    <div class="shops-hero-banner">
        <div>
            <h2>Gian hàng & Xưởng custom phím cơ</h2>
            <p>Khám phá các thương hiệu phân phối chính hãng, xưởng lube switch, cân stab và gia công bàn phím custom uy tín tại Việt Nam.</p>
        </div>
        <div class="keeb-mockup" style="transform: scale(0.85); transform-origin: right center;">
            <div class="keeb-row"><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span></div>
            <div class="keeb-row"><span class="k-key"></span><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span></div>
        </div>
    </div>

    <!-- Thanh Tìm kiếm & Lọc gian hàng -->
    <div class="shop-search-control-bar">
        <form action="shops" method="GET" class="shop-search-form" id="shopSearchForm">
            <div class="shop-search-input-wrap">
                <span class="search-icon">🔍</span>
                <input type="text" name="keyword" placeholder="Tìm tên gian hàng, xưởng, địa chỉ TP.HCM, Hà Nội..." value="<%= keyword != null ? keyword : "" %>">
            </div>
            <% if (workshopOnly) { %>
            <input type="hidden" name="workshop" value="1">
            <% } %>
            <% if (verifiedOnly) { %>
            <input type="hidden" name="verified" value="1">
            <% } %>
            <input type="hidden" name="sort" id="shopSortInput" value="<%= sort %>">
            <button type="submit" class="btn btn-blue" style="height:42px;padding:0 20px;font-weight:700;">Tìm shop</button>
        </form>

        <div class="shop-filter-chips">
            <span style="font-size:13px;color:#64748B;font-weight:600;">Lọc theo:</span>
            <a href="shops?<%= keyword != null && !keyword.isEmpty() ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %>sort=<%= sort %>"
               class="chip-btn <%= (!workshopOnly && !verifiedOnly) ? "active" : "" %>">Tất cả</a>
            <a href="shops?<%= keyword != null && !keyword.isEmpty() ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %><%= !workshopOnly ? "workshop=1&" : "" %><%= verifiedOnly ? "verified=1&" : "" %>sort=<%= sort %>"
               class="chip-btn <%= workshopOnly ? "active" : "" %>">🛠️ Xưởng gia công</a>
            <a href="shops?<%= keyword != null && !keyword.isEmpty() ? "keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") + "&" : "" %><%= workshopOnly ? "workshop=1&" : "" %><%= !verifiedOnly ? "verified=1&" : "" %>sort=<%= sort %>"
               class="chip-btn <%= verifiedOnly ? "active" : "" %>">✓ Đã xác minh</a>
        </div>
    </div>

    <!-- Thanh Header Sắp xếp gian hàng -->
    <div class="sort-header-bar" style="margin-bottom: 20px;">
        <span class="s-label">Sắp xếp theo</span>
        <button type="button" class="sort-pill-btn <%= "rating".equals(sort) ? "active" : "" %>" onclick="submitShopSort('rating')">Đánh giá cao nhất</button>
        <button type="button" class="sort-pill-btn <%= "followers".equals(sort) ? "active" : "" %>" onclick="submitShopSort('followers')">Nhiều người theo dõi</button>
        <button type="button" class="sort-pill-btn <%= "products".equals(sort) ? "active" : "" %>" onclick="submitShopSort('products')">Nhiều sản phẩm</button>
        <button type="button" class="sort-pill-btn <%= "name_asc".equals(sort) ? "active" : "" %>" onclick="submitShopSort('name_asc')">Tên A → Z</button>
        <span class="sort-right-count">Tìm thấy <strong><%= shops.size() %></strong> gian hàng</span>
    </div>

    <% if (shops.isEmpty()) { %>
    <div style="background:#FFF;border:1px solid #E2E8F0;border-radius:14px;padding:48px;text-align:center;margin-bottom:32px;">
        <div style="font-size:48px;margin-bottom:12px;">🏪</div>
        <h3 style="margin-bottom:8px;">Không tìm thấy gian hàng nào</h3>
        <p style="color:#64748B;margin-bottom:16px;">Hãy thử tìm kiếm với từ khoá khác hoặc gỡ bỏ bộ lọc hiện tại.</p>
        <a href="shops" class="btn btn-blue">Xem tất cả gian hàng</a>
    </div>
    <% } else { %>
    <div class="shop-list-grid">
        <% for (Shop s : shops) { %>
        <div class="shop-full-card">
            <div>
                <div class="shop-card-header">
                    <div class="shop-card-avatar" style="background-color: <%= s.getAvatarColor() != null ? s.getAvatarColor() : "#1B64F2" %>">
                        <%= s.getAvatarText() %>
                    </div>
                    <div class="shop-card-meta">
                        <h3><%= s.getShopName() %></h3>
                        <div class="shop-badges">
                            <% if (s.isVerified()) { %>
                            <span class="s-badge verified">✓ Đã xác minh</span>
                            <% } %>
                            <% if (s.isWorkshop()) { %>
                            <span class="s-badge workshop">🛠️ Xưởng gia công</span>
                            <% } %>
                        </div>
                    </div>
                </div>

                <p class="shop-card-desc"><%= s.getDescription() %></p>

                <div class="shop-metrics-grid">
                    <div class="shop-metric-cell">
                        <strong style="color:#F59E0B;">★ <%= s.getRatingAvg() %></strong>
                        <span><%= s.getFormattedRatingCount() %> đánh giá</span>
                    </div>
                    <div class="shop-metric-cell">
                        <strong><%= s.getFormattedFollowers() %></strong>
                        <span>Theo dõi</span>
                    </div>
                    <div class="shop-metric-cell">
                        <strong><%= s.getProductCount() %></strong>
                        <span>Sản phẩm</span>
                    </div>
                </div>

                <div class="shop-card-extra">
                    <div>📍 <strong>Địa chỉ:</strong> <%= s.getAddress() %></div>
                    <div>🕒 <strong>Giờ làm việc:</strong> <%= s.getWorkingHours() %></div>
                    <div>⚡ <strong>Giao đúng hẹn:</strong> <span style="color:#15803D;font-weight:700;"><%= s.getOnTimeRate() %>%</span> · Phản hồi: <%= s.getResponseRate() %>%</div>
                </div>
            </div>

            <div class="shop-card-actions">
                <a href="shop?id=<%= s.getId() %>" class="btn btn-blue" style="font-weight:700;">Vào gian hàng →</a>
                <button type="button" class="btn btn-outline-gray" onclick="alert('Đang kết nối chat với <%= s.getShopName() %>...')">💬 Chat</button>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    function submitShopSort(sortVal) {
        document.getElementById('shopSortInput').value = sortVal;
        document.getElementById('shopSearchForm').submit();
    }
</script>

</body>
</html>
