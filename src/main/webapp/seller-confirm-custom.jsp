<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("seller-confirm-custom");
        return;
    }
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đơn custom #<%= order.getOrderCode() %> - <%= shopName %></title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <jsp:include page="includes/seller-sidebar.jsp">
        <jsp:param name="activeMenu" value="confirm" />
    </jsp:include>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Xác nhận đơn custom</h1>
                <p>Đơn #<%= order.getOrderCode() %> · Khách hàng: <%= order.getReceiverName() %></p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
                    <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
                </div>
            </div>
        </div>

        <div class="sla-warning-banner">
            ⏰ Theo quy định sàn, xưởng phải phản hồi đơn gia công trong <strong>24 giờ</strong> kể từ khi khách đặt đơn.
        </div>

        <form action="seller-confirm-custom" method="POST" id="confirmOrderForm">
            <input type="hidden" name="orderId" value="<%= order.getId() %>">
            <input type="hidden" name="decision" id="decisionInput" value="accept">

            <div class="confirm-layout-2col">
                <div>
                    <div class="white-panel-card">
                        <div style="display:flex;justify-content:space-between;align-items:center;">
                            <div>
                                <h2 style="font-size:17px;font-weight:800;">Build Sheet — <%= order.getBuildCode() %></h2>
                                <span style="font-size:12px;color:#64748B;">Cấu hình đọc từ đơn hàng #<%= order.getOrderCode() %> trong Database</span>
                            </div>
                            <span class="st-badge completed">✓ Tương thích</span>
                        </div>

                        <div class="build-sheet-split">
                            <div style="background:#F1F5F9;border-radius:12px;display:flex;align-items:center;justify-content:center;padding:18px;">
                                <div style="width:100%;background:#FFFFFF;border:4px solid #334155;border-radius:10px;padding:10px;">
                                    <div style="display:flex;gap:4px;margin-bottom:4px;"><span style="height:16px;flex:1;background:#EF4444;border-radius:3px;"></span><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span><span style="height:16px;flex:1;background:#EF4444;border-radius:3px;"></span></div>
                                    <div style="display:flex;gap:4px;margin-bottom:4px;"><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span><span style="height:16px;flex:1;background:#EF4444;border-radius:3px;"></span><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span></div>
                                    <div style="display:flex;gap:4px;"><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span><span style="height:16px;flex:3;background:#CBD5E1;border-radius:3px;"></span><span style="height:16px;flex:1;background:#E2E8F0;border-radius:3px;"></span></div>
                                </div>
                            </div>

                            <table class="build-sheet-table">
                                <tr><td>Sản phẩm chính</td><td><%= order.getProductName() != null ? order.getProductName() : order.getBuildCode() %></td></tr>
                                <tr><td>Cấu hình chi tiết</td><td><%= order.getVariantSummary() %></td></tr>
                                <tr><td>Phí gia công</td><td><%= order.getFormattedCustomFee() %></td></tr>
                                <tr><td>Cam kết hiện tại</td><td><%= order.getCommittedDays() %> ngày làm việc</td></tr>
                                <tr><td>Trạng thái đơn</td><td><%= order.getOrderStatus() %></td></tr>
                            </table>
                        </div>

                        <strong style="font-size:13px;">Yêu cầu riêng của khách (từ bảng <code>orders.customer_note</code>)</strong>
                        <div class="customer-quote-box">
                            💬 “<%= (order.getCustomerNote() != null && !order.getCustomerNote().isEmpty()) ? order.getCustomerNote() : "Nhờ xưởng kiểm tra kỹ toàn bộ socket trước khi lắp ráp." %>”
                        </div>

                        <strong style="font-size:13px;display:block;margin-bottom:10px;">Kiểm tra trước khi nhận</strong>
                        <div style="display:flex;flex-direction:column;gap:10px;">
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Đủ tồn kho toàn bộ linh kiện</span>
                            </label>
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Xưởng còn slot trong <%= order.getCommittedDays() %> ngày cam kết</span>
                            </label>
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Có đủ vật tư mod: PE foam, tape, band-aid, Krytox 205g0</span>
                            </label>
                        </div>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Phản hồi cho khách</h3>

                        <div style="margin-bottom:14px;">
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Thời gian gia công cam kết (ngày) <span style="color:#EF4444;">*</span></label>
                            <input type="number" name="committedDays" value="<%= order.getCommittedDays() %>" min="1" max="30" required
                                   style="width:120px;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;font-weight:700;">
                        </div>

                        <div style="margin-bottom:14px;">
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Ghi chú gửi khách</label>
                            <textarea name="shopNote" rows="3" placeholder="Xưởng đã kiểm tra đủ linh kiện, sẽ cập nhật từng bước gia công..."
                                      style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:10px 12px;font-size:13px;"></textarea>
                        </div>

                        <div>
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Phụ phí phát sinh (VNĐ - nếu có)</label>
                            <input type="text" name="extraFee" placeholder="0"
                                   oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                   style="width:180px;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                        </div>
                    </div>
                </div>

                <div>
                    <div class="white-panel-card">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Thông tin người nhận</h3>
                        <div style="margin-bottom:10px;">
                            <strong style="display:block;font-size:15px;"><%= order.getReceiverName() %></strong>
                            <span style="font-size:13px;color:#64748B;">SĐT: <%= order.getReceiverPhone() %></span>
                        </div>
                        <div style="font-size:13px;color:#475569;">
                            Địa chỉ: <strong><%= order.getShippingAddress() %></strong>
                        </div>
                    </div>

                    <div class="white-panel-card">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Giá trị đơn (#<%= order.getOrderCode() %>)</h3>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;">
                            <span style="color:#64748B;">Linh kiện</span><strong><%= order.getFormattedSubtotal() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0 12px;border-bottom:1px solid #F1F5F9;">
                            <span style="color:#64748B;">Phí gia công</span><strong><%= order.getFormattedCustomFee() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:10px 0 6px;">
                            <span style="color:#64748B;">Tổng thanh toán</span><strong><%= order.getFormattedTotal() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:4px 0;">
                            <span style="color:#64748B;">Phí sàn (5%)</span><span style="color:#EF4444;">−<%= order.getFormattedPlatformFee() %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:4px 0 12px;border-bottom:1px solid #F1F5F9;">
                            <span style="color:#64748B;">Phí thanh toán (1.1%)</span><span style="color:#EF4444;">−<%= order.getFormattedPaymentFee() %></span>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;padding-top:12px;">
                            <strong>Shop thực nhận</strong>
                            <strong style="font-size:20px;color:#16A34A;"><%= order.getFormattedNetShopReceive() %></strong>
                        </div>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;display:flex;flex-direction:column;gap:10px;">
                        <button type="submit" class="btn-seller-primary" style="height:44px;font-size:14px;"
                                onclick="document.getElementById('decisionInput').value='accept'">
                            ✓ Nhận đơn & bắt đầu gia công
                        </button>
                        <button type="submit" class="btn-seller-outline"
                                style="height:40px;background:#FEF2F2;color:#DC2626;border-color:#FECACA;font-weight:700;"
                                onclick="document.getElementById('decisionInput').value='reject'; return confirm('Từ chối đơn gia công này?');">
                            ✕ Từ chối đơn
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </main>
</div>

</body>
</html>