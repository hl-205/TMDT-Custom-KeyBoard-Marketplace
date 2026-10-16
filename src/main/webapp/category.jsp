<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%
    if (request.getAttribute("products") == null) {
        response.sendRedirect("category");
        return;
    }
    List<Product> products = (List<Product>) request.getAttribute("products");
    Integer totalProductsObj = (Integer) request.getAttribute("totalProducts");
    int totalProducts = (totalProductsObj != null) ? totalProductsObj : products.size();
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    int currentPage = (currentPageObj != null) ? currentPageObj : 1;
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    int totalPages = (totalPagesObj != null) ? totalPagesObj : 1;

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
    <div class="search-title-block">
        <h2>Kết quả cho “<%= keyword %>”</h2>
        <p>Tìm thấy <strong><%= totalProducts %></strong> sản phẩm trong cơ sở dữ liệu (Hiển thị tối đa 20 sản phẩm/trang)</p>
    </div>
    <% } else { %>
    <div class="cat-hero-banner">
        <div>
            <h2>Kho Linh Kiện Bàn Phím Cơ & Dịch Vụ Custom</h2>
            <p>Hiển thị trực tiếp từ cơ sở dữ liệu KeebHub. Mọi linh kiện đều có thông số đối chiếu tương thích tự động trong Custom Builder.</p>
            <div class="cat-hero-pills">
                <span>Hotswap 5-pin</span>
                <span>Gasket mount</span>
                <span>Có sẵn tại VN</span>
                <span>Hỗ trợ QMK/VIA</span>
                <span>Tri-mode Wireless</span>
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
        <span class="af-tag"><%= tag %></span>
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
        <input type="hidden" name="page" id="pageHiddenInput" value="<%= currentPage %>">

        <div class="filter-page-grid">
            <!-- Cột Trái: Bộ lọc đa tiêu chí -->
            <aside class="filter-panel-card">
                <div class="filter-panel-head">
                    <h3>Bộ lọc</h3>
                    <a href="category">Xoá tất cả</a>
                </div>

                <!-- Danh mục -->
                <div class="f-section">
                    <h4>Nhóm sản phẩm</h4>
                    <div style="display:flex;flex-direction:column;gap:6px;font-size:13px;">
                        <a href="category" style="color:<%= catId == null ? "#1B64F2;font-weight:700" : "#334155" %>;">• Tất cả danh mục</a>
                        <a href="category?cat=1" style="color:<%= (catId != null && catId == 1) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Kit bàn phím</a>
                        <a href="category?cat=2" style="color:<%= (catId != null && catId == 2) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Switch</a>
                        <a href="category?cat=3" style="color:<%= (catId != null && catId == 3) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Keycap</a>
                        <a href="category?cat=4" style="color:<%= (catId != null && catId == 4) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Stabilizer</a>
                        <a href="category?cat=5" style="color:<%= (catId != null && catId == 5) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Phụ kiện</a>
                        <a href="category?cat=6" style="color:<%= (catId != null && catId == 6) ? "#1B64F2;font-weight:700" : "#334155" %>;">• Dịch vụ gia công</a>
                    </div>
                </div>

                <!-- Tiêu chí 1: Thương hiệu -->
                <div class="f-section">
                    <h4>Thương hiệu</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="KBDfans" <%= selectedBrands.contains("KBDfans") ? "checked" : "" %>>
                        <span>KBDfans</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Gateron" <%= selectedBrands.contains("Gateron") ? "checked" : "" %>>
                        <span>Gateron</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Akko" <%= selectedBrands.contains("Akko") ? "checked" : "" %>>
                        <span>Akko</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Keychron" <%= selectedBrands.contains("Keychron") ? "checked" : "" %>>
                        <span>Keychron</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="GMK" <%= selectedBrands.contains("GMK") ? "checked" : "" %>>
                        <span>GMK</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="HMX" <%= selectedBrands.contains("HMX") ? "checked" : "" %>>
                        <span>HMX</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="brand" value="Qwertykeys" <%= selectedBrands.contains("Qwertykeys") ? "checked" : "" %>>
                        <span>Qwertykeys</span>
                    </label>
                </div>

                <!-- Tiêu chí 2: Loại switch -->
                <div class="f-section">
                    <h4>Loại switch</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Linear" <%= selectedSwitchTypes.contains("Linear") ? "checked" : "" %>>
                        <span>Linear</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Tactile" <%= selectedSwitchTypes.contains("Tactile") ? "checked" : "" %>>
                        <span>Tactile</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="switchType" value="Clicky" <%= selectedSwitchTypes.contains("Clicky") ? "checked" : "" %>>
                        <span>Clicky</span>
                    </label>
                </div>

                <!-- Tiêu chí 3: Layout bàn phím -->
                <div class="f-section">
                    <h4>Layout</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="60%" <%= selectedLayouts.contains("60%") ? "checked" : "" %>>
                        <span>60% / 61 phím</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="65%" <%= selectedLayouts.contains("65%") ? "checked" : "" %>>
                        <span>65% / 68 phím</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="75%" <%= selectedLayouts.contains("75%") ? "checked" : "" %>>
                        <span>75% / 82 phím</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="layout" value="TKL" <%= selectedLayouts.contains("TKL") ? "checked" : "" %>>
                        <span>TKL / 87 phím</span>
                    </label>
                </div>

                <!-- Tiêu chí 4: Khoảng giá -->
                <div class="f-section">
                    <h4>Khoảng giá (VNĐ)</h4>
                    <div class="price-range-inputs">
                        <input type="text" name="minPrice" placeholder="Từ 0" value="<%= minPrice != null ? minPrice : "" %>">
                        <span>—</span>
                        <input type="text" name="maxPrice" placeholder="Đến 8.000.000" value="<%= maxPrice != null ? maxPrice : "" %>">
                    </div>
                </div>

                <!-- Tiêu chí 5: Lực nhấn -->
                <div class="f-section">
                    <h4>Lực nhấn</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="force" value="Dưới 45g" <%= selectedForces.contains("Dưới 45g") ? "checked" : "" %>>
                        <span>Dưới 45g</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="force" value="45-55g" <%= selectedForces.contains("45-55g") ? "checked" : "" %>>
                        <span>45–55g</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="force" value="Trên 55g" <%= selectedForces.contains("Trên 55g") ? "checked" : "" %>>
                        <span>Trên 55g</span>
                    </label>
                </div>

                <!-- Tiêu chí 6: Tình trạng & Dịch vụ -->
                <div class="f-section">
                    <h4>Tình trạng & Dịch vụ</h4>
                    <label class="f-check-row">
                        <input type="checkbox" name="inStock" value="1" <%= (inStock != null && inStock) ? "checked" : "" %>>
                        <span>Còn hàng</span>
                    </label>
                    <label class="f-check-row">
                        <input type="checkbox" name="custom" value="1" <%= (supportCustom != null && supportCustom) ? "checked" : "" %>>
                        <span>Hỗ trợ gia công</span>
                    </label>
                </div>

                <!-- Tiêu chí 7: Đánh giá -->
                <div class="f-section">
                    <h4>Đánh giá</h4>
                    <label class="f-check-row">
                        <input type="radio" name="rating" value="4.9" <%= (minRating != null && minRating == 4.9) ? "checked" : "" %>>
                        <span style="color:#F59E0B;">★★★★★</span> <span>từ 4.9 sao</span>
                    </label>
                    <label class="f-check-row">
                        <input type="radio" name="rating" value="4.8" <%= (minRating != null && minRating == 4.8) ? "checked" : "" %>>
                        <span style="color:#F59E0B;">★★★★☆</span> <span>từ 4.8 sao</span>
                    </label>
                </div>

                <button type="submit" class="btn-apply-filter" onclick="document.getElementById('pageHiddenInput').value='1'">Áp dụng bộ lọc</button>
            </aside>

            <!-- Cột Phải: Kết quả sản phẩm -->
            <section>
                <div class="sort-header-bar">
                    <span class="s-label">Sắp xếp theo</span>
                    <button type="button" class="sort-pill-btn <%= "popular".equals(sort) ? "active" : "" %>" onclick="submitSort('popular')">🔥 Phổ biến</button>
                    <button type="button" class="sort-pill-btn <%= "newest".equals(sort) ? "active" : "" %>" onclick="submitSort('newest')">🆕 Mới nhất</button>
                    <button type="button" class="sort-pill-btn <%= "best_selling".equals(sort) ? "active" : "" %>" onclick="submitSort('best_selling')">📦 Bán chạy</button>
                    <button type="button" class="sort-pill-btn <%= "price_asc".equals(sort) ? "active" : "" %>" onclick="submitSort('price_asc')">💰 Giá thấp → cao</button>
                    <button type="button" class="sort-pill-btn <%= "price_desc".equals(sort) ? "active" : "" %>" onclick="submitSort('price_desc')">💎 Giá cao → thấp</button>
                    <span class="sort-right-count">
                        Hiển thị <strong><%= products.size() %></strong> / <strong><%= totalProducts %></strong> sản phẩm (Trang <%= currentPage %>/<%= totalPages %>)
                    </span>
                </div>

                <div class="compat-banner-alert">
                    💡 Bạn đang tìm linh kiện cho kit <strong>Tofu60 2.0</strong>? <a href="category?custom=1">Bật lọc hỗ trợ gia công</a> hoặc mở <a href="custom-builder">Custom Builder</a> để kiểm tra tương thích tự động.
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

                <!-- Thanh phân trang động: Nếu <= 20 sản phẩm (totalPages == 1) chỉ hiện đúng số 1 -->
                <div class="pagination-bar">
                    <% if (totalPages > 1 && currentPage > 1) { %>
                    <button type="button" class="pg-item" style="cursor:pointer;" onclick="goToPage(<%= currentPage - 1 %>)">‹</button>
                    <% } %>

                    <% for (int pg = 1; pg <= totalPages; pg++) { %>
                    <button type="button"
                            class="pg-item <%= pg == currentPage ? "active" : "" %>"
                            style="cursor:pointer;"
                            onclick="goToPage(<%= pg %>)">
                        <%= pg %>
                    </button>
                    <% } %>

                    <% if (totalPages > 1 && currentPage < totalPages) { %>
                    <button type="button" class="pg-item" style="cursor:pointer;" onclick="goToPage(<%= currentPage + 1 %>)">›</button>
                    <% } %>
                </div>
                <% } %>
            </section>
        </div>
    </form>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    function submitSort(sortValue) {
        document.getElementById('sortHiddenInput').value = sortValue;
        document.getElementById('pageHiddenInput').value = '1';
        document.getElementById('filterForm').submit();
    }

    function goToPage(pageNum) {
        document.getElementById('pageHiddenInput').value = pageNum;
        document.getElementById('filterForm').submit();
    }
</script>
</body>
</html>