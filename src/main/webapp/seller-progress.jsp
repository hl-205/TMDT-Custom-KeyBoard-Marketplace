<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="dao.CustomOrderDAO.ProgressStep" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    List<ProgressStep> steps = (List<ProgressStep>) request.getAttribute("steps");
    List<CustomOrder> workshopQueue = (List<CustomOrder>) request.getAttribute("workshopQueue");

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
    <title>Tiến độ gia công - <%= shopName %></title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <jsp:include page="includes/seller-sidebar.jsp">
        <jsp:param name="activeMenu" value="progress" />
    </jsp:include>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Tiến độ gia công xưởng</h1>
                <p>Xưởng: <strong><%= shopName %></strong></p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
                    <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
                </div>
            </div>
        </div>

        <% if (request.getParameter("msg") != null) { %>
        <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:10px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
            ✓ Đã lưu cập nhật tiến độ gia công thành công!
        </div>
        <% } %>

        <% if (order == null) { %>
        <div class="white-panel-card" style="text-align:center;padding:56px 24px;">
            <div style="font-size:42px;margin-bottom:12px;">🛠️</div>
            <h3 style="font-size:18px;font-weight:800;margin-bottom:6px;">Hiện tại không có đơn custom nào đang gia công trong xưởng</h3>
            <p style="color:#64748B;font-size:13px;margin-bottom:20px;">Khi bạn nhận đơn ở mục "Đơn custom chờ xác nhận", đơn sẽ tự động xuất hiện tại đây.</p>
            <a href="seller-orders" class="btn-seller-primary">Quay lại Quản lý đơn hàng</a>
        </div>
        <% } else { %>
        <div class="confirm-layout-2col">
            <div class="white-panel-card">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <h2 style="font-size:18px;font-weight:800;">Đơn #<%= order.getOrderCode() %> · <%= order.getBuildCode() %></h2>
                        <span style="font-size:12px;color:#64748B;">Khách hàng: <%= order.getReceiverName() %> · Cam kết bàn giao <%= order.getCommittedDays() %> ngày</span>
                    </div>
                    <span class="st-badge processing">Đang gia công · <%= order.getProgressPercent() %>%</span>
                </div>

                <div style="display:flex;align-items:center;gap:14px;">
                    <div class="progress-bar-Full" style="flex:1;">
                        <div class="progress-bar-Fill" style="width:<%= order.getProgressPercent() %>%;"></div>
                    </div>
                    <strong style="font-size:13px;"><%= completedCount %>/<%= steps != null ? steps.size() : 5 %> công đoạn</strong>
                </div>

                <% if (steps != null) {
                    for (ProgressStep st : steps) {
                        boolean isDone = "COMPLETED".equals(st.getStatus());
                        boolean isCurrent = "IN_PROGRESS".equals(st.getStatus());
                %>
                <div class="timeline-step-row">
                    <div class="step-bullet <%= isDone ? "done" : (isCurrent ? "active" : "pending") %>">
                        <%= isDone ? "✓" : st.getStepNumber() %>
                    </div>

                    <div style="flex:1;">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;">
                            <strong style="font-size:14px;"><%= st.getStepTitle() %></strong>
                            <% if (isCurrent) { %>
                            <span style="background:#EFF6FF;color:#1B64F2;font-size:11px;font-weight:700;padding:2px 8px;border-radius:12px;">Đang làm</span>
                            <% } else { %>
                            <span style="font-size:12px;color:#94A3B8;"><%= st.getUpdatedTime() %></span>
                            <% } %>
                        </div>

                        <% if (isDone) { %>
                        <p style="font-size:13px;color:#475569;margin-bottom:10px;"><%= st.getStepDesc() %></p>
                        <% } else if (isCurrent) { %>
                        <form action="seller-progress" method="POST" style="margin-top:8px;">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <input type="hidden" name="stepNumber" value="<%= st.getStepNumber() %>">

                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Ghi chú công đoạn</label>
                            <textarea name="stepDesc" rows="3" required
                                      style="width:100%;border:1.5px solid #1B64F2;border-radius:8px;padding:10px 12px;font-size:13px;margin-bottom:12px;"><%= st.getStepDesc() %></textarea>

                            <div style="display:flex;gap:10px;">
                                <button type="submit" name="submitAction" value="complete" class="btn-seller-primary">Lưu & hoàn thành bước này</button>
                                <button type="submit" name="submitAction" value="draft" class="btn-seller-outline">Chỉ lưu nháp</button>
                            </div>
                        </form>
                        <% } else { %>
                        <p style="font-size:12px;color:#94A3B8;"><%= st.getStepDesc() %></p>
                        <% } %>
                    </div>
                </div>
                <% } } %>
            </div>

            <div>
                <div class="white-panel-card">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Thông tin Build (#<%= order.getOrderCode() %>)</h3>
                    <table class="build-sheet-table" style="border:none;">
                        <tr><td>Sản phẩm</td><td><%= order.getProductName() != null ? order.getProductName() : order.getBuildCode() %></td></tr>
                        <tr><td>Cấu hình</td><td><%= order.getVariantSummary() %></td></tr>
                        <tr><td>Khách hàng</td><td><%= order.getReceiverName() %></td></tr>
                        <tr><td>Phí gia công</td><td><%= order.getFormattedCustomFee() %></td></tr>
                        <tr><td>Tổng đơn</td><td><%= order.getFormattedTotal() %></td></tr>
                    </table>
                </div>
            </div>
        </div>

        <section class="white-panel-card" style="margin-bottom:0;">
            <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Danh sách đơn đang gia công trong xưởng (<%= workshopQueue.size() %>)</h3>
            <table class="orders-table">
                <thead>
                <tr><th>Mã đơn</th><th>Khách hàng</th><th>Cấu hình</th><th>Tiến độ</th><th></th></tr>
                </thead>
                <tbody>
                <% for (CustomOrder q : workshopQueue) { %>
                <tr>
                    <td><strong>#<%= q.getOrderCode() %></strong></td>
                    <td><%= q.getReceiverName() %></td>
                    <td><%= q.getVariantSummary() %></td>
                    <td style="width:200px;">
                        <div style="display:flex;align-items:center;gap:8px;">
                            <div style="flex:1;height:6px;background:#E2E8F0;border-radius:4px;overflow:hidden;">
                                <div style="width:<%= q.getProgressPercent() %>%;height:100%;background:#1B64F2;"></div>
                            </div>
                            <strong><%= q.getProgressPercent() %>%</strong>
                        </div>
                    </td>
                    <td style="text-align:right;">
                        <a href="seller-progress?id=<%= q.getId() %>" class="btn-seller-outline" style="height:30px;font-size:12px;">Chọn đơn này</a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </section>
        <% } %>
    </main>
</div>

</body>
</html>