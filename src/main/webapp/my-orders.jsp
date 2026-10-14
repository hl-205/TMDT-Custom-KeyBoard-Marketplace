<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn hàng của tôi - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> › <a href="#">Tài khoản</a> › <strong>Đơn hàng của tôi</strong>
    </div>

    <div class="account-layout-2col">
        <!-- Cột trái Sidebar Tài khoản -->
        <aside class="account-sidebar-card">
            <div class="acc-user-box">
                <div class="acc-avatar-circle">DT</div>
                <div>
                    <strong style="display:block;font-size:14px;">Lê Tùng Dương</strong>
                    <span style="font-size:12px;color:#64748B;">Thành viên Bạc · 1.240 điểm</span>
                </div>
            </div>

            <div class="acc-nav-group-title">Tài khoản</div>
            <a href="#" class="acc-nav-link"><span>👤 Hồ sơ cá nhân</span></a>
            <a href="#" class="acc-nav-link"><span>📍 Sổ địa chỉ</span></a>
            <a href="#" class="acc-nav-link"><span>🔒 Bảo mật</span></a>

            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link active"><span>📦 Đơn hàng của tôi</span><span class="badge">3</span></a>
            <a href="review?orderCode=KH-281044&productId=7" class="acc-nav-link"><span>⭐ Đánh giá của tôi</span></a>

            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <!-- Cột phải Danh sách đơn hàng -->
        <section>
            <!-- Đơn 1: Đang gia công -->
            <div class="order-card-box">
                <div class="order-card-head">
                    <div>
                        <strong style="margin-right:8px;">SwitchHouse</strong>
                        <span class="shop-badge-pill workshop">Đơn custom</span>
                        <span style="font-size:12px;color:#64748B;margin-left:8px;">Mã đơn <strong>#KH-284193</strong> · 26/09/2026</span>
                    </div>
                    <span style="background:#FFF7ED;color:#EA580C;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">⚙️ Đang gia công</span>
                </div>
                <div class="order-item-row">
                    <div>
                        <strong>Bàn phím custom theo cấu hình — Build #B-7742</strong>
                        <p style="font-size:12px;color:#64748B;">Kit Tofu60 2.0 · Oil King ×70 · GMK Olivia · Full lube</p>
                    </div>
                    <strong>5.320.000₫</strong>
                </div>
                <div class="order-card-foot">
                    <div>Tổng tiền: <strong style="font-size:16px;color:#EA580C;">5.320.000₫</strong></div>
                    <div style="display:flex;gap:10px;">
                        <a href="product-detail?id=1" class="btn btn-outline-gray">Xem sản phẩm</a>
                    </div>
                </div>
            </div>

            <!-- Đơn 2: Đã hoàn thành (Có nút Đánh giá sản phẩm đã mua - Chuẩn Frame 14) -->
            <div class="order-card-box">
                <div class="order-card-head">
                    <div>
                        <strong style="margin-right:8px;">Akko Official</strong>
                        <span style="font-size:12px;color:#64748B;">Mã đơn <strong>#KH-281044</strong> · 18/09/2026</span>
                    </div>
                    <span style="background:#DCFCE7;color:#15803D;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">✓ Hoàn thành</span>
                </div>
                <div class="order-item-row">
                    <div>
                        <strong>Keycap Akko Black & Pink ASA profile — 158 phím</strong>
                        <p style="font-size:12px;color:#64748B;">Phân loại: Black & Pink · ×1</p>
                    </div>
                    <strong>690.000₫</strong>
                </div>
                <div class="order-card-foot">
                    <div>Tổng tiền: <strong style="font-size:16px;color:#EA580C;">690.000₫</strong></div>
                    <div style="display:flex;gap:10px;">
                        <a href="product-detail?id=7" class="btn btn-outline-gray">Mua lại</a>
                        <a href="review?orderCode=KH-281044&productId=7" class="btn-orange-review">★ Đánh giá nhận 50k</a>
                    </div>
                </div>
            </div>

            <!-- Đơn 3: Kit Tofu60 2.0 hoàn thành để test đánh giá trực tiếp trên Kit số 1 -->
            <div class="order-card-box">
                <div class="order-card-head">
                    <div>
                        <strong style="margin-right:8px;">KeebLab Store</strong>
                        <span style="font-size:12px;color:#64748B;">Mã đơn <strong>#KH-280912</strong> · 12/09/2026</span>
                    </div>
                    <span style="background:#DCFCE7;color:#15803D;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">✓ Hoàn thành</span>
                </div>
                <div class="order-item-row">
                    <div>
                        <strong>Kit Tofu60 2.0 Aluminium — Hotswap, gasket mount, foam sẵn</strong>
                        <p style="font-size:12px;color:#64748B;">Phân loại: Silver / Brass plate · ×1</p>
                    </div>
                    <strong>2.690.000₫</strong>
                </div>
                <div class="order-card-foot">
                    <div>Tổng tiền: <strong style="font-size:16px;color:#EA580C;">2.690.000₫</strong></div>
                    <div style="display:flex;gap:10px;">
                        <a href="product-detail?id=1" class="btn btn-outline-gray">Mua lại</a>
                        <a href="review?orderCode=KH-280912&productId=1&variant=Ph%C3%A2n%20lo%E1%BA%A1i:%20Silver%20/%20Brass%20plate" class="btn-orange-review">★ Đánh giá nhận 50k</a>
                    </div>
                </div>
            </div>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>