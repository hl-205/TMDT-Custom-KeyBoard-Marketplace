<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Shop.CustomServiceItem" %>
<%@ page import="model.Product" %>
<%@ page import="java.util.List" %>
<%
    Shop shop = (Shop) request.getAttribute("shop");
    if (shop == null) {
        response.sendRedirect("shop?id=1");
        return;
    }
    List<CustomServiceItem> services = (List<CustomServiceItem>) request.getAttribute("services");
    List<Product> shopProducts = (List<Product>) request.getAttribute("shopProducts");
    Integer totalShopProductsObj = (Integer) request.getAttribute("totalShopProducts");
    int totalShopProducts = (totalShopProductsObj != null) ? totalShopProductsObj : shopProducts.size();
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    int currentPage = (currentPageObj != null) ? currentPageObj : 1;
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    int totalPages = (totalPagesObj != null) ? totalPagesObj : 1;

    Integer selectedCat = (Integer) request.getAttribute("selectedCat");
    String sort = (String) request.getAttribute("sort");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= shop.getShopName() %> - Gian hàng KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <a href="shops">Hệ thống Gian hàng</a> ›
        <strong><%= shop.getShopName() %></strong>
    </div>

    <section class="shop-hero-header">
        <div class="shop-hero-left">
            <div class="shop-big-avatar" style="color:<%= shop.getAvatarColor() %>;"><%= shop.getAvatarText() %></div>
            <div>
                <div class="shop-title-badges">
                    <h2><%= shop.getShopName() %></h2>
                    <% if (shop.isVerified()) { %>
                    <span class="shop-badge-pill verified">✓ Đã xác minh</span>
                    <% } %>
                    <% if (shop.isWorkshop()) { %>
                    <span class="shop-badge-pill workshop">Xưởng gia công</span>
                    <% } %>
                </div>
                <p class="shop-hero-desc"><%= shop.getDescription() %></p>
                <div class="shop-kpi-row">
                    <div class="shop-kpi-item">
                        <strong><%= shop.getRatingAvg() %></strong>
                        <span>Đánh giá (<%= shop.getFormattedRatingCount() %>)</span>
                    </div>
                    <div class="shop-kpi-item">
                        <strong><%= shop.getFormattedFollowers() %></strong>
                        <span>Người theo dõi</span>
                    </div>
                    <div class="shop-kpi-item">
                        <strong><%= totalShopProducts %></strong>
                        <span>Sản phẩm</span>
                    </div>
                    <div class="shop-kpi-item">
                        <strong><%= shop.getResponseRate() %>%</strong>
                        <span>Phản hồi chat</span>
                    </div>
                    <div class="shop-kpi-item">
                        <strong><%= shop.getResponseTime() %></strong>
                        <span>Thời gian phản hồi</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="shop-hero-actions">
            <button type="button" class="btn-follow-white" onclick="this.textContent = (this.textContent.includes('Đang') ? '+ Theo dõi' : '✓ Đang theo dõi')">+ Theo dõi</button>
            <a href="custom-builder" class="btn-chat-outline" style="display:flex;align-items:center;justify-content:center;">⚙️ Đặt Build tại Shop</a>
        </div>
    </section>

    <div class="shop-nav-tabs">
        <a href="shop?id=<%= shop.getId() %>" class="shop-tab-item <%= selectedCat == null ? "active" : "" %>">Tất cả sản phẩm</a>
        <a href="shop?id=<%= shop.getId() %>&cat=1" class="shop-tab-item <%= (selectedCat != null && selectedCat == 1) ? "active" : "" %>">Kit bàn phím</a>
        <a href="shop?id=<%= shop.getId() %>&cat=2" class="shop-tab-item <%= (selectedCat != null && selectedCat == 2) ? "active" : "" %>">Switch</a>
        <a href="shop?id=<%= shop.getId() %>&cat=3" class="shop-tab-item <%= (selectedCat != null && selectedCat == 3) ? "active" : "" %>">Keycap</a>
        <a href="shop?id=<%= shop.getId() %>&cat=4" class="shop-tab-item <%= (selectedCat != null && selectedCat == 4) ? "active" : "" %>">Stabilizer</a>
        <a href="shop?id=<%= shop.getId() %>&cat=5" class="shop-tab-item <%= (selectedCat != null && selectedCat == 5) ? "active" : "" %>">Phụ kiện</a>
        <a href="shop?id=<%= shop.getId() %>&cat=6" class="shop-tab-item <%= (selectedCat != null && selectedCat == 6) ? "active" : "" %>">Dịch vụ gia công</a>
    </div>

    <div class="shop-info-3cols" id="sec-shop-services">
        <div class="shop-info-card">
            <h4>🛠️ Dịch vụ gia công tại xưởng</h4>
            <% if (services != null && !services.isEmpty()) {
                for (CustomServiceItem sv : services) { %>
            <div class="shop-stat-line">
                <span><%= sv.getServiceName() %></span>
                <strong><%= sv.getFormattedPrice() %></strong>
            </div>
            <%  }
            } else { %>
            <div class="shop-stat-line">
                <span>Chuyên phân phối linh kiện chính hãng</span>
                <strong>Sẵn hàng</strong>
            </div>
            <% } %>
            <div style="font-size:11px;color:#94A3B8;margin-top:8px;">Bảo hành kỹ thuật trực tiếp qua sàn KeebHub</div>
        </div>

        <div class="shop-info-card">
            <h4>📊 Chỉ số vận hành</h4>
            <div class="shop-stat-line">
                <span>Giao đúng hẹn</span>
                <strong class="green"><%= shop.getOnTimeRate() %>%</strong>
            </div>
            <div class="shop-stat-line">
                <span>Tỉ lệ huỷ đơn</span>
                <strong class="green"><%= shop.getCancelRate() %>%</strong>
            </div>
            <div class="shop-stat-line">
                <span>Tỉ lệ hoàn hàng</span>
                <strong class="green"><%= shop.getReturnRate() %>%</strong>
            </div>
            <div style="font-size:11px;color:#94A3B8;margin-top:8px;">Dữ liệu trích xuất từ hệ thống KeebHub</div>
        </div>

        <div class="shop-info-card">
            <h4>🏪 Thông tin shop</h4>
            <div class="shop-stat-line">
                <span>Tham gia</span>
                <strong><%= shop.getJoinedDate() %></strong>
            </div>
            <div class="shop-stat-line">
                <span>Địa chỉ</span>
                <strong><%= shop.getAddress() %></strong>
            </div>
            <div class="shop-stat-line">
                <span>Giờ làm việc</span>
                <strong><%= shop.getWorkingHours() %></strong>
            </div>
            <div style="margin-top:8px;">
                <a href="shops" style="font-size:12px;color:#1B64F2;font-weight:700;">Xem danh sách 30 gian hàng ›</a>
            </div>
        </div>
    </div>

    <section class="home-section">
        <div class="section-head">
            <h3>Sản phẩm của <%= shop.getShopName() %> <span style="font-weight:400;color:#64748B;">(<%= totalShopProducts %>)</span></h3>
            <div style="display:flex;gap:8px;">
                <a href="shop?id=<%= shop.getId() %><%= selectedCat != null ? "&cat=" + selectedCat : "" %>&sort=popular"
                   class="sort-pill-btn <%= "popular".equals(sort) ? "active" : "" %>">Phổ biến</a>
                <a href="shop?id=<%= shop.getId() %><%= selectedCat != null ? "&cat=" + selectedCat : "" %>&sort=newest"
                   class="sort-pill-btn <%= "newest".equals(sort) ? "active" : "" %>">Mới nhất</a>
                <a href="shop?id=<%= shop.getId() %><%= selectedCat != null ? "&cat=" + selectedCat : "" %>&sort=best_selling"
                   class="sort-pill-btn <%= "best_selling".equals(sort) ? "active" : "" %>">Bán chạy</a>
                <a href="shop?id=<%= shop.getId() %><%= selectedCat != null ? "&cat=" + selectedCat : "" %>&sort=price_asc"
                   class="sort-pill-btn <%= "price_asc".equals(sort) ? "active" : "" %>">Giá ↑</a>
            </div>
        </div>

        <% if (shopProducts.isEmpty()) { %>
        <div style="background:#FFF;border:1px solid #E2E8F0;border-radius:12px;padding:36px;text-align:center;margin-bottom:24px;">
            <p style="color:#64748B;margin-bottom:12px;">Gian hàng hiện chưa có sản phẩm nào thuộc danh mục này.</p>
            <a href="shop?id=<%= shop.getId() %>" class="btn btn-blue">Xem tất cả sản phẩm của Shop</a>
        </div>
        <% } else { %>
        <div class="product-grid-6" style="margin-bottom:24px;">
            <% for (Product sp : shopProducts) { %>
            <a href="product-detail?id=<%= sp.getId() %>" class="p-card">
                <% if (sp.getBadge() != null && !sp.getBadge().isEmpty()) { %>
                <span class="p-badge <%= sp.getBadge().contains("%") ? "discount" : "new" %>"><%= sp.getBadge() %></span>
                <% } %>
                <span class="p-wish">♡</span>
                <div class="p-thumb">
                    <% if (sp.getCategoryId() == 1) { %>
                    <div class="illus-kit"></div>
                    <% } else if (sp.getCategoryId() == 2) { %>
                    <div class="illus-switch yellow"></div>
                    <% } else if (sp.getCategoryId() == 3) { %>
                    <div class="illus-keycap"></div>
                    <% } else { %>
                    <div class="illus-switch purple"></div>
                    <% } %>
                </div>
                <div class="p-Shop"><span class="dot-green"></span> <%= sp.getShopName() %></div>
                <h4 class="p-name"><%= sp.getName() %></h4>
                <div class="p-price">
                    <%= sp.getFormattedPrice() %>
                    <% if (sp.getOldPrice() > 0) { %>
                    <del><%= sp.getFormattedOldPrice() %></del>
                    <% } %>
                </div>
                <div class="p-meta">
                    <span class="stars">★★★★★ <%= sp.getRatingAvg() %></span>
                    <span>Đã bán <%= sp.getFormattedSoldCount() %></span>
                </div>
            </a>
            <% } %>
        </div>

        <div class="pagination-bar">
            <% for (int pg = 1; pg <= totalPages; pg++) { %>
            <a href="shop?id=<%= shop.getId() %><%= selectedCat != null ? "&cat=" + selectedCat : "" %>&sort=<%= sort %>&page=<%= pg %>"
               class="pg-item <%= pg == currentPage ? "active" : "" %>">
                <%= pg %>
            </a>
            <% } %>
        </div>
        <% } %>
    </section>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>