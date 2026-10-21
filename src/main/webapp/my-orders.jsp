<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    if (request.getAttribute("userOrders") == null) {
        response.sendRedirect("my-orders");
        return;
    }
    List<CustomOrder> userOrders = (List<CustomOrder>) request.getAttribute("userOrders");
    Set<Integer> reviewedIds = (Set<Integer>) request.getAttribute("reviewedProductIds");
    if (reviewedIds == null) reviewedIds = new HashSet<>();
%>
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
        <a href="index.jsp">Trang chủ</a> › <a href="my-orders">Tài khoản</a> › <strong>Đơn hàng của tôi</strong>
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
            <a href="profile" class="acc-nav-link"><span>👤 Thông tin tài khoản</span></a>
            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link active"><span>📦 Đơn hàng của tôi</span><span class="badge"><%= userOrders.size() %></span></a>
            <a href="my-reviews" class="acc-nav-link"><span>⭐ Đánh giá của tôi</span></a>
            <a href="cart" class="acc-nav-link"><span>🛒 Giỏ hàng</span></a>

            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <section>
            <% if (userOrders.isEmpty()) { %>
            <div class="order-card-box" style="text-align:center;padding:48px 24px;">
                <h3 style="font-size:18px;margin-bottom:8px;">Bạn chưa có đơn hàng nào</h3>
                <p style="font-size:13px;color:#64748B;margin-bottom:18px;">Tài khoản <strong><%= currentUser.getFullName() %></strong> hiện chưa phát sinh giao dịch mua hàng trong hệ thống.</p>
                <a href="category" class="btn btn-blue">Khám phá 100+ sản phẩm ngay</a>
            </div>
            <% } else { %>
            <% for (CustomOrder ord : userOrders) { %>
            <div class="order-card-box">
                <div class="order-card-head">
                    <div>
                        <a href="shop?id=<%= ord.getShopId() %>" style="font-weight:800;margin-right:8px;color:#0F172A;"><%= ord.getShopName() %></a>
                        <% if (ord.isCustomOrder()) { %>
                        <span class="shop-badge-pill workshop">Đơn custom</span>
                        <% } %>
                        <span style="font-size:12px;color:#64748B;margin-left:8px;">Mã đơn <strong>#<%= ord.getOrderCode() %></strong></span>
                    </div>
                    <% if ("PROCESSING".equals(ord.getOrderStatus())) { %>
                    <span style="background:#FFF7ED;color:#EA580C;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">⚙️ Đang gia công · <%= ord.getProgressPercent() %>%</span>
                    <% } else if ("COMPLETED".equals(ord.getOrderStatus())) { %>
                    <span style="background:#DCFCE7;color:#15803D;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">✓ Hoàn thành</span>
                    <% } else if ("PENDING".equals(ord.getOrderStatus())) { %>
                    <span style="background:#FEF2F2;color:#DC2626;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;">🕒 Chờ xưởng xác nhận & báo giá</span>
                    <% } else { %>
                    <span style="background:#EFF6FF;color:#1B64F2;font-size:12px;font-weight:700;padding:4px 10px;border-radius:20px;"><%= ord.getOrderStatus() %></span>
                    <% } %>
                </div>

                <div class="order-item-row">
                    <div>
                        <strong><%= ord.getProductName() != null ? ord.getProductName() : ord.getBuildCode() %></strong>
                        <p style="font-size:12px;color:#64748B;"><%= ord.getVariantSummary() %></p>
                    </div>
                    <strong><%= ord.getFormattedTotal() %></strong>
                </div>

                <% if (ord.getShopNote() != null && !ord.getShopNote().isBlank()) { %>
                <div style="background:#F0FDF4;border:1px solid #BBF7D0;border-radius:8px;padding:10px 14px;margin-top:8px;font-size:12px;color:#166534;">
                    <strong>📋 Phiếu báo giá / Phản hồi từ <%= ord.getShopName() %>:</strong> <%= ord.getShopNote() %>
                </div>
                <% } %>

                <div class="order-card-foot">
                    <div>Tổng thanh toán chốt: <strong style="font-size:16px;color:#EA580C;"><%= ord.getFormattedTotal() %></strong></div>
                    <div style="display:flex;gap:10px;">
                        <a href="order-detail?id=<%= ord.getId() %>" class="btn btn-blue">Xem chi tiết & Tiến độ</a>
                        <a href="product-detail?id=<%= ord.getProductId() %>" class="btn btn-outline-gray">Xem sản phẩm</a>

                        <% if ("COMPLETED".equals(ord.getOrderStatus())) { %>
                        <% if (reviewedIds.contains(ord.getProductId())) { %>
                        <a href="my-reviews" class="btn btn-outline-gray" style="color:#16A34A;border-color:#BBF7D0;background:#F0FDF4;">✓ Đã đánh giá (Xem)</a>
                        <% } else { %>
                        <a href="review?orderCode=<%= ord.getOrderCode() %>&productId=<%= ord.getProductId() %>" class="btn-orange-review">★ Đánh giá nhận 50k</a>
                        <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
            <% } %>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>