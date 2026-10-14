<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Shop" %>
<%@ page import="java.util.List" %>
<%
    if (request.getAttribute("products") == null) {
        String qs = request.getQueryString();
        response.sendRedirect("category" + (qs != null && !qs.isEmpty() ? "?" + qs : ""));
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Shop> matchedShops = (List<Shop>) request.getAttribute("matchedShops");
    Integer catId = (Integer) request.getAttribute("catId");
    String keyword = (String) request.getAttribute("keyword");
    List<String> selectedBrands = (List<String>) request.getAttribute("selectedBrands");
    List<String> selectedSwitchTypes = (List<String>) request.getAttribute("selectedSwitchTypes");
    List<String> selectedForces = (List<String>) request.getAttribute("selectedForces");
    List<String> selectedLayouts = (List<String>) request.getAttribute("selectedLayouts");
    List<String> selectedMounts = (List<String>) request.getAttribute("selectedMounts");
    Long minPrice = (Long) request.getAttribute("minPrice");
    Long maxPrice = (Long) request.getAttribute("maxPrice");
    Boolean inStock = (Boolean) request.getAttribute("inStock");
    Boolean supportCustom = (Boolean) request.getAttribute("supportCustom");
    Double minRating = (Double) request.getAttribute("minRating");
    String sort = (String) request.getAttribute("sort");
    List<String> activeTags = (List<String>) request.getAttribute("activeTags");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lọc & Tìm kiếm sản phẩm - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <strong><%= (keyword != null && !keyword.isEmpty()) ? "Kết quả tìm kiếm" : "Danh mục sản phẩm" %></strong>
    </div>

    <% if (keyword != null && !keyword.isEmpty()) { %>
    <!-- Giao diện Header Tìm kiếm chuẩn Frame 04 -->
    <div class="search-title-block">
        <h2>Kết quả cho “<%= keyword %>”</h2>
        <p>Tìm thấy <strong><%= products.size() %></strong> sản phẩm<%= (matchedShops != null && !matchedShops.isEmpty()) ? " và <strong>" + matchedShops.size() + "</strong> gian hàng" : "" %> · <a href="#" style="color:#1B64F2;font-weight:700;">Lưu tìm kiếm này</a></p>
    </div>

    <% if (matchedShops != null && !matchedShops.isEmpty()) { %>
    <!-- Khối Gian hàng liên quan khi tìm kiếm theo tên shop -->
    <div class="matched-shops-block">
        <div class="matched-shops-title">
            <span>🏪 Gian hàng liên quan</span>
            <a href="shops?keyword=<%= java.net.URLEncoder.encode(keyword, "UTF-8") %>">Xem tất cả gian hàng →</a>
        </div>
        <div class="matched-shops-grid">
            <% for (Shop ms : matchedShops) { %>
            <div class="matched-shop-card">
                <div class="shop-avatar" style="background-color: <%= ms.getAvatarColor() != null ? ms.getAvatarColor() : "#1B64F2" %>"><%= ms.getAvatarText() %></div>
                <div class="matched-shop-details">
                    <div class="matched-shop-head">
                        <h4><%= ms.getShopName() %></h4>
                        <% if (ms.isVerified()) { %>
                        <span class="s-badge verified">✓ Đã xác minh</span>
                        <% } %>
                        <% if (ms.isWorkshop()) { %>
                        <span class="s-badge workshop">🛠️ Xưởng</span>
                        <% } %>
                    </div>
                    <p class="matched-shop-desc"><%= ms.getDescription() %></p>
                    <div class="matched-shop-stats">
                        <span>★ <strong><%= ms.getRatingAvg() %></strong></span>
                        <span>·</span>
                        <span><strong><%= ms.getFormattedFollowers() %></strong> theo dõi</span>
                        <span>·</span>
                        <span><strong><%= ms.getProductCount() %></strong> sp</span>
                        <span>·</span>
                        <span>📍 <%= ms.getAddress() %></span>
                    </div>
                </div>
                <div class="matched-shop-action">
                    <a href="shop?id=<%= ms.getId() %>" class="btn btn-blue btn-sm">Xem Shop →</a>
                </div>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>
    <% } else { %>
    <!-- Giao diện Banner Danh mục chuẩn Frame 03 -->
    <div class="cat-hero-banner">
        <div>
            <h2>Kit bàn phím cơ & Linh kiện Custom</h2>
            <p>1.240 sản phẩm từ 86 shop đã xác minh. Mọi kit đều có dữ liệu tương thích để dùng ngay trong Custom Builder.</p>
            <div class="cat-hero-pills">
                <span>Hotswap</span>
                <span>Gasket mount</span>
                <span>Có sẵn tại VN</span>
                <span>Hỗ trợ QMK/VIA</span>
                <span>Tri-mode</span>
            </div>
        </div>
        <div class="keeb-mockup">
            <div class="keeb-row"><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span></div>
            <div class="keeb-row"><span class="k-key"></span><span class="k-key"></span><span class="k-key accent"></span><span class="k-key"></span><span class="k-key"></span><span class="k-key"></span></div>
            <div class="keeb-row"><span class="k-key"></span><span class="k-key space accent"></span><span class="k-key"></span></div>
        </div>
    </div>
    <% } %>

    <% if (activeTags != null && !activeTags.isEmpty()) { %>
    <div class="active-filter-bar">
        <span class="af-label">Đang lọc:</span>
        <% for (String tag : activeTags) { %>
        <span class="af-tag"><%= tag %> ✕</span>
        <% } %>
        <a href="category" class="af-clear">Xoá tất cả</a>
    </div>
    <% } %>

    <form action="category" method="GET" id="filterForm">
        <% if (keyword != null && !keyword.isEmpty()) { %>
        <input type="hidden" name="keyword" value="<%= keyword %>">
        <% } %>
        <% if (catId != null) { %>
        <input type="hidden" name="cat" value="<%= catId %>">
        <% } %>
        <input type="hidden" name="sort" id="sortHiddenInput" value="<%= sort %>">

        <div class="filter-page-grid">
            <!-- Cột Trái: Bộ lọc đa tiêu chí -->
            <aside class="filter-panel-card">
                <div class="filter-panel-head">
                    <h3>Bộ lọc</h3>
                    <a href="category">Xoá tất cả</a>
                </div>

                <!-- Tiêu chí 1: Thương hiệu -->
                <div class="f-section">
                    <h4>Thương hiệu</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="KBDfans" <%= selectedBrands.contains("KBDfans") ? "checked" : "" %>>
                        <span>KBDfans</span><span class="f-cnt">128</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Gateron" <%= selectedBrands.contains("Gateron") ? "checked" : "" %>>
                        <span>Gateron</span><span class="f-cnt">210</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Akko" <%= selectedBrands.contains("Akko") ? "checked" : "" %>>
                        <span>Akko</span><span class="f-cnt">340</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Keychron" <%= selectedBrands.contains("Keychron") ? "checked" : "" %>>
                        <span>Keychron</span><span class="f-cnt">95</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="GMK" <%= selectedBrands.contains("GMK") ? "checked" : "" %>>
                        <span>GMK</span><span class="f-cnt">42</span>
                    </label>
                </div>

                <!-- Tiêu chí 2: Loại switch -->
                <div class="f-section">
                    <h4>Loại switch</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Linear" <%= selectedSwitchTypes.contains("Linear") ? "checked" : "" %>>
                        <span>Linear</span><span class="f-cnt">412</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Tactile" <%= selectedSwitchTypes.contains("Tactile") ? "checked" : "" %>>
                        <span>Tactile</span><span class="f-cnt">298</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Clicky" <%= selectedSwitchTypes.contains("Clicky") ? "checked" : "" %>>
                        <span>Clicky</span><span class="f-cnt">96</span>
                    </label>
                </div>

                <!-- Tiêu chí 3: Layout bàn phím -->
                <div class="f-section">
                    <h4>Layout</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="60%" <%= selectedLayouts.contains("60%") ? "checked" : "" %>>
                        <span>60% / 61 phím</span><span class="f-cnt">286</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="75%" <%= selectedLayouts.contains("75%") ? "checked" : "" %>>
                        <span>75% / 82 phím</span><span class="f-cnt">197</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="TKL" <%= selectedLayouts.contains("TKL") ? "checked" : "" %>>
                        <span>TKL / 87 phím</span><span class="f-cnt">154</span>
                    </label>
                </div>

                <!-- Tiêu chí 4: Khoảng giá -->
                <div class="f-section">
                    <h4>Khoảng giá (VNĐ)</h4>
                    <div class="price-range-inputs">
                        <input type="text" name="minPrice" placeholder="Từ 0" value="<%= minPrice != null ? minPrice : "" %>">
                        <span>—</span>
                        <input type="text" name="maxPrice" placeholder="Đến 5.000.000" value="<%= maxPrice != null ? maxPrice : "" %>">
                    </div>
                </div>

                <!-- Tiêu chí 5: Lực nhấn -->
                <div class="f-section">
                    <h4>Lực nhấn</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="force" value="Dưới 45g" <%= selectedForces.contains("Dưới 45g") ? "checked" : "" %>>
                        <span>Dưới 45g</span><span class="f-cnt">88</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="force" value="45-55g" <%= selectedForces.contains("45-55g") ? "checked" : "" %>>
                        <span>45–55g</span><span class="f-cnt">204</span>
                    </label>
                </div>

                <!-- Tiêu chí 6: Tình trạng & Dịch vụ -->
                <div class="f-section">
                    <h4>Tình trạng & Dịch vụ</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="inStock" value="1" <%= (inStock != null && inStock) ? "checked" : "" %>>
                        <span>Còn hàng</span><span class="f-cnt">984</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="custom" value="1" <%= (supportCustom != null && supportCustom) ? "checked" : "" %>>
                        <span>Hỗ trợ gia công</span><span class="f-cnt">318</span>
                    </label>
                </div>

                <!-- Tiêu chí 7: Đánh giá -->
                <div class="f-section">
                    <h4>Đánh giá</h4>
                    <label class="f-check-row">
                        <input type="radio" name="rating" value="4.8" <%= (minRating != null && minRating == 4.8) ? "checked" : "" %>>
                        <span style="color:#F59E0B;">★★★★★</span> <span>từ 4.8 sao</span>
                    </label>
                    <label class="f-check-row">
                        <input type="radio" name="rating" value="4.5" <%= (minRating != null && minRating == 4.5) ? "checked" : "" %>>
                        <span style="color:#F59E0B;">★★★★☆</span> <span>từ 4.5 sao</span>
                    </label>
                </div>

                <button type="submit" class="btn-apply-filter">Áp dụng bộ lọc</button>
            </aside>

            <!-- Cột Phải: Kết quả sản phẩm -->
            <section>
                <div class="sort-header-bar">
                    <span class="s-label">Sắp xếp theo</span>
                    <button type="button" class="sort-pill-btn <%= "popular".equals(sort) ? "active" : "" %>" onclick="submitSort('popular')">Phổ biến</button>
                    <button type="button" class="sort-pill-btn <%= "best_selling".equals(sort) ? "active" : "" %>" onclick="submitSort('best_selling')">Bán chạy (Số lượng bán)</button>
                    <button type="button" class="sort-pill-btn <%= "price_asc".equals(sort) ? "active" : "" %>" onclick="submitSort('price_asc')">Giá: Thấp → Cao</button>
                    <button type="button" class="sort-pill-btn <%= "price_desc".equals(sort) ? "active" : "" %>" onclick="submitSort('price_desc')">Giá: Cao → Thấp</button>
                    <button type="button" class="sort-pill-btn <%= "newest".equals(sort) ? "active" : "" %>" onclick="submitSort('newest')">Mới nhất</button>
                    <span class="sort-right-count"><strong><%= products.size() %></strong> sản phẩm</span>
                </div>

                <div class="compat-banner-alert">
                    💡 Bạn đang tìm linh kiện cho kit <strong>Tofu60 2.0</strong> đã lưu? <a href="category?custom=1">Bật lọc tương thích</a> để chỉ hiện linh kiện lắp vừa kit này (UC27).
                </div>

                <% if (products.isEmpty()) { %>
                <div style="background:#FFF;border:1px solid #E2E8F0;border-radius:12px;padding:48px;text-align:center;">
                    <h3 style="margin-bottom:8px;">Không tìm thấy sản phẩm khớp với bộ lọc</h3>
                    <p style="color:#64748B;margin-bottom:16px;">Hãy thử gỡ bớt một vài tiêu chí lọc để xem nhiều sản phẩm hơn.</p>
                    <a href="category" class="btn btn-blue">Xoá tất cả bộ lọc</a>
                </div>
                <% } else { %>
                <div class="product-grid-4">
                    <% for (Product p : products) { %>
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
                <% } %>

                <div class="pagination-bar">
                    <span class="pg-item">‹</span>
                    <span class="pg-item active">1</span>
                    <span class="pg-item">2</span>
                    <span class="pg-item">3</span>
                    <span class="pg-item">›</span>
                </div>
            </section>
        </div>
    </form>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    function submitSort(sortValue) {
        document.getElementById('sortHiddenInput').value = sortValue;
        document.getElementById('filterForm').submit();
    }
</script>
</body>
</html>