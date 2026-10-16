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
    if (request.getAttribute("sellerShop") == null && request.getAttribute("order") == null) {
        response.sendRedirect("seller-confirm-custom");
        return;
    }
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
    CustomOrder order = (CustomOrder) request.getAttribute("order");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đơn custom - <%= shopName %></title>
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
                <h1>Xác nhận đơn custom chờ xử lý</h1>
                <p>Xưởng: <strong><%= shopName %></strong></p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
                    <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
                </div>
            </div>
        </div>

        <% if (order == null || !"PENDING".equals(order.getOrderStatus())) { %>
        <div class="white-panel-card" style="text-align:center;padding:56px 24px;">
            <div style="font-size:42px;margin-bottom:12px;">🎉</div>
            <h3 style="font-size:18px;font-weight:800;margin-bottom:6px;">Không có đơn custom nào đang chờ xác nhận</h3>
            <p style="color:#64748B;font-size:13px;margin-bottom:20px;">Tất cả yêu cầu gia công từ khách hàng đã được xưởng tiếp nhận hoặc xử lý xong.</p>
            <a href="seller-orders" class="btn-seller-primary">Quay lại Quản lý đơn hàng</a>
        </div>
        <% } else { %>
        <div class="sla-warning-banner">
            ⏰ Đơn hàng <strong>#<%= order.getOrderCode() %></strong> đang chờ xưởng phản hồi báo giá (Giá tạm tính: <strong><%= order.getFormattedTotal() %></strong>).
        </div>

        <form action="seller-confirm-custom" method="POST" id="confirmOrderForm">
            <input type="hidden" name="orderId" value="<%= order.getId() %>">
            <input type="hidden" name="decision" id="decisionInput" value="accept">

            <div class="confirm-layout-2col">
                <div>
                    <div class="white-panel-card">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
                            <div>
                                <h2 style="font-size:17px;font-weight:800;">Build Sheet — Đơn #<%= order.getOrderCode() %></h2>
                                <span style="font-size:12px;color:#64748B;"><%= order.getBuildCode() %></span>
                            </div>
                            <span class="st-badge completed">✓ Tương thích hệ thống</span>
                        </div>

                        <table class="build-sheet-table" style="margin-bottom:16px;">
                            <tr><td>Sản phẩm chính</td><td><%= order.getProductName() != null ? order.getProductName() : order.getBuildCode() %></td></tr>
                            <tr><td>Cấu hình chi tiết</td><td><%= order.getVariantSummary() %></td></tr>
                            <tr><td>Giá linh kiện</td><td><%= order.getFormattedSubtotal() %></td></tr>
                            <tr><td>Phí gia công gốc</td><td><%= order.getFormattedCustomFee() %></td></tr>
                        </table>

                        <strong style="font-size:13px;display:block;margin-bottom:6px;">Yêu cầu riêng của khách hàng:</strong>
                        <div class="customer-quote-box" style="margin-bottom:16px;">
                            💬 “<%= (order.getCustomerNote() != null && !order.getCustomerNote().isEmpty()) ? order.getCustomerNote() : "Không có ghi chú thêm." %>”
                        </div>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;border:2px solid #1B64F2;">
                        <h3 style="font-size:16px;font-weight:800;color:#1B64F2;margin-bottom:14px;">📋 Lập Phiếu Báo Giá Gia Công</h3>

                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:14px;">
                            <div>
                                <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Thời gian cam kết (ngày) *</label>
                                <input type="number" name="committedDays" value="<%= order.getCommittedDays() %>" min="1" max="30" required
                                       style="width:100%;height:40px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;font-weight:700;">
                            </div>
                            <div>
                                <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Phụ phí báo giá thêm (+VNĐ)</label>
                                <input type="text" name="extraFee" id="extraFeeInput" value="0"
                                       oninput="this.value = this.value.replace(/[^0-9]/g, ''); updateLiveQuotation();"
                                       style="width:100%;height:40px;border:1.5px solid #EA580C;border-radius:8px;padding:0 12px;font-weight:700;color:#EA580C;">
                            </div>
                        </div>

                        <div>
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Nội dung giải trình Phiếu báo giá gửi khách *</label>
                            <textarea name="shopNote" rows="3" required
                                      placeholder="Xưởng xác nhận báo giá: Đã kiểm tra đủ linh kiện, tiến hành gia công theo đúng yêu cầu..."
                                      style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:10px 12px;font-size:13px;"></textarea>
                        </div>
                    </div>
                </div>

                <div>
                    <div class="white-panel-card">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Khách hàng</h3>
                        <strong style="display:block;font-size:14px;"><%= order.getReceiverName() %></strong>
                        <span style="font-size:13px;color:#64748B;">SĐT: <%= order.getReceiverPhone() %></span>
                        <div style="font-size:13px;color:#475569;margin-top:8px;">Địa chỉ: <%= order.getShippingAddress() %></div>
                    </div>

                    <div class="white-panel-card" id="quotationSummaryBox"
                         data-base-total="<%= order.getTotalAmount() %>">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Tổng kết báo giá</h3>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;">
                            <span style="color:#64748B;">Tổng tiền tạm tính</span><strong><%= order.getFormattedTotal() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;color:#EA580C;font-weight:700;">
                            <span>+ Phụ phí báo giá</span><span id="liveExtraFeeText">+0₫</span>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;padding:12px 0;border-top:1px solid #E2E8F0;border-bottom:1px solid #E2E8F0;margin:8px 0;">
                            <strong>Tổng giá chốt báo khách</strong>
                            <strong style="font-size:18px;color:#EA580C;" id="liveFinalTotalText"><%= order.getFormattedTotal() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;padding-top:6px;">
                            <strong>Xưởng thực nhận</strong>
                            <strong style="font-size:16px;color:#16A34A;" id="liveNetShopText"><%= order.getFormattedNetShopReceive() %></strong>
                        </div>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;display:flex;flex-direction:column;gap:10px;">
                        <button type="submit" class="btn-seller-primary" style="height:44px;font-size:14px;"
                                onclick="document.getElementById('decisionInput').value='accept'">
                            ✓ Gửi Phiếu Báo Giá & Bắt đầu gia công
                        </button>
                        <button type="submit" class="btn-seller-outline"
                                style="height:40px;background:#FEF2F2;color:#DC2626;border-color:#FECACA;font-weight:700;"
                                onclick="document.getElementById('decisionInput').value='reject'; return confirm('Từ chối đơn gia công này?');">
                            ✕ Từ chối nhận đơn
                        </button>
                    </div>
                </div>
            </div>
        </form>
        <% } %>
    </main>
</div>

<script>
    function formatMoneyVND(n) {
        return (n || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") + "₫";
    }

    function updateLiveQuotation() {
        const box = document.getElementById('quotationSummaryBox');
        if (!box) return;
        const baseTotal = parseInt(box.getAttribute('data-base-total'), 10) || 0;
        const extraInput = document.getElementById('extraFeeInput');
        const extra = parseInt(extraInput.value, 10) || 0;

        const finalTotal = baseTotal + extra;
        const fee = Math.round(finalTotal * 0.061);
        const net = finalTotal - fee;

        document.getElementById('liveExtraFeeText').textContent = '+' + formatMoneyVND(extra);
        document.getElementById('liveFinalTotalText').textContent = formatMoneyVND(finalTotal);
        document.getElementById('liveNetShopText').textContent = formatMoneyVND(net);
    }
</script>
</body>
</html>