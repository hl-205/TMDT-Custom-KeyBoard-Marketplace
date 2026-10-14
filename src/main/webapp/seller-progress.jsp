<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CustomOrderDAO.CustomOrder" %>
<%@ page import="dao.CustomOrderDAO.ProgressStep" %>
<%@ page import="java.util.List" %>
<%
    CustomOrder order = (CustomOrder) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect("seller-progress");
        return;
    }
    List<ProgressStep> steps = (List<ProgressStep>) request.getAttribute("steps");
    List<CustomOrder> workshopQueue = (List<CustomOrder>) request.getAttribute("workshopQueue");

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
    <title>Tiến độ gia công #<%= order.getOrderCode() %> - KeebHub Seller</title>
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
        <a href="seller-confirm-custom" class="s-nav-item"><span>⚙️ Đơn custom chờ xác nhận</span><span class="s-pill-orange">3</span></a>
        <a href="seller-progress" class="s-nav-item active"><span>🛠️ Tiến độ gia công</span><span class="s-pill-orange">5</span></a>

        <div class="s-nav-section">Sản phẩm</div>
        <a href="seller-services" class="s-nav-item"><span>🔧 Dịch vụ gia công</span></a>
        <a href="order-detail?code=<%= order.getOrderCode() %>" class="s-nav-item"><span>👁️ Xem giao diện Khách hàng</span></a>
    </aside>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Tiến độ gia công</h1>
                <p>5 đơn đang trong xưởng · 2 đơn tới hạn trong 48 giờ</p>
            </div>
            <div class="seller-top-right">
                <a href="order-detail?code=<%= order.getOrderCode() %>" class="btn-seller-outline">👁️ Xem góc nhìn Khách hàng (Frame 15)</a>
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;">SH</div>
                    <span>Trần Hùng · Chủ shop ▾</span>
                </div>
            </div>
        </div>

        <% if (request.getParameter("msg") != null) { %>
        <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:10px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
            ✓ Đã lưu cập nhật tiến độ gia công! Tiến độ hiện tại của đơn #<%= order.getOrderCode() %> là <%= order.getProgressPercent() %>%.
        </div>
        <% } %>

        <div class="confirm-layout-2col">
            <!-- Cột Trái: Timeline 5 công đoạn gia công chuẩn Frame 22 -->
            <div class="white-panel-card">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <h2 style="font-size:18px;font-weight:800;">Đơn #<%= order.getOrderCode() %> · <%= order.getBuildCode() %></h2>
                        <span style="font-size:12px;color:#64748B;"><%= order.getReceiverName() %> · Nhận 21/09 · Cam kết bàn giao <%= order.getCommittedDays() %> ngày</span>
                    </div>
                    <span class="st-badge processing">Đang gia công · <%= order.getProgressPercent() %>%</span>
                </div>

                <div style="display:flex;align-items:center;gap:14px;">
                    <div class="progress-bar-Full" style="flex:1;">
                        <div class="progress-bar-Fill" style="width:<%= order.getProgressPercent() %>%;"></div>
                    </div>
                    <strong style="font-size:13px;"><%= completedCount %>/5 công đoạn</strong>
                </div>

                <!-- Danh sách 5 bước -->
                <% for (ProgressStep st : steps) {
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
                        <div style="display:flex;gap:8px;">
                            <div style="width:56px;height:44px;background:#F8FAFC;border:1px solid #CBD5E1;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:10px;color:#1B64F2;font-weight:700;">IMG 1</div>
                            <div style="width:56px;height:44px;background:#F8FAFC;border:1px solid #CBD5E1;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:10px;color:#1B64F2;font-weight:700;">IMG 2</div>
                        </div>
                        <% } else if (isCurrent) { %>
                        <!-- Form cập nhật công đoạn đang làm chuẩn Frame 22 -->
                        <form action="seller-progress" method="POST" style="margin-top:8px;">
                            <input type="hidden" name="orderId" value="<%= order.getId() %>">
                            <input type="hidden" name="stepNumber" value="<%= st.getStepNumber() %>">

                            <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Ghi chú công đoạn</label>
                            <textarea name="stepDesc" rows="3" required
                                      placeholder="Nhập kết quả kiểm tra thực tế của công đoạn này để gửi thông báo cho khách..."
                                      style="width:100%;border:1.5px solid #1B64F2;border-radius:8px;padding:10px 12px;font-size:13px;margin-bottom:12px;"><%= st.getStepDesc() %></textarea>

                            <div style="display:flex;align-items:center;gap:14px;">
                                <div style="width:82px;height:66px;border:1px dashed #CBD5E1;background:#F8FAFC;border-radius:8px;display:flex;flex-direction:column;align-items:center;justify-content:center;font-size:11px;color:#64748B;">
                                    <span>📷</span><span>Thêm ảnh</span>
                                </div>
                                <div style="flex:1;">
                                    <p style="font-size:12px;color:#94A3B8;margin-bottom:10px;">Ảnh thực tế giúp khách yên tâm và giảm khiếu nại. Shop có ảnh ở mỗi công đoạn được ưu tiên hiển thị trong kết quả tìm kiếm.</p>
                                    <div style="display:flex;gap:10px;">
                                        <button type="submit" name="submitAction" value="complete" class="btn-seller-primary">Lưu & hoàn thành bước này</button>
                                        <button type="submit" name="submitAction" value="draft" class="btn-seller-outline">Chỉ lưu nháp</button>
                                    </div>
                                </div>
                            </div>
                        </form>
                        <% } else { %>
                        <p style="font-size:12px;color:#94A3B8;"><%= st.getStepDesc() %></p>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Cột Phải: Build Sheet tóm tắt & Hành động nhanh -->
            <div>
                <div class="white-panel-card">
                    <h3 style="font-size:15px;font-weight:800;margin-bottom:12px;">Build Sheet</h3>
                    <table class="build-sheet-table" style="border:none;">
                        <tr><td>Kit</td><td>Tofu60 2.0 · Silver</td></tr>
                        <tr><td>Plate</td><td>Brass</td></tr>
                        <tr><td>Switch</td><td>Oil King ×70</td></tr>
                        <tr><td>Keycap</td><td>GMK Olivia++</td></tr>
                        <tr><td>Stab</td><td>Durock V2 screw-in</td></tr>
                        <tr><td>Gói</td><td>Full lube + tune</td></tr>
                    </table>
                    <button type="button" class="btn-seller-outline" style="width:100%;margin-top:12px;" onclick="window.print()">📄 In Build Sheet cho thợ</button>
                </div>

                <div class="white-panel-card" style="display:flex;flex-direction:column;gap:10px;">
                    <button type="button" class="btn-seller-outline" style="height:40px;">💬 Nhắn khách về tiến độ</button>
                    <button type="button" class="btn-seller-outline" style="height:40px;">⏱️ Xin gia hạn thêm ngày</button>
                    <button type="button" class="btn-seller-outline" style="height:40px;background:#FFFBEB;border-color:#FDE68A;color:#92400E;font-weight:700;">⚠️ Báo sự cố kỹ thuật</button>
                    <span style="font-size:11px;color:#94A3B8;">Báo sự cố khi linh kiện lỗi, thiếu hàng hoặc hỏng trong lúc gia công.</span>
                </div>
            </div>
        </div>

        <!-- Bảng Hàng đợi xưởng dưới cùng chuẩn Frame 22 -->
        <section class="white-panel-card" style="margin-bottom:0;">
            <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Hàng đợi xưởng</h3>
            <table class="orders-table">
                <thead>
                <tr><th>Đơn</th><th>Khách</th><th>Tiến độ</th><th>Hạn</th><th>Tình trạng</th><th></th></tr>
                </thead>
                <tbody>
                <% for (CustomOrder q : workshopQueue) { %>
                <tr>
                    <td><strong>#<%= q.getOrderCode() %></strong><br><span style="font-size:11px;color:#94A3B8;"><%= q.getBuildCode() %></span></td>
                    <td><%= q.getReceiverName() %></td>
                    <td style="width:200px;">
                        <div style="display:flex;align-items:center;gap:8px;">
                            <div style="flex:1;height:6px;background:#E2E8F0;border-radius:4px;overflow:hidden;">
                                <div style="width:<%= q.getProgressPercent() %>%;height:100%;background:#1B64F2;"></div>
                            </div>
                            <strong><%= q.getProgressPercent() %>%</strong>
                        </div>
                    </td>
                    <td>28/09</td>
                    <td><span class="st-badge processing">Đúng tiến độ</span></td>
                    <td style="text-align:right;">
                        <a href="seller-progress?id=<%= q.getId() %>" class="btn-seller-outline" style="height:30px;font-size:12px;">Cập nhật</a>
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