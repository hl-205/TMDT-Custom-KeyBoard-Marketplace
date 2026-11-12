<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.Product.*" %>
<%@ page import="model.User" %>
<%@ page import="dao.ProductDAO.ReviewItem" %>
<%@ page import="dao.ProductDAO.ReviewReplyItem" %>
<%@ page import="dao.ProductDAO.ReviewStats" %>
<%@ page import="java.util.List" %>
<%
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("product-detail?id=1");
        return;
    }
    User currentUser = (User) session.getAttribute("user");
    List<ProductOption> colorOptions = (List<ProductOption>) request.getAttribute("colorOptions");
    List<ProductOption> plateOptions = (List<ProductOption>) request.getAttribute("plateOptions");
    List<ProductSpec> specs = (List<ProductSpec>) request.getAttribute("specs");
    List<ProductCompatibility> compatibilities = (List<ProductCompatibility>) request.getAttribute("compatibilities");
    List<Product> similarProducts = (List<Product>) request.getAttribute("similarProducts");

    ReviewStats reviewStats = (ReviewStats) request.getAttribute("reviewStats");
    if (reviewStats == null) reviewStats = new ReviewStats();
    List<ReviewItem> reviewItems = (List<ReviewItem>) request.getAttribute("reviewItems");
    Integer filteredReviewCountObj = (Integer) request.getAttribute("filteredReviewCount");
    int filteredReviewCount = (filteredReviewCountObj != null) ? filteredReviewCountObj : 0;

    Integer starFilter = (Integer) request.getAttribute("starFilter");
    Boolean hasImageObj = (Boolean) request.getAttribute("hasImage");
    boolean hasImage = (hasImageObj != null && hasImageObj);
    Boolean hasCustomObj = (Boolean) request.getAttribute("hasCustom");
    boolean hasCustom = (hasCustomObj != null && hasCustomObj);
    Integer revLimitObj = (Integer) request.getAttribute("revLimit");
    int revLimit = (revLimitObj != null) ? revLimitObj : 15;

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

    String filterQueryBase = "product-detail?id=" + product.getId()
            + (starFilter != null ? "&star=" + starFilter : "")
            + (hasImage ? "&hasImage=1" : "")
            + (hasCustom ? "&hasCustom=1" : "");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= product.getName() %> - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/product-detail.css">
    <style>
        .r-pill {
            text-decoration: none;
            display: inline-block;
            cursor: pointer;
        }
        .rev-real-img {
            width: 76px;
            height: 76px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #CBD5E1;
            cursor: zoom-in;
            transition: transform 0.15s ease;
        }
        .rev-real-img:hover {
            transform: scale(1.06);
            border-color: #1B64F2;
        }
        .rev-vote-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 10px;
            border-radius: 6px;
            border: 1px solid #E2E8F0;
            background: #F8FAFC;
            color: #475569;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s;
        }
        .rev-vote-btn:hover {
            border-color: #1B64F2;
            color: #1B64F2;
            background: #EFF6FF;
        }
        .rev-reply-thread {
            margin-top: 12px;
            background: #F8FAFC;
            border-left: 3px solid #1B64F2;
            padding: 10px 14px;
            border-radius: 0 8px 8px 0;
        }
        .rev-reply-item {
            padding: 6px 0;
            border-bottom: 1px dashed #E2E8F0;
            font-size: 13px;
        }
        .rev-reply-item:last-child {
            border-bottom: none;
        }
        .rev-role-badge {
            font-size: 10px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 10px;
            margin-left: 6px;
        }
        .rev-role-badge.seller {
            background: #FFF7ED;
            color: #EA580C;
            border: 1px solid #FED7AA;
        }
        .rev-role-badge.admin {
            background: #FEF2F2;
            color: #DC2626;
            border: 1px solid #FECACA;
        }
        .rev-role-badge.customer {
            background: #EFF6FF;
            color: #1B64F2;
        }
        .img-lightbox-modal {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.82);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            padding: 24px;
        }
        .img-lightbox-modal.show {
            display: flex;
        }
        .img-lightbox-modal img {
            max-width: 90vw;
            max-height: 85vh;
            border-radius: 12px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.5);
        }
    </style>
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb">
        <a href="index.jsp">Trang chủ</a> ›
        <a href="category?cat=<%= product.getCategoryId() %>"><%= product.getCategoryName() %></a> ›
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
                <span class="stars">★★★★★ <strong><%= reviewStats.getTotalCount() > 0 ? reviewStats.getAvgRating() : product.getRatingAvg() %></strong></span>
                <a href="#sec-danhgia" style="color:#64748B;text-decoration:underline;"><%= reviewStats.getTotalCount() %> đánh giá</a>
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
                    Tiết kiệm <%= product.getFormattedSavedAmount() %> · Giá đã bao gồm VAT
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

            <!-- Chọn Plate -->
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

            <!-- Số lượng -->
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
                            ★ <%= product.getShopRating() %> · <%= product.getFormattedShopFollowers() %> theo dõi · Phản hồi <%= product.getShopResponseRate() %>% <%= product.getShopResponseTime() %> · Tại <%= product.getShopAddress() %>
                        </div>
                    </div>
                </div>
                <div class="pd-shop-btns">
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
                <a href="#sec-danhgia" class="pd-tab-link">Đánh giá (<%= reviewStats.getTotalCount() %>)</a>
            </div>

            <div class="pd-article-section" id="sec-mota">
                <h3><%= product.getName().split("—")[0].trim() %></h3>
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
                <p class="pd-compat-subtitle">Dữ liệu đối chiếu tự động từ cơ sở dữ liệu tương thích của sàn</p>
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

            <!-- KHỐI ĐÁNH GIÁ TỪ NGƯỜI MUA: ĐỘNG 100% TỪ DATABASE -->
            <div class="pd-article-section" id="sec-danhgia" style="margin-bottom: 0;">
                <h3>Đánh giá từ người mua (<%= reviewStats.getTotalCount() %>)</h3>
                <div class="pd-rating-overview">
                    <div class="rating-score-big">
                        <strong><%= reviewStats.getTotalCount() > 0 ? reviewStats.getAvgRating() : 5.0 %></strong>
                        <div class="stars">★★★★★</div>
                        <span><%= reviewStats.getTotalCount() %> đánh giá xác thực</span>
                    </div>
                    <div class="rating-bars-list">
                        <div class="r-bar-row">
                            <span>5 ★</span>
                            <div class="r-bar-track"><div class="r-bar-fill" style="width: <%= reviewStats.getPercent(reviewStats.getStar5()) %>%;"></div></div>
                            <span class="r-bar-count"><%= reviewStats.getStar5() %></span>
                        </div>
                        <div class="r-bar-row">
                            <span>4 ★</span>
                            <div class="r-bar-track"><div class="r-bar-fill" style="width: <%= reviewStats.getPercent(reviewStats.getStar4()) %>%;"></div></div>
                            <span class="r-bar-count"><%= reviewStats.getStar4() %></span>
                        </div>
                        <div class="r-bar-row">
                            <span>3 ★</span>
                            <div class="r-bar-track"><div class="r-bar-fill" style="width: <%= reviewStats.getPercent(reviewStats.getStar3()) %>%;"></div></div>
                            <span class="r-bar-count"><%= reviewStats.getStar3() %></span>
                        </div>
                        <div class="r-bar-row">
                            <span>2 ★</span>
                            <div class="r-bar-track"><div class="r-bar-fill" style="width: <%= reviewStats.getPercent(reviewStats.getStar2()) %>%;"></div></div>
                            <span class="r-bar-count"><%= reviewStats.getStar2() %></span>
                        </div>
                        <div class="r-bar-row">
                            <span>1 ★</span>
                            <div class="r-bar-track"><div class="r-bar-fill" style="width: <%= reviewStats.getPercent(reviewStats.getStar1()) %>%;"></div></div>
                            <span class="r-bar-count"><%= reviewStats.getStar1() %></span>
                        </div>
                    </div>
                </div>

                <!-- Bộ lọc đầy đủ từ 1 đến 5 sao, Có hình ảnh, Có gia công -->
                <div class="review-filter-pills" style="flex-wrap:wrap;gap:8px;">
                    <a href="product-detail?id=<%= product.getId() %>#sec-danhgia"
                       class="r-pill <%= (starFilter == null && !hasImage && !hasCustom) ? "active" : "" %>">
                        Tất cả (<%= reviewStats.getTotalCount() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&star=5#sec-danhgia"
                       class="r-pill <%= (starFilter != null && starFilter == 5) ? "active" : "" %>">
                        5 sao (<%= reviewStats.getStar5() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&star=4#sec-danhgia"
                       class="r-pill <%= (starFilter != null && starFilter == 4) ? "active" : "" %>">
                        4 sao (<%= reviewStats.getStar4() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&star=3#sec-danhgia"
                       class="r-pill <%= (starFilter != null && starFilter == 3) ? "active" : "" %>">
                        3 sao (<%= reviewStats.getStar3() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&star=2#sec-danhgia"
                       class="r-pill <%= (starFilter != null && starFilter == 2) ? "active" : "" %>">
                        2 sao (<%= reviewStats.getStar2() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&star=1#sec-danhgia"
                       class="r-pill <%= (starFilter != null && starFilter == 1) ? "active" : "" %>">
                        1 sao (<%= reviewStats.getStar1() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&hasImage=1#sec-danhgia"
                       class="r-pill <%= hasImage ? "active" : "" %>">
                        📷 Có hình ảnh (<%= reviewStats.getWithImagesCount() %>)
                    </a>
                    <a href="product-detail?id=<%= product.getId() %>&hasCustom=1#sec-danhgia"
                       class="r-pill <%= hasCustom ? "active" : "" %>">
                        🛠️ Có gia công (<%= reviewStats.getWithCustomCount() %>)
                    </a>
                </div>

                <% if (reviewItems == null || reviewItems.isEmpty()) { %>
                <div style="padding:36px 20px;text-align:center;color:#64748B;background:#F8FAFC;border-radius:10px;border:1px dashed #CBD5E1;margin-top:14px;">
                    Chưa có bài đánh giá nào khớp với tiêu chí lọc này.
                    <div style="margin-top:10px;">
                        <a href="product-detail?id=<%= product.getId() %>#sec-danhgia" style="color:#1B64F2;font-weight:700;">Xem tất cả đánh giá</a>
                    </div>
                </div>
                <% } else { %>
                <% for (ReviewItem rv : reviewItems) { %>
                <div class="review-item-card">
                    <div class="review-user-head">
                        <div class="rev-avatar"><%= rv.getAvatarText() %></div>
                        <div>
                            <div>
                                <strong style="font-size: 13px; margin-right: 6px;"><%= rv.getReviewerName() %></strong>
                                <span class="badge-verified-green">Đã mua hàng</span>
                                <% if (rv.isCustomService()) { %>
                                <span style="background:#FFF7ED;color:#EA580C;font-size:11px;font-weight:700;padding:2px 8px;border-radius:12px;margin-left:4px;">🛠️ Đơn có gia công</span>
                                <% } %>
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

                    <!-- Hiển thị ảnh đánh giá thực tế nếu có -->
                    <% String[] imgs = rv.getImageUrlArray();
                        if (imgs.length > 0) { %>
                    <div class="review-photos-row" style="margin-top:10px;">
                        <% for (String imgUrl : imgs) {
                            if (!imgUrl.isBlank()) { %>
                        <img src="<%= imgUrl.trim() %>" alt="Ảnh thực tế từ người mua" class="rev-real-img"
                             onclick="openLightbox('<%= imgUrl.trim() %>')">
                        <%  }
                        } %>
                    </div>
                    <% } %>

                    <!-- Thanh tương tác: Hữu ích (Like), Không hữu ích (Dislike) & Trả lời -->
                    <div class="review-actions-line" style="display:flex;align-items:center;gap:10px;margin-top:12px;">
                        <a href="review-action?act=vote&reviewId=<%= rv.getId() %>&helpful=1&productId=<%= product.getId() %>"
                           class="rev-vote-btn" title="Đánh giá này hữu ích">
                            👍 Hữu ích (<%= rv.getHelpfulCount() %>)
                        </a>
                        <a href="review-action?act=vote&reviewId=<%= rv.getId() %>&helpful=0&productId=<%= product.getId() %>"
                           class="rev-vote-btn" title="Đánh giá này không hữu ích">
                            👎 Không hữu ích (<%= rv.getUnhelpfulCount() %>)
                        </a>
                        <button type="button" class="rev-vote-btn" style="cursor:pointer;color:#1B64F2;"
                                onclick="toggleReplyForm(<%= rv.getId() %>)">
                            💬 Trả lời (<%= rv.getReplies().size() %>)
                        </button>
                    </div>

                    <!-- Danh sách phản hồi dưới đánh giá (Của Chủ xưởng, Admin, Khách hàng) -->
                    <% if (!rv.getReplies().isEmpty()) { %>
                    <div class="rev-reply-thread">
                        <% for (ReviewReplyItem rep : rv.getReplies()) {
                            String badgeCls = "customer";
                            if ("Chủ xưởng".equalsIgnoreCase(rep.getRoleBadge())) badgeCls = "seller";
                            else if ("Quản trị viên".equalsIgnoreCase(rep.getRoleBadge())) badgeCls = "admin";
                        %>
                        <div class="rev-reply-item">
                            <div>
                                <strong style="color:#0F172A;"><%= rep.getReplierName() %></strong>
                                <span class="rev-role-badge <%= badgeCls %>"><%= rep.getRoleBadge() %></span>
                                <span style="font-size:11px;color:#94A3B8;margin-left:6px;"><%= rep.getCreatedAt() %></span>
                            </div>
                            <p style="color:#334155;margin:4px 0 0 0;"><%= rep.getComment() %></p>
                        </div>
                        <% } %>
                    </div>
                    <% } %>

                    <!-- Khung nhập câu trả lời -->
                    <div id="replyFormBox-<%= rv.getId() %>" style="display:none;margin-top:10px;">
                        <% if (currentUser == null) { %>
                        <div style="font-size:12px;color:#64748B;background:#F8FAFC;padding:8px 12px;border-radius:6px;">
                            Vui lòng <a href="login?redirect=<%= request.getContextPath() %>/product-detail?id=<%= product.getId() %>" style="color:#1B64F2;font-weight:700;">Đăng nhập</a> để trả lời đánh giá này.
                        </div>
                        <% } else { %>
                        <form action="review-action" method="POST" style="display:flex;gap:8px;">
                            <input type="hidden" name="act" value="reply">
                            <input type="hidden" name="reviewId" value="<%= rv.getId() %>">
                            <input type="hidden" name="productId" value="<%= product.getId() %>">
                            <input type="text" name="replyComment" required maxlength="500"
                                   placeholder="Phản hồi dưới tên <%= currentUser.getFullName() %>..."
                                   style="flex:1;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;font-size:13px;">
                            <button type="submit" class="btn btn-blue" style="height:36px;padding:0 16px;font-size:12px;">Gửi phản hồi</button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <% } %>

                <!-- Nút Xem thêm đánh giá (Mỗi lần bấm tải thêm 15 đánh giá tiếp theo) -->
                <div style="margin-top:16px;text-align:center;">
                    <div style="font-size:12px;color:#64748B;margin-bottom:8px;">
                        Đang hiển thị <strong><%= reviewItems.size() %></strong> / <strong><%= filteredReviewCount %></strong> đánh giá
                    </div>
                    <% if (filteredReviewCount > reviewItems.size()) {
                        int nextLimit = revLimit + 15;
                        int remaining = filteredReviewCount - reviewItems.size();
                    %>
                    <a href="<%= filterQueryBase %>&revLimit=<%= nextLimit %>#sec-danhgia"
                       class="btn-more-reviews" style="display:inline-block;text-decoration:none;width:auto;padding:10px 28px;">
                        Xem thêm đánh giá (còn <%= remaining %> đánh giá) ↓
                    </a>
                    <% } %>
                </div>
                <% } %>
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
                    <strong>5.720.000₫</strong>
                </div>
                <form method="post" action="<%= request.getContextPath() %>/cart">
                    <input type="hidden" name="action" value="addBundle">
                    <input type="hidden" name="productId" value="4">
                    <input type="hidden" name="productId" value="5">
                    <input type="hidden" name="productId" value="6">
                    <input type="hidden" name="productId" value="7">
                    <button type="submit" class="btn-full-blue" style="border:none;cursor:pointer;width:100%;">Thêm cả combo vào giỏ</button>
                </form>
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

<!-- Modal phóng to ảnh đánh giá -->
<div class="img-lightbox-modal" id="imgLightbox" onclick="closeLightbox()">
    <img id="lightboxImg" src="" alt="Ảnh phóng to">
</div>

<jsp:include page="includes/footer.jsp" />

<script>
    function formatCurrencyVND(amount) {
        return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") + "₫";
    }

    function toggleReplyForm(revId) {
        const el = document.getElementById('replyFormBox-' + revId);
        if (el) {
            el.style.display = (el.style.display === 'none' || el.style.display === '') ? 'block' : 'none';
        }
    }

    function openLightbox(src) {
        const modal = document.getElementById('imgLightbox');
        const img = document.getElementById('lightboxImg');
        if (modal && img) {
            img.src = src;
            modal.classList.add('show');
        }
    }

    function closeLightbox() {
        const modal = document.getElementById('imgLightbox');
        if (modal) modal.classList.remove('show');
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

    // 4. Tương tác chọn Plate & Tự động cập nhật Giá tiền
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