<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CustomOrderDAO.ServicePackage" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    if (request.getAttribute("services") == null) {
        response.sendRedirect("seller-services");
        return;
    }
    Shop sellerShop = (Shop) request.getAttribute("sellerShop");
    String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
    List<ServicePackage> services = (List<ServicePackage>) request.getAttribute("services");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dịch vụ gia công - <%= shopName %></title>
    <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
    <jsp:include page="includes/seller-sidebar.jsp">
        <jsp:param name="activeMenu" value="services" />
    </jsp:include>

    <main class="seller-main-area">
        <div class="seller-topbar">
            <div class="seller-page-title">
                <h1>Dịch vụ gia công</h1>
                <p>${activePkgCount} gói đang mở · ${totalSoldMonth} đơn trong tháng</p>
            </div>
            <div class="seller-top-right">
                <div class="seller-user-pill">
                    <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
                    <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
                </div>
                <button type="button" class="btn-seller-primary" onclick="openServiceModal('', '', '', '3–4 ngày làm việc', '', false)">+ Thêm gói dịch vụ</button>
            </div>
        </div>

        <% if (request.getParameter("msg") != null) { %>
        <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:10px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
            ✓ Đã cập nhật dữ liệu dịch vụ gia công trong Database thành công!
        </div>
        <% } %>

        <div class="seller-kpi-grid4">
            <div class="s-kpi-card">
                <div class="s-kpi-head">🛠️ Đơn gia công tháng này</div>
                <strong>${totalSoldMonth}</strong>
                <span class="s-kpi-sub up">▲ Dữ liệu từ bảng custom_services</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">💰 Doanh thu gia công</div>
                <strong>${formattedCustomRevenue}</strong>
                <span class="s-kpi-sub" style="color:#64748B;">${activePkgCount} gói dịch vụ đang bật</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">⏱️ Công suất nhận đơn</div>
                <strong><%= session.getAttribute("cap_maxOrders") != null ? session.getAttribute("cap_maxOrders") : "10" %> đơn/ngày</strong>
                <span class="s-kpi-sub up">▲ <%= session.getAttribute("cap_staffCount") != null ? session.getAttribute("cap_staffCount") : "4" %> thợ kỹ thuật</span>
            </div>
            <div class="s-kpi-card">
                <div class="s-kpi-head">⭐ Đánh giá xưởng</div>
                <strong><%= sellerShop != null ? sellerShop.getRatingAvg() : 4.8 %></strong>
                <span class="s-kpi-sub up">▲ <%= sellerShop != null ? sellerShop.getOnTimeRate() : 96.0 %>% đúng hẹn</span>
            </div>
        </div>

        <section class="white-panel-card">
            <h2 style="font-size:16px;font-weight:800;">Các gói dịch vụ của <%= shopName %></h2>

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
                               onclick="return confirm('Xóa gói dịch vụ này khỏi Database?')">Xoá</a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </section>

        <div class="capacity-bottom-grid">
            <form action="seller-services" method="POST" class="white-panel-card" style="margin-bottom:0;">
                <input type="hidden" name="formType" value="capacity">
                <h3 style="font-size:15px;font-weight:800;margin-bottom:16px;">Cấu hình công suất xưởng</h3>

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

                <button type="submit" class="btn-seller-primary">Lưu cấu hình công suất</button>
            </form>

            <div class="white-panel-card" style="margin-bottom:0;">
                <h3 style="font-size:15px;font-weight:800;margin-bottom:14px;">Thông tin vận hành xưởng (<%= shopName %>)</h3>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #F1F5F9;">
                    <span>Chủ sở hữu</span><strong><%= currentUser.getFullName() %></strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #F1F5F9;">
                    <span>Email quản trị</span><strong><%= currentUser.getEmail() %></strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid #F1F5F9;">
                    <span>Địa chỉ xưởng</span><strong><%= sellerShop != null ? sellerShop.getAddress() : "TP.HCM" %></strong>
                </div>
                <div style="display:flex;justify-content:space-between;padding:8px 0;">
                    <span>Tỉ lệ giao đúng hẹn</span><strong style="color:#16A34A;"><%= sellerShop != null ? sellerShop.getOnTimeRate() : 96.0 %>%</strong>
                </div>
            </div>
        </div>
    </main>
</div>

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