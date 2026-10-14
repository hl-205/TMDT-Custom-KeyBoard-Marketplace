<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="dao.CustomOrderDAO.ProgressStep" %>
<%@ page import="java.util.List" %>
<%
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("order-detail?code=KH-284193");
        return;
    }
    List<ProgressStep> steps = (List<ProgressStep>) request.getAttribute("steps");
    int completedCount = 0;
    for (ProgressStep s : steps) {
        if ("COMPLETED".equals(s.getStatus())) completedCount++;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn hàng #<%= order.getOrderCode() %> - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> ›
        <a href="my-orders">Đơn hàng của tôi</a> ›
        <strong>#<%= order.getOrderCode() %></strong>
    </div>

    <div class="account-layout-2col">
        <aside class="account-sidebar-card">
            <div class="acc-user-box">
                <div class="acc-avatar-circle">${sessionScope.user != null ? sessionScope.user.avatarText : 'KH'}</div>
                <div>
                    <strong style="display:block;font-size:14px;">${sessionScope.user != null ? sessionScope.user.fullName : 'Khách hàng'}</strong>
                    <span style="font-size:12px;color:#64748B;">${sessionScope.user != null ? sessionScope.user.rankName : 'Thành viên'} · ${sessionScope.user != null ? sessionScope.user.points : 0} điểm</span>
                </div>
            </div>
            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link active"><span>📦 Đơn hàng của tôi</span><span class="badge">3</span></a>
            <a href="my-reviews" class="acc-nav-link"><span>⭐ Đánh giá của tôi</span></a>
            <div class="acc-nav-group-title">Kênh người bán</div>
            <a href="seller-progress?id=<%= order.getId() %>" class="acc-nav-link" style="color:#1B64F2;font-weight:700;"><span>🛠️ Sang Xưởng cập nhật tiến độ</span></a>
        </aside>

        <section>
            <!-- Header Đơn hàng chuẩn Frame 15 -->
            <div class="order-card-box">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                            <h2 style="font-size:20px;font-weight:800;">Đơn hàng #<%= order.getOrderCode() %></h2>
                            <span style="background:#FFF7ED;color:#EA580C;font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;">⚙️ Đang gia công</span>
                            <span class="shop-badge-pill workshop">Đơn custom</span>
                        </div>
                        <span style="font-size:12px;color:#64748B;">Đặt ngày 20/09/2026 · SwitchHouse · Dự kiến nhận 28–30/09/2026</span>
                    </div>
                    <div style="display:flex;gap:8px;">
                        <a href="seller-progress?id=<%= order.getId() %>" class="btn btn-outline-gray">🛠️ Mở trang Xưởng (Frame 22)</a>
                    </div>
                </div>
            </div>

            <!-- Khối Tiến độ gia công đồng bộ trực tiếp từ Seller -->
            <div class="order-card-box">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                    <div>
                        <h3 style="font-size:16px;font-weight:800;">Tiến độ gia công</h3>
                        <span style="font-size:12px;color:#64748B;">Cập nhật trực tiếp bởi SwitchHouse · <%= completedCount %>/5 công đoạn hoàn thành</span>
                    </div>
                    <span style="background:#DCFCE7;color:#15803D;font-size:11px;font-weight:700;padding:4px 10px;border-radius:20px;">Đúng tiến độ</span>
                </div>

                <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
                    <div style="flex:1;height:8px;background:#E2E8F0;border-radius:6px;overflow:hidden;">
                        <div style="width:<%= order.getProgressPercent() %>%;height:100%;background:#16A34A;"></div>
                    </div>
                    <strong><%= order.getProgressPercent() %>%</strong>
                </div>

                <% for (ProgressStep st : steps) {
                    boolean isDone = "COMPLETED".equals(st.getStatus());
                %>
                <div style="display:flex;gap:12px;padding:12px 0;border-top:1px solid #F1F5F9;">
                    <span style="color:<%= isDone ? "#16A34A" : "#CBD5E1" %>;font-weight:800;">●</span>
                    <div style="flex:1;">
                        <div style="display:flex;justify-content:space-between;">
                            <strong style="color:<%= isDone ? "#0F172A" : "#94A3B8" %>;"><%= st.getStepTitle() %></strong>
                            <span style="font-size:12px;color:#94A3B8;"><%= st.getUpdatedTime() %></span>
                        </div>
                        <p style="font-size:13px;color:<%= isDone ? "#475569" : "#94A3B8" %>;margin-top:4px;"><%= st.getStepDesc() %></p>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Build Sheet & Thanh toán dưới cùng chuẩn Frame 15 -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="order-card-box" style="margin-bottom:0;">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Build Sheet</h3>
                    <div class="shop-stat-line"><span>Kit</span><strong>Tofu60 2.0 Aluminium · 3.040.000₫</strong></div>
                    <div class="shop-stat-line"><span>Switch</span><strong>Gateron Oil King ×70 · 890.000₫</strong></div>
                    <div class="shop-stat-line"><span>Keycap</span><strong>GMK Olivia++ Cherry · 4.150.000₫</strong></div>
                    <div class="shop-stat-line"><span>Stabilizer</span><strong>Durock V2 screw-in · 420.000₫</strong></div>
                    <div class="shop-stat-line"><span>Gia công</span><strong>Gói Full lube + tune · 750.000₫</strong></div>
                </div>

                <div class="order-card-box" style="margin-bottom:0;">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Thanh toán</h3>
                    <div class="shop-stat-line"><span>Tạm tính</span><strong><%= order.getFormattedSubtotal() %></strong></div>
                    <div class="shop-stat-line"><span>Phí gia công</span><strong><%= order.getFormattedCustomFee() %></strong></div>
                    <div class="shop-stat-line"><span>Vận chuyển</span><strong><%= order.getFormattedShippingFee() %></strong></div>
                    <div class="shop-stat-line"><span>Giảm giá</span><strong class="green">−<%= order.getFormattedDiscount() %></strong></div>
                    <div class="shop-stat-line" style="border-top:1px solid #E2E8F0;margin-top:8px;padding-top:10px;">
                        <strong>Tổng thanh toán</strong>
                        <strong style="font-size:18px;color:#EA580C;"><%= order.getFormattedTotal() %></strong>
                    </div>
                </div>
            </div>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>