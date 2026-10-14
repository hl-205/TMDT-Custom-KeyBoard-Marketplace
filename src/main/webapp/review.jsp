<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    Product product = (Product) request.getAttribute("product");
    if (product == null) {
        response.sendRedirect("review?orderCode=KH-281044&productId=7");
        return;
    }
    String orderCode = (String) request.getAttribute("orderCode");
    String variant = (String) request.getAttribute("variant");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá sản phẩm - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
    <style>
        .sub-star-group {
            display: inline-flex;
            gap: 4px;
            margin-top: 4px;
        }
        .sub-star-btn {
            font-size: 20px;
            color: #CBD5E1;
            cursor: pointer;
            user-select: none;
            transition: color 0.15s;
        }
        .sub-star-btn.active {
            color: #F59E0B;
        }
    </style>
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <a href="my-orders">Đơn hàng của tôi</a> ›
        <strong>Đánh giá đơn #<%= orderCode %></strong>
    </div>

    <div class="account-layout-2col">
        <!-- Sidebar hiển thị đúng tên & avatar của tài khoản đang đăng nhập -->
        <aside class="account-sidebar-card">
            <div class="acc-user-box">
                <div class="acc-avatar-circle"><%= currentUser.getAvatarText() %></div>
                <div>
                    <strong style="display:block;font-size:14px;"><%= currentUser.getFullName() %></strong>
                    <span style="font-size:12px;color:#64748B;"><%= currentUser.getRankName() %> · <%= currentUser.getPoints() %> điểm</span>
                </div>
            </div>
            <div class="acc-nav-group-title">Tài khoản</div>
            <a href="my-orders" class="acc-nav-link"><span>👤 Hồ sơ cá nhân</span></a>
            <a href="my-orders" class="acc-nav-link"><span>📍 Sổ địa chỉ</span></a>
            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link"><span>📦 Đơn hàng của tôi</span><span class="badge">3</span></a>
            <a href="my-reviews" class="acc-nav-link active"><span>⭐ Đánh giá của tôi</span></a>
            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <!-- Form Đánh giá sản phẩm -->
        <section class="review-form-card">
            <div class="review-card-top">
                <div>
                    <h2 style="font-size:20px;font-weight:800;">Đánh giá sản phẩm</h2>
                    <span style="font-size:12px;color:#64748B;">Đơn #<%= orderCode %> · <%= product.getShopName() %> · Giao thành công 18/09/2026</span>
                </div>
                <span class="voucher-pill-orange">🎁 Nhận 50.000đ voucher</span>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div style="background:#FEF2F2;border:1px solid #FECACA;color:#B91C1C;padding:12px;border-radius:8px;margin-bottom:16px;font-size:13px;">
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <div class="review-product-strip">
                <div class="illus-keycap" style="width:48px;height:48px;"></div>
                <div>
                    <strong style="font-size:15px;display:block;"><%= product.getName() %></strong>
                    <span style="font-size:12px;color:#64748B;"><%= variant %></span>
                </div>
            </div>

            <form action="review" method="POST" id="reviewForm">
                <input type="hidden" name="productId" value="<%= product.getId() %>">
                <input type="hidden" name="orderCode" value="<%= orderCode %>">
                <input type="hidden" name="variant" value="<%= variant %>">
                <input type="hidden" name="rating" id="ratingValueInput" value="5">
                <input type="hidden" name="qualityRating" id="qualityRatingInput" value="5">
                <input type="hidden" name="accuracyRating" id="accuracyRatingInput" value="5">
                <input type="hidden" name="deliveryRating" id="deliveryRatingInput" value="5">

                <strong style="font-size:13px;">Bạn hài lòng đến mức nào?</strong>
                <div class="star-picker-row" id="starPicker">
                    <span class="star-btn-big active" data-val="1">★</span>
                    <span class="star-btn-big active" data-val="2">★</span>
                    <span class="star-btn-big active" data-val="3">★</span>
                    <span class="star-btn-big active" data-val="4">★</span>
                    <span class="star-btn-big active" data-val="5">★</span>
                    <span class="star-rating-text" id="ratingLabelText">Tuyệt vời</span>
                </div>

                <!-- Đánh giá chi tiết 3 tiêu chí có thể click chọn sao độc lập -->
                <strong style="font-size:13px;display:block;margin-bottom:10px;">Đánh giá chi tiết</strong>
                <div class="sub-ratings-3col">
                    <div>
                        <span style="font-size:12px;color:#64748B;display:block;">Chất lượng</span>
                        <div class="sub-star-group" data-target="qualityRatingInput">
                            <span class="sub-star-btn active" data-val="1">★</span>
                            <span class="sub-star-btn active" data-val="2">★</span>
                            <span class="sub-star-btn active" data-val="3">★</span>
                            <span class="sub-star-btn active" data-val="4">★</span>
                            <span class="sub-star-btn active" data-val="5">★</span>
                        </div>
                    </div>
                    <div>
                        <span style="font-size:12px;color:#64748B;display:block;">Đúng mô tả</span>
                        <div class="sub-star-group" data-target="accuracyRatingInput">
                            <span class="sub-star-btn active" data-val="1">★</span>
                            <span class="sub-star-btn active" data-val="2">★</span>
                            <span class="sub-star-btn active" data-val="3">★</span>
                            <span class="sub-star-btn active" data-val="4">★</span>
                            <span class="sub-star-btn active" data-val="5">★</span>
                        </div>
                    </div>
                    <div>
                        <span style="font-size:12px;color:#64748B;display:block;">Tốc độ giao</span>
                        <div class="sub-star-group" data-target="deliveryRatingInput">
                            <span class="sub-star-btn active" data-val="1">★</span>
                            <span class="sub-star-btn active" data-val="2">★</span>
                            <span class="sub-star-btn active" data-val="3">★</span>
                            <span class="sub-star-btn active" data-val="4">★</span>
                            <span class="sub-star-btn active" data-val="5">★</span>
                        </div>
                    </div>
                </div>

                <strong style="font-size:13px;display:block;margin-bottom:10px;">Nhận xét của bạn</strong>
                <div class="quick-tags-wrap">
                    <label class="q-tag-label">
                        <input type="checkbox" name="quickTags" value="Màu đẹp đúng ảnh" checked>
                        <span class="q-tag-span">Màu đẹp đúng ảnh</span>
                    </label>
                    <label class="q-tag-label">
                        <input type="checkbox" name="quickTags" value="Chất nhựa dày" checked>
                        <span class="q-tag-span">Chất nhựa dày</span>
                    </label>
                    <label class="q-tag-label">
                        <input type="checkbox" name="quickTags" value="Legend sắc nét">
                        <span class="q-tag-span">Legend sắc nét</span>
                    </label>
                    <label class="q-tag-label">
                        <input type="checkbox" name="quickTags" value="Đóng gói kỹ">
                        <span class="q-tag-span">Đóng gói kỹ</span>
                    </label>
                    <label class="q-tag-label">
                        <input type="checkbox" name="quickTags" value="Giao nhanh">
                        <span class="q-tag-span">Giao nhanh</span>
                    </label>
                </div>

                <textarea name="comment" id="reviewComment" class="review-textarea" maxlength="2000"
                          placeholder="Chia sẻ trải nghiệm thực tế của bạn về sản phẩm (âm gõ, độ hoàn thiện, đóng gói...)"
                          required><%= request.getAttribute("comment") != null ? request.getAttribute("comment") : "" %></textarea>
                <div style="display:flex;justify-content:space-between;font-size:12px;color:#94A3B8;margin:6px 0 20px;">
                    <span id="charMinHint">Tối thiểu 20 ký tự</span>
                    <span><strong id="charCountNum">0</strong> / 2000</span>
                </div>

                <strong style="font-size:13px;">Thêm hình ảnh / video <span style="font-weight:400;color:#94A3B8;">(không bắt buộc — có ảnh được thêm 20k)</span></strong>
                <div class="upload-slot-row">
                    <div class="upload-slot-box"><div class="illus-keycap" style="width:42px;height:42px;"></div></div>
                    <div class="upload-slot-box"><div class="illus-kit" style="width:46px;height:28px;"></div></div>
                    <div class="upload-slot-box"><span style="font-size:20px;">+</span><span>Thêm ảnh</span></div>
                </div>
                <div style="font-size:11px;color:#94A3B8;margin-bottom:18px;">Tối đa 6 ảnh (≤5MB/ảnh) và 1 video (≤30 giây)</div>

                <!-- Tên ẩn danh tự động khớp với Họ & Tên của tài khoản đang đăng nhập -->
                <label style="display:flex;align-items:center;gap:8px;padding:12px;border:1px solid #E2E8F0;border-radius:8px;font-size:13px;margin-bottom:20px;cursor:pointer;">
                    <input type="checkbox" name="anonymous" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                    <span>Hiển thị tên tôi là <strong><%= currentUser.getMaskedName() %></strong> (ẩn danh một phần)</span>
                </label>

                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <span style="font-size:12px;color:#94A3B8;">Đánh giá sẽ hiển thị công khai ngay trên trang sản phẩm</span>
                    <div style="display:flex;gap:10px;">
                        <a href="my-orders" class="btn btn-outline-gray">Để sau</a>
                        <button type="submit" class="btn-orange-review" style="padding:11px 24px;">Gửi đánh giá</button>
                    </div>
                </div>
            </form>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
    // 1. Chọn sao tổng quan
    const stars = document.querySelectorAll('#starPicker .star-btn-big');
    const ratingInput = document.getElementById('ratingValueInput');
    const ratingLabel = document.getElementById('ratingLabelText');
    const labels = {
        1: 'Rất tệ',
        2: 'Không hài lòng',
        3: 'Bình thường',
        4: 'Hài lòng',
        5: 'Tuyệt vời'
    };

    stars.forEach(star => {
        star.addEventListener('click', () => {
            const val = parseInt(star.getAttribute('data-val'), 10);
            ratingInput.value = val;
            ratingLabel.textContent = labels[val];
            stars.forEach(s => {
                const sVal = parseInt(s.getAttribute('data-val'), 10);
                s.classList.toggle('active', sVal <= val);
            });
        });
    });

    // 2. Chọn sao cho 3 tiêu chí Đánh giá chi tiết (Chất lượng, Đúng mô tả, Tốc độ giao)
    const subGroups = document.querySelectorAll('.sub-star-group');
    subGroups.forEach(group => {
        const targetId = group.getAttribute('data-target');
        const hiddenInput = document.getElementById(targetId);
        const subStars = group.querySelectorAll('.sub-star-btn');

        subStars.forEach(st => {
            st.addEventListener('click', () => {
                const val = parseInt(st.getAttribute('data-val'), 10);
                if (hiddenInput) hiddenInput.value = val;
                subStars.forEach(item => {
                    const iVal = parseInt(item.getAttribute('data-val'), 10);
                    item.classList.toggle('active', iVal <= val);
                });
            });
        });
    });

    // 3. Đếm ký tự nhận xét
    const commentArea = document.getElementById('reviewComment');
    const charCountNum = document.getElementById('charCountNum');
    const charMinHint = document.getElementById('charMinHint');
    if (commentArea) {
        commentArea.addEventListener('input', () => {
            const len = commentArea.value.trim().length;
            charCountNum.textContent = len;
            if (len >= 20) {
                charMinHint.textContent = '✓ Đã đủ tối thiểu 20 ký tự';
                charMinHint.style.color = '#16A34A';
            } else {
                charMinHint.textContent = 'Cần thêm ' + (20 - len) + ' ký tự nữa (Tối thiểu 20 ký tự)';
                charMinHint.style.color = '#EF4444';
            }
        });
    }
</script>
</body>
</html>