<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        <aside class="sidebar-categories">
            <ul class="sidebar-list">
                <li class="active"><a href="category.jsp?cat=1"><span class="icon">⌨️</span> Kit bàn phím <span class="count">1.240</span></a></li>
                <li><a href="category.jsp?cat=2"><span class="icon">⚙️</span> Switch <span class="count">860</span></a></li>
                <li><a href="category.jsp?cat=3"><span class="icon">🎨</span> Keycap <span class="count">1.520</span></a></li>
                <li><a href="category.jsp?cat=4"><span class="icon">⚖️</span> Stabilizer <span class="count">310</span></a></li>
                <li><a href="category.jsp?cat=5"><span class="icon">🔩</span> Plate & foam <span class="count">220</span></a></li>
                <li><a href="category.jsp?cat=5"><span class="icon">🔌</span> Cáp & phụ kiện <span class="count">980</span></a></li>
                <li><a href="category.jsp?cat=6"><span class="icon">🛠️</span> Dịch vụ gia công <span class="count">142</span></a></li>
                <li><a href="#"><span class="icon">📦</span> Build sẵn <span class="count">74</span></a></li>
                <li class="highlight"><a href="#"><span class="icon">🔥</span> Group buy <span class="count">18</span></a></li>
            </ul>
        </aside>

        <div class="main-banner">
            <div class="banner-text">
                <p class="subtitle">Sàn bàn phím custom số 1 Việt Nam</p>
                <h2>Tự build bàn phím<br>đúng gu của bạn</h2>
                <p class="desc">Chọn kit, switch, keycap và gói gia công trong một luồng duy nhất. Hệ thống tự kiểm tra tương thích trước khi bạn đặt hàng.</p>
                <div class="banner-buttons">
                    <a href="custom-builder.jsp" class="btn btn-orange">⚙️ Bắt đầu build ngay</a>
                    <a href="product-detail?id=1" class="btn btn-white">Xem build mẫu</a>
                </div>
                <div class="banner-stats">
                    <div class="stat-item"><strong>4.800+</strong><span>Sản phẩm</span></div>
                    <div class="stat-item"><strong>142</strong><span>Xưởng gia công</span></div>
                    <div class="stat-item"><strong>26k</strong><span>Đơn đã giao</span></div>
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
                <h4>Group buy<br>GMK Olivia++</h4>
                <p>Đóng đơn sau 6 ngày</p>
                <a href="product-detail?id=3" class="link-arrow">Tham gia ngay →</a>
            </div>
            <div class="small-banner service-banner">
                <h4>Gói lube trọn bộ<br>chỉ 750.000đ</h4>
                <p>Xưởng thẩm định, bảo hành 6 tháng</p>
                <a href="#" class="link-arrow green">Đặt dịch vụ →</a>
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
                <p>142 shop đã xác minh</p>
            </div>
        </div>
    </div>

    <section class="home-section">
        <div class="section-head">
            <h3>Danh mục nổi bật</h3>
            <a href="category.jsp" class="view-all-link">Xem tất cả →</a>
        </div>
        <div class="featured-cat-grid">
            <a href="category.jsp?cat=1" class="cat-box">
                <div class="cat-icon-circle blue">⌨️</div>
                <strong>Kit bàn phím</strong>
                <span>1.240 sp</span>
            </a>
            <a href="category.jsp?cat=2" class="cat-box">
                <div class="cat-icon-circle orange">⚙️</div>
                <strong>Switch</strong>
                <span>860 sp</span>
            </a>
            <a href="category.jsp?cat=3" class="cat-box">
                <div class="cat-icon-circle yellow">🎨</div>
                <strong>Keycap</strong>
                <span>1.520 sp</span>
            </a>
            <a href="category.jsp?cat=4" class="cat-box">
                <div class="cat-icon-circle green">⚖️</div>
                <strong>Stabilizer</strong>
                <span>310 sp</span>
            </a>
            <a href="category.jsp?cat=5" class="cat-box">
                <div class="cat-icon-circle purple">🔌</div>
                <strong>Phụ kiện</strong>
                <span>980 sp</span>
            </a>
            <a href="category.jsp?cat=6" class="cat-box">
                <div class="cat-icon-circle gray">🛠️</div>
                <strong>Dịch vụ gia công</strong>
                <span>142 shop</span>
            </a>
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
                <a href="custom-builder.jsp" class="btn btn-blue">Mở Custom Builder</a>
                <a href="guide.jsp" class="btn btn-outline-gray">Xem hướng dẫn</a>
            </div>
        </div>
        <div class="builder-promo-right">
            <div class="mini-build-card">
                <div class="mini-build-head">
                    <strong>Cấu hình của bạn</strong>
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
                    🔒 Đã giữ chỗ tồn kho · còn 14:22
                </div>
            </div>
        </div>
    </section>

    <div class="flash-sale-banner">
        <div>
            <span class="fs-subtitle">FLASH SALE</span>
            <h3>Giảm đến 40% switch & keycap</h3>
        </div>
        <div class="fs-right">
            <span class="fs-label">Kết thúc sau</span>
            <div class="fs-timer">
                <span>04</span> <span>12</span> <span>38</span>
            </div>
            <a href="category.jsp" class="btn btn-white-orange">Xem deal</a>
        </div>
    </div>

    <section class="home-section">
        <div class="section-head">
            <h3>Sản phẩm bán chạy</h3>
            <a href="category.jsp" class="view-all-link">Xem tất cả →</a>
        </div>
        <div class="product-grid-6">
            <a href="product-detail?id=1" class="p-card">
                <span class="p-badge discount">-18%</span>
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-kit"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> KeebLab Store</div>
                <h4 class="p-name">Kit Tofu60 2.0 Aluminium — Hotswap...</h4>
                <div class="p-price">2.690.000đ <del>3.280.000đ</del></div>
                <div class="p-meta"><span class="stars">★★★★★ 4.9</span><span>Đã bán 1.2k</span></div>
            </a>

            <a href="product-detail?id=2" class="p-card">
                <span class="p-badge new">Mới</span>
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-switch dark"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> SwitchHouse</div>
                <h4 class="p-name">Switch Gateron Oil King — Linear 55g (bịch 70...</h4>
                <div class="p-price">890.000đ</div>
                <div class="p-meta"><span class="stars">★★★★★ 4.7</span><span>Đã bán 430</span></div>
            </a>

            <a href="product-detail?id=3" class="p-card">
                <span class="p-badge preorder">Pre-order</span>
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-keycap pink"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> Keycap Đông Nam</div>
                <h4 class="p-name">Keycap GMK Olivia++ Cherry profile — bộ...</h4>
                <div class="p-price">4.150.000đ</div>
                <div class="p-meta"><span class="stars">★★★★★ 5.0</span><span>Đã bán 86</span></div>
            </a>

            <a href="product-detail?id=4" class="p-card">
                <span class="p-badge discount">-10%</span>
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-kit dark"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> Keychron VN</div>
                <h4 class="p-name">Kit Keychron Q1 Pro QMK/VIA — knob...</h4>
                <div class="p-price">4.290.000đ <del>4.790.000đ</del></div>
                <div class="p-meta"><span class="stars">★★★★★ 4.8</span><span>Đã bán 2.1k</span></div>
            </a>

            <a href="product-detail?id=5" class="p-card">
                <span class="p-badge discount">-24%</span>
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-switch yellow"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> Akko Official</div>
                <h4 class="p-name">Switch Akko Cream Yellow V3 Pro — Linear...</h4>
                <div class="p-price">320.000đ <del>420.000đ</del></div>
                <div class="p-meta"><span class="stars">★★★★★ 4.6</span><span>Đã bán 3.4k</span></div>
            </a>

            <a href="product-detail?id=6" class="p-card">
                <span class="p-wish">♡</span>
                <div class="p-thumb"><div class="illus-switch purple"></div></div>
                <div class="p-Shop"><span class="dot-green"></span> SwitchHouse</div>
                <h4 class="p-name">Stabilizer Durock V2 PCB-mount — đã lube...</h4>
                <div class="p-price">420.000đ</div>
                <div class="p-meta"><span class="stars">★★★★★ 4.8</span><span>Đã bán 760</span></div>
            </a>
        </div>
    </section>

    <section class="home-section">
        <div class="section-head">
            <h3>Shop gia công uy tín</h3>
            <a href="#" class="view-all-link">Xem tất cả →</a>
        </div>
        <div class="shop-cards-grid">
            <a href="shop.jsp?id=1" class="shop-mini-card">
                <div class="shop-avatar blue">KL</div>
                <div class="shop-mini-info">
                    <strong>KeebLab Store</strong>
                    <p>★ 4.9 · 12.4k lượt theo dõi</p>
                    <div class="shop-badges">
                        <span class="s-badge verified">Đã xác minh</span>
                        <span class="s-badge workshop">Gia công</span>
                    </div>
                </div>
            </a>
            <a href="shop.jsp?id=2" class="shop-mini-card">
                <div class="shop-avatar orange">SH</div>
                <div class="shop-mini-info">
                    <strong>SwitchHouse</strong>
                    <p>★ 4.8 · 8.9k lượt theo dõi</p>
                    <div class="shop-badges">
                        <span class="s-badge verified">Đã xác minh</span>
                        <span class="s-badge workshop">Gia công</span>
                    </div>
                </div>
            </a>
            <a href="shop.jsp?id=4" class="shop-mini-card">
                <div class="shop-avatar purple">KĐ</div>
                <div class="shop-mini-info">
                    <strong>Keycap Đông Nam</strong>
                    <p>★ 5.0 · 4.2k lượt theo dõi</p>
                    <div class="shop-badges">
                        <span class="s-badge verified">Đã xác minh</span>
                        <span class="s-badge workshop">Gia công</span>
                    </div>
                </div>
            </a>
            <a href="shop.jsp?id=6" class="shop-mini-card">
                <div class="shop-avatar green">MG</div>
                <div class="shop-mini-info">
                    <strong>Monsgeek VN</strong>
                    <p>★ 4.7 · 6.1k lượt theo dõi</p>
                    <div class="shop-badges">
                        <span class="s-badge verified">Đã xác minh</span>
                        <span class="s-badge workshop">Gia công</span>
                    </div>
                </div>
            </a>
        </div>
    </section>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>