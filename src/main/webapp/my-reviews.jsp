<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.ProductDAO.UserReviewItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    if (request.getAttribute("myReviews") == null) {
        response.sendRedirect("my-reviews");
        return;
    }
    List<UserReviewItem> myReviews = (List<UserReviewItem>) request.getAttribute("myReviews");
    Set<Integer> reviewedIds = (Set<Integer>) request.getAttribute("reviewedProductIds");
    if (reviewedIds == null) reviewedIds = new HashSet<>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá của tôi - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> › <a href="my-orders">Tài khoản</a> › <strong>Đánh giá của tôi</strong>
    </div>

    <div class="account-layout-2col">
        <!-- Sidebar hiển thị đúng User đang đăng nhập -->
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
            <a href="my-orders" class="acc-nav-link"><span>🔒 Bảo mật</span></a>

            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link"><span>📦 Đơn hàng của tôi</span><span class="badge">3</span></a>
            <a href="my-reviews" class="acc-nav-link active"><span>⭐ Đánh giá của tôi</span></a>

            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <!-- Nội dung Quản lý Đánh giá -->
        <section>
            <% if ("submitted".equals(request.getParameter("msg"))) { %>
            <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-weight:600;font-size:13px;">
                ✓ Gửi đánh giá thành công! Tài khoản của bạn đã được cộng thêm +50 điểm thưởng.
            </div>
            <% } %>

            <!-- Khối 1: Sản phẩm đã mua chờ đánh giá -->
            <div class="order-card-box">
                <h3 style="font-size:16px;font-weight:800;margin-bottom:12px;">Sản phẩm chờ đánh giá</h3>
                <% boolean hasPending = !reviewedIds.contains(7) || !reviewedIds.contains(1); %>
                <% if (!hasPending) { %>
                <p style="font-size:13px;color:#64748B;">Bạn đã đánh giá toàn bộ các đơn hàng hoàn thành.</p>
                <% } else { %>
                <% if (!reviewedIds.contains(7)) { %>
                <div class="order-item-row" style="border-bottom:1px solid #F1F5F9;padding:12px 0;">
                    <div>
                        <strong>Keycap Akko Black & Pink ASA profile — 158 phím</strong>
                        <p style="font-size:12px;color:#64748B;">Đơn #KH-281044 · Akko Official · Phân loại: Black & Pink</p>
                    </div>
                    <a href="review?orderCode=KH-281044&productId=7" class="btn-orange-review">★ Viết đánh giá (+50 điểm)</a>
                </div>
                <% } %>
                <% if (!reviewedIds.contains(1)) { %>
                <div class="order-item-row" style="padding:12px 0;">
                    <div>
                        <strong>Kit Tofu60 2.0 Aluminium — Hotswap, gasket mount, foam sẵn</strong>
                        <p style="font-size:12px;color:#64748B;">Đơn #KH-280912 · KeebLab Store · Phân loại: Silver / Brass plate</p>
                    </div>
                    <a href="review?orderCode=KH-280912&productId=1&variant=Ph%C3%A2n%20lo%E1%BA%A1i:%20Silver%20/%20Brass%20plate" class="btn-orange-review">★ Viết đánh giá (+50 điểm)</a>
                </div>
                <% } %>
                <% } %>
            </div>

            <!-- Khối 2: Lịch sử đánh giá đã đăng của User -->
            <div class="order-card-box">
                <h3 style="font-size:16px;font-weight:800;margin-bottom:14px;">Đánh giá đã đăng của bạn (<%= myReviews.size() %>)</h3>
                <% if (myReviews.isEmpty()) { %>
                <p style="font-size:13px;color:#64748B;">Bạn chưa đăng đánh giá nào. Hãy chọn một sản phẩm phía trên để đánh giá nhé!</p>
                <% } else { %>
                <% for (UserReviewItem item : myReviews) { %>
                <div style="border-top:1px solid #F1F5F9;padding:16px 0;">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
                        <a href="product-detail?id=<%= item.getProductId() %>#sec-danhgia" style="font-weight:700;color:#1B64F2;font-size:14px;">
                            <%= item.getProductName() %>
                        </a>
                        <span style="font-size:12px;color:#94A3B8;"><%= item.getReviewDate() %></span>
                    </div>
                    <div style="font-size:12px;color:#64748B;margin-bottom:8px;">
                                <span style="color:#F59E0B;font-weight:700;margin-right:6px;">
                                    <% for (int s = 1; s <= 5; s++) { %><%= s <= item.getRating() ? "★" : "☆" %><% } %>
                                </span>
                        <%= item.getVariantInfo() %>
                    </div>
                    <p style="font-size:13px;color:#1E293B;background:#F8FAFC;padding:10px 14px;border-radius:8px;border:1px solid #E2E8F0;">
                        <%= item.getComment() %>
                    </p>
                    <div style="margin-top:8px;text-align:right;">
                        <a href="product-detail?id=<%= item.getProductId() %>#sec-danhgia" style="font-size:12px;color:#1B64F2;font-weight:600;">Xem trên trang sản phẩm →</a>
                    </div>
                </div>
                <% } %>
                <% } %>
            </div>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>