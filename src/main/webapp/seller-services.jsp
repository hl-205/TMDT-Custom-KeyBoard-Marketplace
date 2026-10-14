<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.CustomOrderDAO.ServicePackage" %>
<%@ page import="java.util.List" %>
<%
    if (request.getAttribute("services") == null) {
        response.sendRedirect("seller-services");
        return;
    }
    List<ServicePackage> services = (List<ServicePackage>) request.getAttribute("services");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dịch vụ gia công - KeebHub Seller</title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <!-- Sidebar Kênh người bán chuẩn Figma -->
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

        <div class="s-nav-section">Tổng quan</div>
        <a href="seller-orders" class="s-nav-item"><span>◎ Bảng điều khiển</span></a>

        <div class="s-nav-section">Đơn hàng</div>
        <a href="seller-orders" class="s-nav-item"><span>📦 Quản lý đơn hàng</span><span class="s-pill-orange">12</span></a>
        <a href="seller-confirm-custom" class="s-nav-item"><span>⚙️ Đơn custom chờ xác nhận</span><span class="s-pill-orange">3</span></a>
        <a href="seller-progress" class="s-nav-item"><span>🛠️ Tiến độ gia công</span><span class="s-pill-orange">5</span></a>

        <div class="s-nav-section">Sản phẩm</div>
        <a href="shop?id=2" class="s-nav-item"><span>📋 Danh sách sản phẩm</span></a>
        <a href="seller-services" class="s-nav-item active"><span>🔧 Dịch vụ gia công</span></a>

        <div class="s-nav-section">Khách hàng & Shop</div>
        <a href="index.jsp" class="s-nav-item"><span>🏠 Về sàn KeebHub</span></a>
    </aside>

    <!-- Main Content -->
    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Dịch vụ gia công</h1>
                <p><%= services.size() %> gói đang mở · công suất 10 đơn/ngày · 38 đơn trong tháng</p>
            </div>
            <div class="seller-top-right">
                <input type="text" class="seller-search-box" placeholder="🔍 Tìm gói dịch vụ...">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;">SH</div>
                    <span>Trần Hùng · Chủ shop ▾</span>
                </div>
                <button type="button" class="btn-seller-primary" onclick="openServiceModal('', '', '', '3–4 ngày làm việc', '', false)">+ Thêm gói dịch vụ</button>
            </div>
        </div>

        <% if (request.getParameter("msg") != null) { %>
        <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:10px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
            ✓ Đã cập nhật dữ liệu dịch vụ gia công thành công!
        </div>
        <% } %>

        <!-- 4 KPI Cards chuẩn Frame 26 -->
        <div class="seller-kpi-grid4">
            <div class="s-kpi-card">
                <div class="s-kpi-head">🛠️ Đơn gia công tháng này</div>
                <strong>38</strong>
                <span class="s-kpi-sub up">▲ 15.2% so với tháng trước</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">💰 Doanh thu gia công</div>
                <strong>28.5tr</strong>
                <span class="s-kpi-sub" style="color:#64748B;">3 gói dịch vụ đang bật</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">⏱️ Thời gian TB/đơn</div>
                <strong>5.4 ngày</strong>
                <span class="s-kpi-sub up">▲ Cam kết 5–7 ngày</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">⭐ Đánh giá dịch vụ</div>
                <strong>4.9</strong>
                <span class="s-kpi-sub up">▲ 96% đúng hẹn</span>
            </div>
        </div>

        <!-- Khối Các gói dịch vụ -->
        <section class="white-panel-card">
            <h2 style="font-size:16px;font-weight:800;">Các gói dịch vụ</h2>
            <p style="font-size:12px;color:#64748B;">Khách chọn gói ở bước 4 của Custom Builder</p>

            <div class="service-pkg-grid3">
                <% for (ServicePackage pkg : services) { %>
                <div class="service-pkg-card <%= pkg.isPopular() ? "popular" : "" %>">
                    <div>
                        <div class="pkg-top-row">
                            <h3><%= pkg.getServiceName() %></h3>
                            <a href="seller-services?action=toggle&id=<%= pkg.getId() %>"
                               class="toggle-pill-switch <%= !"ACTIVE".equals(pkg.getStatus()) ? "off" : "" %>"
                               title="Bật/Tắt gói dịch vụ">
                                <span></span>
                            </a>
                        </div>
                        <div class="pkg-price"><%= pkg.getFormattedPrice() %></div>
                        <div class="pkg-duration">
                            <%= pkg.getDurationText() %>
                            <% if (pkg.isPopular()) { %>
                            · <strong style="color:#1B64F2;">Bán chạy nhất</strong>
                            <% } %>
                        </div>

                        <ul class="pkg-feature-list">
                            <% for (String line : pkg.getFeatureLines()) { %>
                            <li><%= line.trim() %></li>
                            <% } %>
                        </ul>
                    </div>

                    <div>
                        <div class="pkg-bottom-stats">
                            <span style="color:#64748B;">Đã bán tháng này</span>
                            <strong><%= pkg.getSoldMonth() %> đơn</strong>
                        </div>
                        <div style="display:flex;gap:8px;">
                            <button type="button"
                                    class="<%= pkg.isPopular() ? "btn-seller-primary" : "btn-seller-outline" %>"
                                    style="flex:1;"
                                    onclick="openServiceModal('<%= pkg.getId() %>', '<%= pkg.getServiceName().replace("'", "\\'") %>', '<%= pkg.getPrice() %>', '<%= pkg.getDurationText().replace("'", "\\'") %>', '<%= pkg.getDescription().replace("'", "\\'") %>', <%= pkg.isPopular() %>)">
                                Chỉnh sửa gói
                            </button>
                            <% if (services.size() > 1) { %>
                            <a href="seller-services?action=delete&id=<%= pkg.getId() %>"
                               class="btn-seller-outline" style="color:#EF4444;border-color:#FECACA;"
                               onclick="return confirm('Xóa gói dịch vụ này?')">Xoá</a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </section>

        <!-- Khối Cấu hình công suất xưởng & Vật tư gia công chuẩn Frame 26 -->
        <div class="capacity-bottom-grid">
            <form action="seller-services" method="POST" class="white-panel-card" style="margin-bottom:0;">
                <input type="hidden" name="formType" value="capacity">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
                    <h3 style="font-size:15px;font-weight:800;">Cấu hình công suất xưởng</h3>
                    <span style="font-size:12px;color:#94A3B8;">Quyết định số đơn custom sàn cho phép nhận mỗi ngày</span>
                </div>

                <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:16px;">
                    <div>
                        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Số đơn tối đa nhận / ngày</label>
                        <input type="number" name="maxOrders" value="<%= session.getAttribute("cap_maxOrders") != null ? session.getAttribute("cap_maxOrders") : "10" %>"
                               min="1" max="50" style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                    </div>
                    <div>
                        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Số thợ đang làm</label>
                        <input type="number" name="staffCount" value="<%= session.getAttribute("cap_staffCount") != null ? session.getAttribute("cap_staffCount") : "4" %>"
                               min="1" max="20" style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                    </div>
                </div>

                <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:18px;">
                    <div>
                        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Ngày làm việc trong tuần</label>
                        <div class="day-pills-row">
                            <span class="day-pill active">T2</span>
                            <span class="day-pill active">T3</span>
                            <span class="day-pill active">T4</span>
                            <span class="day-pill active">T5</span>
                            <span class="day-pill active">T6</span>
                            <span class="day-pill active">T7</span>
                            <span class="day-pill">CN</span>
                        </div>
                    </div>
                    <div>
                        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:6px;">Giờ làm việc</label>
                        <input type="text" name="workHours" value="<%= session.getAttribute("cap_workHours") != null ? session.getAttribute("cap_workHours") : "08:30 – 18:00" %>"
                               style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                    </div>
                </div>

                <div style="display:flex;flex-direction:column;gap:12px;margin-bottom:18px;">
                    <label style="display:flex;align-items:center;gap:10px;cursor:pointer;">
                        <input type="checkbox" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                        <div>
                            <strong style="font-size:13px;display:block;">Tự động từ chối khi hết slot</strong>
                            <span style="font-size:12px;color:#64748B;">Đơn mới sẽ đẩy sang ngày trống gần nhất thay vì báo lỗi</span>
                        </div>
                    </label>
                    <label style="display:flex;align-items:center;gap:10px;cursor:pointer;">
                        <input type="checkbox" checked style="width:16px;height:16px;accent-color:#1B64F2;">
                        <div>
                            <strong style="font-size:13px;display:block;">Bắt buộc cập nhật ảnh mỗi công đoạn</strong>
                            <span style="font-size:12px;color:#64748B;">Giảm khiếu nại, tăng điểm uy tín shop</span>
                        </div>
                    </label>
                </div>

                <button type="submit" class="btn-seller-primary">Lưu cấu hình công suất</button>
            </form>

            <div class="white-panel-card" style="margin-bottom:0;">
                <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Vật tư gia công</h3>
                <table class="orders-table">
                    <thead>
                    <tr><th>Vật tư</th><th>Còn lại</th><th>Trạng thái</th></tr>
                    </thead>
                    <tbody>
                    <tr><td><strong>Krytox 205g0</strong><br><span style="font-size:11px;color:#94A3B8;">Dầu lube switch</span></td><td><strong>14 ml</strong></td><td><span class="st-badge processing">Sắp hết</span></td></tr>
                    <tr><td><strong>Dielectric grease</strong><br><span style="font-size:11px;color:#94A3B8;">Lube stabilizer</span></td><td><strong>62 ml</strong></td><td><span class="st-badge completed">Đủ</span></td></tr>
                    <tr><td><strong>Film Deskeys</strong><br><span style="font-size:11px;color:#94A3B8;">Film switch</span></td><td><strong>840 cái</strong></td><td><span class="st-badge completed">Đủ</span></td></tr>
                    <tr><td><strong>PE foam 0.5mm</strong><br><span style="font-size:11px;color:#94A3B8;">Tape/PE mod</span></td><td><strong>3 tấm</strong></td><td><span class="st-badge pending">Sắp hết</span></td></tr>
                    <tr><td><strong>Band-aid</strong><br><span style="font-size:11px;color:#94A3B8;">Mod stabilizer</span></td><td><strong>210 miếng</strong></td><td><span class="st-badge completed">Đủ</span></td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Modal Thêm / Chỉnh sửa Gói dịch vụ -->
<div class="modal-backdrop" id="serviceModal">
    <div class="modal-card">
        <h3 id="modalTitle" style="font-size:18px;font-weight:800;margin-bottom:16px;">Chỉnh sửa gói dịch vụ</h3>
        <form action="seller-services" method="POST">
            <input type="hidden" name="serviceId" id="mServiceId">
            <div style="margin-bottom:12px;">
                <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Tên gói dịch vụ *</label>
                <input type="text" name="serviceName" id="mServiceName" required
                       style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px;">
                <div>
                    <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Đơn giá (VNĐ) *</label>
                    <input type="number" name="price" id="mPrice" min="50000" step="10000" required
                           style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                </div>
                <div>
                    <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Thời gian thực hiện *</label>
                    <input type="text" name="durationText" id="mDuration" required
                           style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
                </div>
            </div>
            <div style="margin-bottom:12px;">
                <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Các hạng mục công việc (ngăn cách bằng dấu chấm phẩy `;`) *</label>
                <textarea name="description" id="mDesc" rows="4" required
                          style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:8px 12px;"></textarea>
            </div>
            <label style="display:flex;align-items:center;gap:8px;margin-bottom:18px;font-size:13px;cursor:pointer;">
                <input type="checkbox" name="isPopular" id="mPopular" style="width:16px;height:16px;accent-color:#1B64F2;">
                <span>Đánh dấu là gói <strong>Bán chạy nhất</strong> (Viền xanh nổi bật)</span>
            </label>
            <div style="display:flex;justify-content:flex-end;gap:10px;">
                <button type="button" class="btn-seller-outline" onclick="closeServiceModal()">Huỷ</button>
                <button type="submit" class="btn-seller-primary">Lưu gói dịch vụ</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openServiceModal(id, name, price, duration, desc, popular) {
        document.getElementById('mServiceId').value = id;
        document.getElementById('mServiceName').value = name;
        document.getElementById('mPrice').value = price;
        document.getElementById('mDuration').value = duration;
        document.getElementById('mDesc').value = desc;
        document.getElementById('mPopular').checked = popular;
        document.getElementById('modalTitle').textContent = id ? 'Chỉnh sửa gói dịch vụ' : 'Thêm gói dịch vụ mới';
        document.getElementById('serviceModal').classList.add('show');
    }
    function closeServiceModal() {
        document.getElementById('serviceModal').classList.remove('show');
    }
</script>
</body>
</html>