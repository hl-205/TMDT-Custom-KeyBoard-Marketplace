<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Product.*" %>
<%@ page import="java.util.List" %>
<%
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("product-detail?id=1");
        return;
    }
    List<ProductOption> colorOptions = (List<ProductOption>) request.getAttribute("colorOptions");
    List<ProductOption> plateOptions = (List<ProductOption>) request.getAttribute("plateOptions");
    List<ProductSpec> specs = (List<ProductSpec>) request.getAttribute("specs");
    List<ProductCompatibility> compatibilities = (List<ProductCompatibility>) request.getAttribute("compatibilities");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    List<Product> similarProducts = (List<Product>) request.getAttribute("similarProducts");

    // Tìm option Plate mặc định có extraPrice = 0 để khớp với giá gốc khi mới mở trang
    int defaultPlateIndex = 0;
    String defaultPlateLabel = "Polycarbonate";
    if (plateOptions != null) {
        for (int i = 0; i < plateOptions.size(); i++) {
            if (plateOptions.get(i).getExtraPrice() == 0) {
                defaultPlateIndex = i;
                defaultPlateLabel = plateOptions.get(i).getOptionName();
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getName() %> - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/product-detail.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb">
        <a href="index.jsp">Trang chủ</a> ›
        <a href="category?cat=<%= product.getCategoryId() %>"><%= product.getCategoryName() %></a> ›
        <a href="category">60% layout</a> ›
        <strong><%= product.getName().split("—")[0].trim() %></strong>
    </div>

    <section class="pd-top-card">
        <!-- Cột trái: Bộ ảnh sản phẩm có Zoom & Đổi góc nhìn -->
        <div class="pd-gallery-col">
            <div class="pd-main-image-box" id="mainImageBox">
                <div class="pd-zoom-target" id="zoomTarget">
                    <div id="graphicStage">
                        <div class="tofu-board-graphic">
                            <div class="tofu-inner-case">
                                <div class="tofu-row">
                                    <span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span>
                                </div>
                                <div class="tofu-row">
                                    <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                                </div>
                                <div class="tofu-row">
                                    <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                                </div>
                                <div class="tofu-row">
                                    <span class="t-key"></span><span class="t-key"></span><span class="t-key w2 blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <span class="pd-view-caption" id="viewCaption">Góc 1/5 · Mặt trên Layout tiêu chuẩn</span>
                </div>
                <span class="pd-zoom-hint">🔍 Rê chuột để phóng to</span>
            </div>

            <div class="pd-thumb-list">
                <div class="pd-thumb-item active" data-view="1" data-caption="Góc 1/5 · Mặt trên Layout tiêu chuẩn">
                    <div class="mini-thumb-box"><span></span><span></span></div>
                </div>
                <div class="pd-thumb-item" data-view="2" data-caption="Góc 2/5 · Mạch PCB Hotswap 5-pin & RGB">
                    <div class="mini-thumb-box"><span></span><span></span><span></span></div>
                </div>
                <div class="pd-thumb-item" data-view="3" data-caption="Góc 3/5 · Khung nhôm CNC 6063 & Tạ đáy">
                    <div class="mini-thumb-box" style="background:#CBD5E1;"><span></span></div>
                </div>
                <div class="pd-thumb-item" data-view="4" data-caption="Góc 4/5 · Cấu trúc Gasket Poron & Switch">
                    <div class="illus-switch purple" style="width:24px;height:24px;"></div>
                </div>
                <div class="pd-thumb-item" data-view="5" data-caption="Góc 5/5 · Cổng USB-C & Daughterboard rời">
                    <div class="mini-thumb-box"><span></span><span></span></div>
                </div>
            </div>
        </div>

        <!-- Cột phải: Thông tin & Tùy chọn mua hàng -->
        <div class="pd-info-col">
            <div class="pd-badges-row">
                <% if (product.getDiscountPercent() > 0) { %>
                <span class="pd-tag discount">-<%= product.getDiscountPercent() %>%</span>
                <% } %>
                <span class="pd-tag stock">Còn hàng</span>
                <% if (product.isSupportCustom()) { %>
                <span class="pd-tag custom">Hỗ trợ gia công</span>
                <% } %>
            </div>

            <h1 class="pd-title"><%= product.getName() %></h1>

            <div class="pd-meta-stats">
                <span class="stars">★★★★★ <strong><%= product.getRatingAvg() %></strong></span>
                <span><%= product.getRatingCount() %> đánh giá</span>
                <span>Đã bán <%= product.getFormattedSoldCount() %></span>
                <span>Mã SP: <%= product.getSku() %></span>
            </div>

            <div class="pd-price-box">
                <div class="pd-price-main">
                    <span class="pd-current-price" id="displayPrice" data-base="<%= product.getPrice() %>"><%= product.getFormattedPrice() %></span>
                    <% if (product.getOldPrice() > 0) { %>
                    <span class="pd-old-price" id="displayOldPrice" data-base-old="<%= product.getOldPrice() %>"><%= product.getFormattedOldPrice() %></span>
                    <% } %>
                </div>
                <% if (product.getOldPrice() > product.getPrice()) { %>
                <div class="pd-price-sub">
                    Tiết kiệm <%= product.getFormattedSavedAmount() %> · Ưu đãi kết thúc sau <strong>04:12:38</strong>
                </div>
                <% } %>
            </div>

            <!-- Chọn Màu sắc -->
            <div class="pd-option-section">
                <div class="pd-option-label">Màu sắc · <strong id="selectedColorText">Silver</strong></div>
                <div class="pd-option-buttons" id="colorGroup">
                    <% if (colorOptions != null) {
                        for (int i = 0; i < colorOptions.size(); i++) {
                            ProductOption opt = colorOptions.get(i);
                    %>
                    <button type="button"
                            class="pd-opt-btn <%= i == 0 ? "active" : "" %> <%= !opt.isAvailable() ? "disabled" : "" %>"
                            <%= !opt.isAvailable() ? "disabled" : "" %>
                            data-label="<%= opt.getOptionName() %>">
                        <%= opt.getOptionName() %>
                    </button>
                    <%  }
                    } %>
                </div>
            </div>

            <!-- Chọn Plate (Tự động cộng/trừ giá tiền) -->
            <div class="pd-option-section">
                <div class="pd-option-label">Plate · <strong id="selectedPlateText"><%= defaultPlateLabel %></strong></div>
                <div class="pd-option-buttons" id="plateGroup">
                    <% if (plateOptions != null) {
                        for (int i = 0; i < plateOptions.size(); i++) {
                            ProductOption opt = plateOptions.get(i);
                    %>
                    <button type="button"
                            class="pd-opt-btn <%= i == defaultPlateIndex ? "active" : "" %> <%= !opt.isAvailable() ? "disabled" : "" %>"
                            <%= !opt.isAvailable() ? "disabled" : "" %>
                            data-extra="<%= opt.getExtraPrice() %>"
                            data-label="<%= opt.getOptionName() %>">
                        <%= opt.getOptionName() %>
                    </button>
                    <%  }
                    } %>
                </div>
            </div>

            <!-- Số lượng (Giới hạn từ 1 đến tồn kho thực tế) -->
            <div class="pd-option-section">
                <div class="pd-option-label"><strong>Số lượng</strong></div>
                <div class="pd-qty-row">
                    <div class="qty-stepper">
                        <button type="button" class="qty-btn" id="qtyMinus" disabled>−</button>
                        <input type="text" id="qtyInput" class="qty-input" value="1" data-max="<%= product.getStock() %>" readonly>
                        <button type="button" class="qty-btn" id="qtyPlus" <%= product.getStock() <= 1 ? "disabled" : "" %>>+</button>
                    </div>
                    <span class="pd-stock-note">Kho còn <strong id="maxStockText"><%= product.getStock() %></strong> sản phẩm</span>
                </div>
                <div class="pd-stock-warning" id="stockLimitWarning">
                    Đã đạt giới hạn tối đa <%= product.getStock() %> sản phẩm hiện có trong kho.
                </div>
            </div>

            <form method="post" action="<%= request.getContextPath() %>/cart" id="cartForm" class="pd-buy-actions">
                <input type="hidden" name="productId" value="<%= product.getId() %>">
                <input type="hidden" name="quantity" id="cartQty" value="1">
                <input type="hidden" name="color" id="cartColor" value="">
                <input type="hidden" name="plate" id="cartPlate" value="">
                <button type="submit" class="btn-add-cart">🛒 Thêm vào giỏ</button>
                <button type="submit" name="buyNow" value="1" class="btn-buy-now">Mua ngay</button>
            </form>

            <a href="custom-builder?kitId=<%= product.getId() %>" class="btn-custom-builder-wide">
                ⚙️ Dùng kit này để build custom trong Custom Builder
            </a>

            <div class="pd-shop-strip">
                <div class="pd-shop-left">
                    <div class="pd-shop-logo" style="background:<%= product.getShopAvatarColor() %>;"><%= product.getShopAvatarText() %></div>
                    <div>
                        <div class="pd-shop-title-row">
                            <strong><%= product.getShopName() %></strong>
                            <% if (product.isShopVerified()) { %>
                            <span class="badge-verified-green">Đã xác minh</span>
                            <% } %>
                        </div>
                        <div class="pd-shop-sub">
                            ★ <%= product.getShopRating() %> · <%= product.getFormattedShopFollowers() %> theo dõi · Phản hồi <%= product.getShopResponseRate() %>% trong <%= product.getShopResponseTime() %> · Xưởng gia công tại <%= product.getShopAddress() %>
                        </div>
                    </div>
                </div>
                <div class="pd-shop-btns">
                    <a href="#" class="btn-shop-sm">💬 Chat</a>
                    <a href="shop?id=<%= product.getShopId() %>" class="btn-shop-sm">Xem shop</a>
                </div>
            </div>

            <div class="pd-mini-guarantees">
                <div class="pd-guar-item">
                    <strong>🚚 Giao 2–4 ngày</strong>
                    <span>Miễn phí đơn từ 500k</span>
                </div>
                <div class="pd-guar-item">
                    <strong>🛡️ Bảo hành 12 tháng</strong>
                    <span>Đổi mới 7 ngày đầu</span>
                </div>
                <div class="pd-guar-item">
                    <strong>🔒 Sàn giữ tiền</strong>
                    <span>Tới khi bạn xác nhận</span>
                </div>
            </div>
        </div>
    </section>

    <div class="pd-bottom-layout">
        <div class="pd-content-card">
            <div class="pd-tabs-nav">
                <a href="#sec-mota" class="pd-tab-link active">Mô tả</a>
                <a href="#sec-thongso" class="pd-tab-link">Thông số kỹ thuật</a>
                <a href="#sec-tuongthich" class="pd-tab-link">Tương thích</a>
                <a href="#sec-danhgia" class="pd-tab-link">Đánh giá (<%= reviews != null ? reviews.size() : product.getRatingCount() %>)</a>
                <a href="#sec-danhgia" class="pd-tab-link">Hỏi đáp (34)</a>
            </div>

            <div class="pd-article-section" id="sec-mota">
                <h3><%= product.getName().split("—")[0].trim() %> — bản nâng cấp của huyền thoại</h3>
                <p><%= product.getShortDesc() %></p>
                <p><%= product.getDescription() %></p>

                <div class="pd-desc-banner">
                    <div class="tofu-board-graphic" style="width: 420px;">
                        <div class="tofu-inner-case">
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key blue"></span><span class="t-key w2"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="pd-article-section" id="sec-thongso">
                <h3>Thông số kỹ thuật</h3>
                <table class="pd-specs-table">
                    <% if (specs != null) {
                        for (ProductSpec sp : specs) { %>
                    <tr>
                        <td><%= sp.getSpecName() %></td>
                        <td><%= sp.getSpecValue() %></td>
                    </tr>
                    <%  }
                    } %>
                </table>
            </div>

            <div class="pd-article-section" id="sec-tuongthich">
                <h3>Tương thích linh kiện</h3>
                <p class="pd-compat-subtitle">Dữ liệu đối chiếu tự động từ cơ sở dữ liệu tương thích của sàn (UC27)</p>
                <div class="pd-compat-grid">
                    <% if (compatibilities != null) {
                        for (ProductCompatibility cp : compatibilities) { %>
                    <div class="compat-box <%= cp.isCompatible() ? "ok" : "no" %>">
                        <span class="compat-icon"><%= cp.isCompatible() ? "✓" : "✕" %></span>
                        <div>
                            <strong><%= cp.getTitle() %></strong>
                            <span><%= cp.getDescription() %></span>
                        </div>
                    </div>
                    <%  }
                    } %>
                </div>
            </div>

            <div class="pd-article-section" id="sec-danhgia" style="margin-bottom: 0;">
                <h3>Đánh giá từ người mua</h3>
                <div class="pd-rating-overview">
                    <div class="rating-score-big">
                        <strong><%= product.getRatingAvg() %></strong>
                        <div class="stars">★★★★★</div>
                        <span><%= product.getRatingCount() %> đánh giá</span>
                    </div>
                    <div class="rating-bars-list">
                        <div class="r-bar-row"><span>5 ★</span><div class="r-bar-track"><div class="r-bar-fill" style="width: 88%;"></div></div><span class="r-bar-count">192</span></div>
                        <div class="r-bar-row"><span>4 ★</span><div class="r-bar-track"><div class="r-bar-fill" style="width: 14%;"></div></div><span class="r-bar-count">19</span></div>
                        <div class="r-bar-row"><span>3 ★</span><div class="r-bar-track"><div class="r-bar-fill" style="width: 5%;"></div></div><span class="r-bar-count">5</span></div>
                        <div class="r-bar-row"><span>2 ★</span><div class="r-bar-track"><div class="r-bar-fill" style="width: 2%;"></div></div><span class="r-bar-count">1</span></div>
                        <div class="r-bar-row"><span>1 ★</span><div class="r-bar-track"><div class="r-bar-fill" style="width: 2%;"></div></div><span class="r-bar-count">1</span></div>
                    </div>
                </div>

                <div class="review-filter-pills">
                    <span class="r-pill active">Tất cả</span>
                    <span class="r-pill">5 sao (192)</span>
                    <span class="r-pill">4 sao (19)</span>
                    <span class="r-pill">Có hình ảnh (64)</span>
                    <span class="r-pill">Có gia công (28)</span>
                </div>

                <% if (reviews != null) {
                    for (Review rv : reviews) { %>
                <div class="review-item-card">
                    <div class="review-user-head">
                        <div class="rev-avatar"><%= rv.getAvatarText() %></div>
                        <div>
                            <div>
                                <strong style="font-size: 13px; margin-right: 6px;"><%= rv.getReviewerName() %></strong>
                                <span class="badge-verified-green">Đã mua hàng</span>
                            </div>
                            <div class="rev-meta-line">
                                    <span class="stars">
                                        <% for (int s = 1; s <= 5; s++) { %><%= s <= rv.getRating() ? "★" : "☆" %><% } %>
                                    </span>
                                <%= rv.getReviewDate() %> · <%= rv.getVariantInfo() %>
                            </div>
                        </div>
                    </div>
                    <p class="review-comment-text"><%= rv.getComment() %></p>
                    <div class="review-photos-row">
                        <div class="rev-photo-box"><div class="mini-thumb-box"><span></span></div></div>
                        <div class="rev-photo-box"><div class="mini-thumb-box"><span></span><span></span></div></div>
                        <div class="rev-photo-box"><div class="mini-thumb-box"><span></span></div></div>
                    </div>
                    <div class="review-actions-line">
                        <span>👍 Hữu ích (<%= rv.getHelpfulCount() %>)</span>
                        <span>Trả lời</span>
                    </div>
                </div>
                <%  }
                } %>

                <button type="button" class="btn-more-reviews">Xem thêm đánh giá</button>
            </div>
        </div>

        <aside class="pd-right-sidebar">
            <div class="sidebar-box-card">
                <h4>Thường mua cùng</h4>
                <div class="bundle-item">
                    <div class="bundle-thumb"><div class="illus-kit" style="width:28px;height:18px;"></div></div>
                    <div class="bundle-info">
                        <strong>Kit Keychron Q1 Pro QMK/VIA — knob, hotswap, ANSI</strong>
                        <span>4.290.000₫</span>
                    </div>
                </div>
                <div class="bundle-item">
                    <div class="bundle-thumb"><div class="illus-switch yellow" style="width:22px;height:22px;"></div></div>
                    <div class="bundle-info">
                        <strong>Switch Akko Cream Yellow V3 Pro — Linear 50g (45 nút)</strong>
                        <span>320.000₫</span>
                    </div>
                </div>
                <div class="bundle-item">
                    <div class="bundle-thumb"><div class="illus-switch purple" style="width:22px;height:22px;"></div></div>
                    <div class="bundle-info">
                        <strong>Stabilizer Durock V2 PCB-mount — đã lube sẵn</strong>
                        <span>420.000₫</span>
                    </div>
                </div>
                <div class="bundle-item">
                    <div class="bundle-thumb"><div class="illus-keycap" style="width:24px;height:24px;"></div></div>
                    <div class="bundle-info">
                        <strong>Keycap Akko Black & Pink ASA profile — 158 phím</strong>
                        <span>690.000₫</span>
                    </div>
                </div>
                <div class="bundle-total-row">
                    <span>Tổng combo</span>
                    <strong>12.230.000₫</strong>
                </div>
                <a href="cart.jsp" class="btn-full-blue">Thêm cả combo vào giỏ</a>
            </div>

            <div class="sidebar-blue-promo">
                <h4>⚙️ Build trọn bộ với kit này</h4>
                <p>Chọn switch, keycap và gói gia công phù hợp — hệ thống tự loại linh kiện không lắp vừa.</p>
                <a href="custom-builder?kitId=<%= product.getId() %>" class="btn-full-blue">Mở Custom Builder</a>
            </div>

            <div class="sidebar-box-card">
                <h4>Chính sách</h4>
                <ul class="policy-check-list">
                    <li><span>↩</span> <span>Đổi trả trong 7 ngày nếu lỗi nhà sản xuất</span></li>
                    <li><span>🛡️</span> <span>Bảo hành 12 tháng tại xưởng KeebHub</span></li>
                    <li><span>🔒</span> <span>Tiền giữ ở sàn tới khi bạn bấm “Đã nhận hàng”</span></li>
                    <li><span>📦</span> <span>Kiểm tra hàng trước khi thanh toán (COD)</span></li>
                </ul>
            </div>
        </aside>
    </div>

    <section class="home-section">
        <div class="section-head">
            <h3>Sản phẩm tương tự</h3>
            <a href="category" class="view-all-link">Xem tất cả →</a>
        </div>
        <div class="product-grid-6">
            <% if (similarProducts != null) {
                for (Product sp : similarProducts) { %>
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
            <%  }
            } %>
        </div>
    </section>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    function formatCurrencyVND(amount) {
        return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") + "₫";
    }

    // 1. Phóng to ảnh khi rê chuột vào khung ảnh chính
    const mainImageBox = document.getElementById('mainImageBox');
    const zoomTarget = document.getElementById('zoomTarget');
    if (mainImageBox && zoomTarget) {
        mainImageBox.addEventListener('mousemove', (e) => {
            const rect = mainImageBox.getBoundingClientRect();
            const x = ((e.clientX - rect.left) / rect.width) * 100;
            const y = ((e.clientY - rect.top) / rect.height) * 100;
            zoomTarget.style.transformOrigin = x + '% ' + y + '%';
            zoomTarget.style.transform = 'scale(1.65)';
        });
        mainImageBox.addEventListener('mouseleave', () => {
            zoomTarget.style.transformOrigin = 'center center';
            zoomTarget.style.transform = 'scale(1)';
        });
    }

    // 2. Thay đổi ảnh to khi click chọn 5 ảnh nhỏ (Thumbnail)
    const graphicStage = document.getElementById('graphicStage');
    const viewCaption = document.getElementById('viewCaption');
    const viewTemplates = {
        '1': `<div class="tofu-board-graphic"><div class="tofu-inner-case">
                <div class="tofu-row"><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span></div>
                <div class="tofu-row"><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span></div>
                <div class="tofu-row"><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span></div>
                <div class="tofu-row"><span class="t-key"></span><span class="t-key"></span><span class="t-key w2 blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span></div>
              </div></div>`,
        '2': `<div class="tofu-board-graphic" style="background:#1E293B;border-color:#0F172A;"><div class="tofu-inner-case" style="background:#0F172A;border-color:#334155;">
                <div class="tofu-row"><span class="t-key" style="background:#F97316;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#1B64F2;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#F97316;"></span></div>
                <div class="tofu-row"><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#10B981;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#10B981;"></span><span class="t-key" style="background:#334155;"></span><span class="t-key" style="background:#334155;"></span></div>
                <div class="tofu-row"><span class="t-key" style="background:#334155;"></span><span class="t-key w2" style="background:#1B64F2;"></span><span class="t-key" style="background:#334155;"></span></div>
              </div></div>`,
        '3': `<div class="tofu-board-graphic" style="background:#CBD5E1;border-color:#94A3B8;padding:24px;"><div class="tofu-inner-case" style="background:linear-gradient(135deg,#F59E0B,#D97706);border-color:#B45309;height:110px;display:flex;align-items:center;justify-content:center;color:#FFF;font-weight:800;letter-spacing:2px;">
                BRASS WEIGHT · CNC 6063
              </div></div>`,
        '4': `<div style="display:flex;gap:18px;align-items:center;justify-content:center;padding:20px;">
                <div class="illus-switch purple" style="width:90px;height:90px;border-top-width:14px;"></div>
                <div class="illus-switch yellow" style="width:90px;height:90px;border-top-width:14px;"></div>
              </div>`,
        '5': `<div class="tofu-board-graphic" style="background:#E2E8F0;"><div class="tofu-inner-case" style="padding:22px;text-align:center;">
                <div style="width:70px;height:20px;background:#0F172A;border-radius:10px;margin:0 auto 10px;border:3px solid #94A3B8;"></div>
                <strong style="font-size:12px;color:#334155;">USB Type-C Daughterboard & JST Cable</strong>
              </div></div>`
    };

    const thumbs = document.querySelectorAll('.pd-thumb-item');
    thumbs.forEach(t => {
        t.addEventListener('click', () => {
            thumbs.forEach(item => item.classList.remove('active'));
            t.classList.add('active');
            const viewKey = t.getAttribute('data-view');
            const caption = t.getAttribute('data-caption');
            if (graphicStage && viewTemplates[viewKey]) {
                graphicStage.innerHTML = viewTemplates[viewKey];
            }
            if (viewCaption && caption) {
                viewCaption.textContent = caption;
            }
        });
    });

    // 3. Tương tác chọn Màu sắc
    const colorBtns = document.querySelectorAll('#colorGroup .pd-opt-btn:not(.disabled)');
    const selectedColorText = document.getElementById('selectedColorText');
    colorBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            colorBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            selectedColorText.textContent = btn.getAttribute('data-label');
        });
    });

    // 4. Tương tác chọn Plate & Tự động cập nhật Giá tiền theo Plate đã chọn
    const plateBtns = document.querySelectorAll('#plateGroup .pd-opt-btn:not(.disabled)');
    const selectedPlateText = document.getElementById('selectedPlateText');
    const displayPrice = document.getElementById('displayPrice');
    const displayOldPrice = document.getElementById('displayOldPrice');

    plateBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            plateBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            selectedPlateText.textContent = btn.getAttribute('data-label');

            const basePrice = parseInt(displayPrice.getAttribute('data-base'), 10) || 0;
            const extraPrice = parseInt(btn.getAttribute('data-extra'), 10) || 0;
            displayPrice.textContent = formatCurrencyVND(basePrice + extraPrice);

            if (displayOldPrice) {
                const baseOld = parseInt(displayOldPrice.getAttribute('data-base-old'), 10) || 0;
                if (baseOld > 0) {
                    displayOldPrice.textContent = formatCurrencyVND(baseOld + extraPrice);
                }
            }
        });
    });

    // 5. Tăng giảm số lượng trong phạm vi từ 1 đến tồn kho thực tế
    const qtyInput = document.getElementById('qtyInput');
    const qtyMinus = document.getElementById('qtyMinus');
    const qtyPlus = document.getElementById('qtyPlus');
    const stockLimitWarning = document.getElementById('stockLimitWarning');
    const maxStock = parseInt(qtyInput.getAttribute('data-max'), 10) || 1;

    function syncQtyButtons(val) {
        qtyMinus.disabled = (val <= 1);
        qtyPlus.disabled = (val >= maxStock);
        if (stockLimitWarning) {
            stockLimitWarning.style.display = (val >= maxStock) ? 'block' : 'none';
        }
    }

    // Gửi số lượng đang chọn cùng form thêm vào giỏ
    document.getElementById('cartForm').addEventListener('submit', () => {
        document.getElementById('cartQty').value = parseInt(qtyInput.value, 10) || 1;
        document.getElementById('cartColor').value = document.querySelector('#colorGroup .pd-opt-btn.active:not(.disabled)')?.getAttribute('data-label') || '';
        document.getElementById('cartPlate').value = document.querySelector('#plateGroup .pd-opt-btn.active:not(.disabled)')?.getAttribute('data-label') || '';
    });

    qtyMinus.addEventListener('click', () => {
        let val = parseInt(qtyInput.value, 10) || 1;
        if (val > 1) {
            val--;
            qtyInput.value = val;
            syncQtyButtons(val);
        }
    });

    qtyPlus.addEventListener('click', () => {
        let val = parseInt(qtyInput.value, 10) || 1;
        if (val < maxStock) {
            val++;
            qtyInput.value = val;
            syncQtyButtons(val);
        }
    });
</script>
</body>
</html>