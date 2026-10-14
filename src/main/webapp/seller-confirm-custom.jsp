<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("seller-confirm-custom");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác nhận đơn custom #<%= order.getOrderCode() %> - KeebHub Seller</title>
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
        <a href="seller-orders" class="s-nav-item"><span>📦 Quản lý đơn hàng</span><span class="s-pill-orange">12</span></a>
        <a href="seller-confirm-custom" class="s-nav-item active"><span>⚙️ Đơn custom chờ xác nhận</span><span class="s-pill-orange">3</span></a>
        <a href="seller-progress" class="s-nav-item"><span>🛠️ Tiến độ gia công</span><span class="s-pill-orange">5</span></a>

        <div class="s-nav-section">Sản phẩm</div>
        <a href="seller-services" class="s-nav-item"><span>🔧 Dịch vụ gia công</span></a>
        <a href="index.jsp" class="s-nav-item"><span>🏠 Về sàn KeebHub</span></a>
    </aside>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Xác nhận đơn custom</h1>
                <p>Đơn #<%= order.getOrderCode() %> · <%= order.getReceiverName() %> · Gửi 25/09/2026 20:18</p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;">SH</div>
                    <span>Trần Hùng · Chủ shop ▾</span>
                </div>
            </div>
        </div>

        <div class="sla-warning-banner">
            ⏰ Đơn đã chờ <strong>18 giờ 42 phút</strong>. Theo quy định sàn, shop phải phản hồi trong <strong>24 giờ</strong> kể từ khi khách thanh toán, nếu không đơn sẽ tự huỷ và hoàn tiền cho khách, đồng thời tính vào tỉ lệ huỷ đơn của shop.
        </div>

        <form action="seller-confirm-custom" method="POST" id="confirmOrderForm">
            <input type="hidden" name="orderId" value="<%= order.getId() %>">
            <input type="hidden" name="decision" id="decisionInput" value="accept">

            <div class="confirm-layout-2col">
                <!-- Cột Trái: Build Sheet + Kiểm tra + Phản hồi -->
                <div>
                    <div class="white-panel-card">
                        <div style="display:flex;justify-content:space-between;align-items:center;">
                            <div>
                                <h2 style="font-size:17px;font-weight:800;">Build Sheet — <%= order.getBuildCode() %></h2>
                                <span style="font-size:12px;color:#64748B;">Cấu hình khách chốt từ Custom Builder · đã kiểm tra tương thích tự động</span>
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
                                <tr><td>Kit</td><td>Keychron Q1 Pro · Carbon Black</td></tr>
                                <tr><td>Plate</td><td>PC (polycarbonate)</td></tr>
                                <tr><td>Switch</td><td>Boba U4T Thocky ×84 · Tactile 62g</td></tr>
                                <tr><td>Keycap</td><td>MW Jamón Cherry · base + novelty</td></tr>
                                <tr><td>Stabilizer</td><td>Durock V2 screw-in ×5</td></tr>
                                <tr><td>Gói gia công</td><td>Premium — mod đầy đủ</td></tr>
                                <tr><td>Cam kết</td><td><%= order.getCommittedDays() %> ngày làm việc</td></tr>
                            </table>
                        </div>

                        <strong style="font-size:13px;">Yêu cầu riêng của khách</strong>
                        <div class="customer-quote-box">
                            💬 “<%= (order.getCustomerNote() != null && !order.getCustomerNote().isEmpty()) ? order.getCustomerNote() : "Nhờ shop lube kỹ stabilizer và kiểm tra toàn bộ socket trước khi lắp." %>”
                        </div>

                        <strong style="font-size:13px;display:block;margin-bottom:10px;">Kiểm tra trước khi nhận</strong>
                        <div style="display:flex;flex-direction:column;gap:10px;">
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" class="precheck-item" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Đủ tồn kho toàn bộ linh kiện (đã giữ chỗ)</span>
                            </label>
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" class="precheck-item" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Xưởng còn slot trong <%= order.getCommittedDays() %> ngày cam kết</span>
                            </label>
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" class="precheck-item" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Có đủ vật tư mod: PE foam, tape, band-aid, Krytox 205g0</span>
                            </label>
                            <label style="display:flex;align-items:center;gap:10px;font-size:13px;cursor:pointer;">
                                <input type="checkbox" style="width:16px;height:16px;accent-color:#1B64F2;">
                                <span>Đã liên hệ khách xác nhận yêu cầu riêng</span>
                            </label>
                        </div>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Phản hồi cho khách</h3>

                        <div style="margin-bottom:14px;">
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Thời gian gia công cam kết <span style="color:#EF4444;">*</span></label>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <input type="number" name="committedDays" value="<%= order.getCommittedDays() %>" min="1" max="30" required
                                       style="width:90px;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;font-weight:700;">
                                <span style="font-size:13px;color:#64748B;">ngày làm việc · Dự kiến bàn giao vận chuyển <strong>05/10/2026</strong></span>
                            </div>
                        </div>

                        <div style="margin-bottom:14px;">
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Ghi chú gửi khách</label>
                            <textarea name="shopNote" rows="3" placeholder="Xưởng đã kiểm tra đủ linh kiện, sẽ gửi ảnh từng bước rã hàn và lube cho bạn..."
                                      style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:10px 12px;font-size:13px;"></textarea>
                        </div>

                        <div>
                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Phụ phí phát sinh (nếu có)</label>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <input type="text" name="extraFee" placeholder="0"
                                       oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                       style="width:160px;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                                <span style="font-size:12px;color:#94A3B8;">₫ · Khách phải đồng ý trước khi shop bắt đầu</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cột Phải: Khách hàng, Giá trị đơn, Nút Nhận / Từ chối -->
                <div>
                    <div class="white-panel-card">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Khách hàng</h3>
                        <div style="display:flex;align-items:center;gap:12px;margin-bottom:14px;">
                            <div style="width:42px;height:42px;border-radius:50%;background:#1B64F2;color:#FFF;font-weight:800;display:flex;align-items:center;justify-content:center;">NM</div>
                            <div>
                                <strong style="display:block;"><%= order.getReceiverName() %></strong>
                                <span style="font-size:12px;color:#64748B;"><%= order.getReceiverPhone() %></span>
                            </div>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;">
                            <span style="color:#64748B;">Đã mua tại shop</span><strong>6 đơn</strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;">
                            <span style="color:#64748B;">Tỉ lệ huỷ đơn</span><strong style="color:#16A34A;">0%</strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0 12px;">
                            <span style="color:#64748B;">Đánh giá đã để lại</span><strong>5 · trung bình 5.0 ★</strong>
                        </div>
                        <button type="button" class="btn-seller-outline" style="width:100%;">💬 Nhắn tin cho khách</button>
                    </div>

                    <div class="white-panel-card">
                        <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Giá trị đơn</h3>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0;">
                            <span style="color:#64748B;">Linh kiện</span><strong><%= order.getFormattedSubtotal() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:6px 0 12px;border-bottom:1px solid #F1F5F9;">
                            <span style="color:#64748B;">Gói gia công</span><strong><%= order.getFormattedCustomFee() %></strong>
                        </div>
                        <div style="display:flex;justify-content:space-between;font-size:13px;padding:10px 0 6px;">
                            <span style="color:#64748B;">Khách đã trả</span><strong><%= order.getFormattedTotal() %></strong>
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
                        <span style="font-size:11px;color:#94A3B8;display:block;margin-top:6px;">Tiền về ví shop sau khi khách xác nhận nhận hàng</span>
                    </div>

                    <div class="white-panel-card" style="margin-bottom:0;display:flex;flex-direction:column;gap:10px;">
                        <button type="submit" class="btn-seller-primary" style="height:44px;font-size:14px;"
                                onclick="document.getElementById('decisionInput').value='accept'">
                            ✓ Nhận đơn & bắt đầu gia công
                        </button>
                        <button type="button" class="btn-seller-outline" style="height:40px;">
                            💬 Hỏi thêm khách trước
                        </button>
                        <button type="submit" class="btn-seller-outline"
                                style="height:40px;background:#FEF2F2;color:#DC2626;border-color:#FECACA;font-weight:700;"
                                onclick="document.getElementById('decisionInput').value='reject'; return confirm('Từ chối đơn gia công này và hoàn tiền cho khách?');">
                            ✕ Từ chối đơn
                        </button>
                        <span style="font-size:11px;color:#94A3B8;line-height:1.4;">Từ chối đơn sẽ hoàn tiền toàn bộ cho khách và tính vào tỉ lệ từ chối của shop (hiện 1.2%).</span>
                    </div>
                </div>
            </div>
        </form>
    </main>
</div>

</body>
</html>