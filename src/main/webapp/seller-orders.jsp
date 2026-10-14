<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="java.util.List" %>
<%
    if (request.getAttribute("orders") == null) {
        response.sendRedirect("seller-orders");
        return;
    }
    List<CustomOrder> orders = (List<CustomOrder>) request.getAttribute("orders");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    Boolean onlyCustom = (Boolean) request.getAttribute("onlyCustom");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý đơn hàng - KeebHub Seller</title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <aside class="seller-sidebar">
        <a href="index.jsp" class="seller-brand-head">
            <div class="seller-brand-icon">K</div>
            <div>
                <strong>KeebHub Seller</strong>
                <span>Kênh người bán</span>
            </div>
        </a>
        <div class="seller-shop-badge-box">
            <div class="sh-square">SH</div>
            <div>
                <strong>SwitchHouse</strong>
                <span>Đã xác minh · Xưởng gia công</span>
            </div>
        </div>
        <div class="s-nav-section">Đơn hàng</div>
        <a href="seller-orders" class="s-nav-item active"><span>📦 Quản lý đơn hàng</span><span class="s-pill-orange"><%= orders.size() %></span></a>
        <a href="seller-confirm-custom" class="s-nav-item"><span>⚙️ Đơn custom chờ xác nhận</span><span class="s-pill-orange">2</span></a>
        <a href="seller-progress" class="s-nav-item"><span>🛠️ Tiến độ gia công</span><span class="s-pill-orange">5</span></a>

        <div class="s-nav-section">Sản phẩm</div>
        <a href="shop?id=2" class="s-nav-item"><span>📋 Danh sách sản phẩm</span></a>
        <a href="seller-services" class="s-nav-item"><span>🔧 Dịch vụ gia công</span></a>

        <div class="s-nav-section">Hệ thống</div>
        <a href="index.jsp" class="s-nav-item"><span>🏠 Về sàn KeebHub</span></a>
    </aside>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Quản lý đơn hàng</h1>
                <p>142 đơn trong 30 ngày · Click vào đơn Chờ xác nhận để tiếp nhận yêu cầu gia công</p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;">SH</div>
                    <span>Trần Hùng · Chủ shop ▾</span>
                </div>
            </div>
        </div>

        <div class="seller-kpi-grid4">
            <div class="s-kpi-card">
                <div class="s-kpi-head">🕒 Chờ xác nhận</div>
                <strong>3</strong>
                <span class="s-kpi-sub down">▼ Quá hạn 18 giờ</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">🛠️ Đang gia công</div>
                <strong>5</strong>
                <span class="s-kpi-sub up">Đúng tiến độ</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">🚚 Đang giao</div>
                <strong>4</strong>
                <span class="s-kpi-sub" style="color:#64748B;">Giao Hàng Nhanh</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">✓ Hoàn thành tháng này</div>
                <strong>118</strong>
                <span class="s-kpi-sub up">▲ 8.2% so với tháng trước</span>
            </div>
        </div>

        <section class="white-panel-card">
            <div style="display:flex;gap:18px;border-bottom:1px solid #E2E8F0;padding-bottom:12px;margin-bottom:14px;">
                <a href="seller-orders?status=ALL" style="font-weight:700;color:<%= "ALL".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Tất cả (<%= orders.size() %>)</a>
                <a href="seller-orders?status=PENDING" style="font-weight:700;color:<%= "PENDING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Chờ xác nhận</a>
                <a href="seller-orders?status=PROCESSING" style="font-weight:700;color:<%= "PROCESSING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Đang gia công</a>
                <a href="seller-orders?status=SHIPPING" style="font-weight:700;color:<%= "SHIPPING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Đang giao</a>
                <a href="seller-orders?status=COMPLETED" style="font-weight:700;color:<%= "COMPLETED".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Hoàn thành</a>
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
                    <th>Sản phẩm</th>
                    <th>Giá trị</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (CustomOrder o : orders) { %>
                <tr>
                    <td><strong>#<%= o.getOrderCode() %></strong><br><span style="font-size:11px;color:#94A3B8;">26/09 14:32</span></td>
                    <td><strong><%= o.getReceiverName() %></strong><br><span style="font-size:11px;color:#94A3B8;"><%= o.getReceiverPhone() %></span></td>
                    <td>
                        <strong><%= o.getProductSummary() %></strong>
                        <% if (o.isCustomOrder()) { %>
                        <span class="s-pill-orange" style="margin-left:6px;">Custom</span>
                        <% } %>
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