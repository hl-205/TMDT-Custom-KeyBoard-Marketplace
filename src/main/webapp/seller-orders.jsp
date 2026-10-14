<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    if (request.getAttribute("orders") == null) {
        response.sendRedirect("seller-orders");
        return;
    }
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
    List<CustomOrder> orders = (List<CustomOrder>) request.getAttribute("orders");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    Boolean onlyCustom = (Boolean) request.getAttribute("onlyCustom");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn hàng - <%= shopName %></title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <jsp:include page="includes/seller-sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Quản lý đơn hàng</h1>
                <p>Tổng cộng ${totalOrdersCount} đơn trong Database · Click vào đơn Chờ xác nhận để tiếp nhận yêu cầu gia công</p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
                    <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
                </div>
            </div>
        </div>

        <div class="seller-kpi-grid4">
            <div class="s-kpi-card">
                <div class="s-kpi-head">🕒 Chờ xác nhận</div>
                <strong>${pendingCount}</strong>
                <span class="s-kpi-sub down">Cần phản hồi trong 24h</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">🛠️ Đang gia công</div>
                <strong>${processingCount}</strong>
                <span class="s-kpi-sub up">Đúng tiến độ</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">🚚 Đang giao</div>
                <strong>${shippingCount}</strong>
                <span class="s-kpi-sub" style="color:#64748B;">Đơn vị vận chuyển</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">✓ Đã hoàn thành</div>
                <strong>${completedCount}</strong>
                <span class="s-kpi-sub up">Đơn hàng thành công</span>
            </div>
        </div>

        <section class="white-panel-card">
            <div style="display:flex;gap:18px;border-bottom:1px solid #E2E8F0;padding-bottom:12px;margin-bottom:14px;">
                <a href="seller-orders?status=ALL" style="font-weight:700;color:<%= "ALL".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Tất cả (${totalOrdersCount})</a>
                <a href="seller-orders?status=PENDING" style="font-weight:700;color:<%= "PENDING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Chờ xác nhận (${pendingCount})</a>
                <a href="seller-orders?status=PROCESSING" style="font-weight:700;color:<%= "PROCESSING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Đang gia công (${processingCount})</a>
                <a href="seller-orders?status=SHIPPING" style="font-weight:700;color:<%= "SHIPPING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Đang giao (${shippingCount})</a>
                <a href="seller-orders?status=COMPLETED" style="font-weight:700;color:<%= "COMPLETED".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Hoàn thành (${completedCount})</a>
            </div>

            <div style="display:flex;gap:8px;margin-bottom:16px;">
                <a href="seller-orders" class="btn-seller-outline" style="<%= !onlyCustom ? "background:#1B64F2;color:#FFF;border-color:#1B64F2;" : "" %>">Tất cả</a>
                <a href="seller-orders?custom=1" class="btn-seller-outline" style="<%= onlyCustom ? "background:#1B64F2;color:#FFF;border-color:#1B64F2;" : "" %>">Chỉ đơn custom</a>
            </div>

            <table class="orders-table">
                <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Khách hàng</th>
                    <th>Sản phẩm / Cấu hình</th>
                    <th>Giá trị</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (CustomOrder o : orders) { %>
                <tr>
                    <td><strong>#<%= o.getOrderCode() %></strong></td>
                    <td><strong><%= o.getReceiverName() %></strong><br><span style="font-size:11px;color:#94A3B8;"><%= o.getReceiverPhone() %></span></td>
                    <td>
                        <strong><%= o.getProductSummary() %></strong>
                        <% if (o.isCustomOrder()) { %>
                        <span class="s-pill-orange" style="margin-left:6px;">Custom</span>
                        <% } %>
                        <br><span style="font-size:11px;color:#64748B;"><%= o.getVariantSummary() %></span>
                    </td>
                    <td><strong><%= o.getFormattedTotal() %></strong><br><span style="font-size:11px;color:#94A3B8;"><%= o.getPaymentMethod() %></span></td>
                    <td>
                        <% if ("PENDING".equals(o.getOrderStatus())) { %>
                        <span class="st-badge pending">Chờ xác nhận</span>
                        <% } else if ("PROCESSING".equals(o.getOrderStatus())) { %>
                        <span class="st-badge processing">Đang gia công · <%= o.getProgressPercent() %>%</span>
                        <% } else if ("SHIPPING".equals(o.getOrderStatus())) { %>
                        <span class="st-badge shipping">Đang giao</span>
                        <% } else if ("COMPLETED".equals(o.getOrderStatus())) { %>
                        <span class="st-badge completed">Đã giao</span>
                        <% } else { %>
                        <span class="st-badge cancelled">Đã huỷ</span>
                        <% } %>
                    </td>
                    <td>
                        <% if ("PENDING".equals(o.getOrderStatus()) && o.isCustomOrder()) { %>
                        <a href="seller-confirm-custom?id=<%= o.getId() %>" class="btn-seller-primary" style="height:32px;font-size:12px;">Xác nhận đơn</a>
                        <% } else if ("PROCESSING".equals(o.getOrderStatus())) { %>
                        <a href="seller-progress?id=<%= o.getId() %>" class="btn-seller-outline" style="height:32px;font-size:12px;">Cập nhật tiến độ</a>
                        <% } else { %>
                        <a href="seller-confirm-custom?id=<%= o.getId() %>" class="btn-seller-outline" style="height:32px;font-size:12px;">Chi tiết</a>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </section>
    </main>
</div>

</body>
</html>