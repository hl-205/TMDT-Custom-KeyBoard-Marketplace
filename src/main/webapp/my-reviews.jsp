<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="dao.ProductDAO.UserReviewItem" %>
<%@ page import="java.util.List" %>
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
    List<CustomOrder> pendingOrders = (List<CustomOrder>) request.getAttribute("pendingReviewOrders");
    List<UserReviewItem> myReviews = (List<UserReviewItem>) request.getAttribute("myReviews");
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
            <a href="my-orders" class="acc-nav-link"><span>📦 Đơn hàng của tôi</span></a>
            <a href="my-reviews" class="acc-nav-link active"><span>⭐ Đánh giá của tôi</span></a>

            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <section>
            <% if ("submitted".equals(request.getParameter("msg"))) { %>
            <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:12px 16px;border-radius:10px;margin-bottom:16px;font-weight:600;font-size:13px;">
                ✓ Đánh giá của bạn đã được lưu vào Database và hiển thị trên trang sản phẩm (+50 điểm thưởng)!
            </div>
            <% } %>

            <!-- Khối 1: Sản phẩm đã hoàn thành trong bảng orders nhưng chưa đánh giá -->
            <div class="order-card-box">
                <h3 style="font-size:16px;font-weight:800;margin-bottom:12px;">Sản phẩm chờ đánh giá (<%= pendingOrders != null ? pendingOrders.size() : 0 %>)</h3>
                <% if (pendingOrders == null || pendingOrders.isEmpty()) { %>
                <p style="font-size:13px;color:#64748B;">Hiện tại tài khoản <strong><%= currentUser.getFullName() %></strong> không có đơn hàng hoàn thành nào chờ đánh giá.</p>
                <% } else { %>
                <% for (CustomOrder po : pendingOrders) { %>
                <div class="order-item-row" style="border-top:1px solid #F1F5F9;padding:12px 0;">
                    <div>
                        <strong><%= po.getProductName() %></strong>
                        <p style="font-size:12px;color:#64748B;">Đơn #<%= po.getOrderCode() %> · <%= po.getShopName() %> · <%= po.getVariantSummary() %></p>
                    </div>
                    <a href="review?orderCode=<%= po.getOrderCode() %>&productId=<%= po.getProductId() %>" class="btn-orange-review">★ Viết đánh giá (+50 điểm)</a>
                </div>
                <% } %>
                <% } %>
            </div>

            <!-- Khối 2: Các đánh giá thực sự do chính tài khoản này đã đăng trong bảng reviews -->
            <div class="order-card-box">
                <h3 style="font-size:16px;font-weight:800;margin-bottom:14px;">Đánh giá đã đăng của bạn (<%= myReviews.size() %>)</h3>
                <% if (myReviews.isEmpty()) { %>
                <p style="font-size:13px;color:#64748B;">Tài khoản <strong><%= currentUser.getFullName() %></strong> chưa đăng bài đánh giá nào.</p>
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