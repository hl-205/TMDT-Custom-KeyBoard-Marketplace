<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="dao.CustomOrderDAO.ProgressStep" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("my-orders");
        return;
    }
    List<ProgressStep> steps = (List<ProgressStep>) request.getAttribute("steps");
    int completedCount = 0;
    if (steps != null) {
        for (ProgressStep s : steps) {
            if ("COMPLETED".equals(s.getStatus())) completedCount++;
        }
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
                <div class="acc-avatar-circle"><%= currentUser.getAvatarText() %></div>
                <div>
                    <strong style="display:block;font-size:14px;"><%= currentUser.getFullName() %></strong>
                    <span style="font-size:12px;color:#64748B;"><%= currentUser.getRankName() %> · <%= currentUser.getPoints() %> điểm</span>
                </div>
            </div>
            <div class="acc-nav-group-title">Mua hàng</div>
            <a href="my-orders" class="acc-nav-link active"><span>📦 Đơn hàng của tôi</span></a>
            <a href="my-reviews" class="acc-nav-link"><span>⭐ Đánh giá của tôi</span></a>
            <% if ("SELLER".equalsIgnoreCase(currentUser.getRole())) { %>
            <div class="acc-nav-group-title">Kênh người bán</div>
            <a href="seller-progress?id=<%= order.getId() %>" class="acc-nav-link" style="color:#1B64F2;font-weight:700;"><span>🛠️ Cập nhật tại Xưởng</span></a>
            <% } %>
        </aside>

        <section>
            <div class="order-card-box">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                            <h2 style="font-size:20px;font-weight:800;">Đơn hàng #<%= order.getOrderCode() %></h2>
                            <span style="background:#FFF7ED;color:#EA580C;font-size:11px;font-weight:700;padding:3px 10px;border-radius:20px;"><%= order.getOrderStatus() %></span>
                            <% if (order.isCustomOrder()) { %>
                            <span class="shop-badge-pill workshop">Đơn custom</span>
                            <% } %>
                        </div>
                        <span style="font-size:12px;color:#64748B;">Gian hàng: <strong><%= order.getShopName() %></strong> · Cam kết xử lý: <%= order.getCommittedDays() %> ngày</span>
                    </div>
                    <a href="my-orders" class="btn btn-outline-gray">‹ Quay lại danh sách đơn</a>
                </div>
            </div>

            <!-- Hộp Phiếu Báo Giá từ Xưởng -->
            <div class="order-card-box" style="border-left:4px solid #1B64F2;">
                <h3 style="font-size:15px;font-weight:800;color:#1B64F2;margin-bottom:6px;">📋 Phiếu Báo Giá & Xác Nhận Từ Xưởng (<%= order.getShopName() %>)</h3>
                <% if (order.getShopNote() != null && !order.getShopNote().isBlank()) { %>
                <p style="font-size:13px;color:#1E293B;"><%= order.getShopNote() %></p>
                <% } else { %>
                <p style="font-size:13px;color:#64748B;">Đơn hàng đang chờ xưởng kiểm tra linh kiện và gửi phiếu báo giá xác nhận (tối đa trong 24 giờ).</p>
                <% } %>
            </div>

            <% if (steps != null && !steps.isEmpty()) { %>
            <div class="order-card-box">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                    <div>
                        <h3 style="font-size:16px;font-weight:800;">Tiến độ gia công trực tiếp tại xưởng</h3>
                        <span style="font-size:12px;color:#64748B;">Cập nhật bởi <%= order.getShopName() %> · <%= completedCount %>/<%= steps.size() %> công đoạn hoàn thành</span>
                    </div>
                    <span style="background:#DCFCE7;color:#15803D;font-size:11px;font-weight:700;padding:4px 10px;border-radius:20px;">Đồng bộ từ Database</span>
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
            <% } %>

            <!-- Thông tin Sản phẩm & Thanh toán lấy động 100% từ đơn hàng -->
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
                <div class="order-card-box" style="margin-bottom:0;">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Thông tin đơn hàng & Giao nhận</h3>
                    <div class="shop-stat-line"><span>Sản phẩm chính</span><strong><%= order.getProductName() != null ? order.getProductName() : order.getBuildCode() %></strong></div>
                    <div class="shop-stat-line"><span>Chi tiết phân loại</span><strong><%= order.getVariantSummary() %></strong></div>
                    <div class="shop-stat-line"><span>Người nhận</span><strong><%= order.getReceiverName() %> (<%= order.getReceiverPhone() %>)</strong></div>
                    <div class="shop-stat-line"><span>Địa chỉ nhận</span><strong><%= order.getShippingAddress() %></strong></div>
                    <% if (order.getCustomerNote() != null && !order.getCustomerNote().isBlank()) { %>
                    <div class="shop-stat-line"><span>Ghi chú của khách</span><strong><%= order.getCustomerNote() %></strong></div>
                    <% } %>
                </div>

                <div class="order-card-box" style="margin-bottom:0;">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Chi tiết Thanh toán & Báo giá</h3>
                    <div class="shop-stat-line"><span>Tiền linh kiện / sản phẩm</span><strong><%= order.getFormattedSubtotal() %></strong></div>
                    <div class="shop-stat-line"><span>Phí gia công & phụ phí báo giá</span><strong><%= order.getFormattedCustomFee() %></strong></div>
                    <div class="shop-stat-line"><span>Phí vận chuyển</span><strong><%= order.getFormattedShippingFee() %></strong></div>
                    <div class="shop-stat-line"><span>Giảm giá</span><strong class="green">−<%= order.getFormattedDiscount() %></strong></div>
                    <div class="shop-stat-line" style="border-top:1px solid #E2E8F0;margin-top:8px;padding-top:10px;">
                        <strong>Tổng thanh toán chốt</strong>
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