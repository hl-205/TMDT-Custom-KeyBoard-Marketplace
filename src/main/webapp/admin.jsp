<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bảng Quản Trị Hệ Thống - KeebHub</title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/admin.css">

    <style>
        .topbar-content,
        .header-content,
        .nav-content {
            max-width: 1240px;
            margin: 0 auto;
            padding: 0 20px;
            box-sizing: border-box;
        }

        .clickable-card {
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .clickable-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.12);
        }
        .chart-box {
            cursor: pointer;
            height: 260px;
            position: relative;
        }
        .legend-list li {
            transition: background-color 0.15s ease, padding-left 0.15s ease;
            border-radius: 6px;
            padding: 8px 6px;
        }
        .legend-list li:hover {
            background-color: #f1f5f9;
        }
        .legend-badge {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 3px;
            margin-right: 8px;
            vertical-align: middle;
        }
        .role-ADMIN { background: #fee2e2; color: #dc2626; }
        .role-SELLER { background: #f3e8ff; color: #7c3aed; }
        .role-CUSTOMER, .role-USER { background: #dbeafe; color: #1d4ed8; }
        .role-MODERATOR { background: #fef3c7; color: #b45309; }
    </style>
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body>
<jsp:include page="includes/header.jsp" />
<main class="wrap">
    <!-- Header Admin -->
    <div class="admin-header">
        <h1>Bảng Quản Trị Hệ Thống</h1>
        <p>Thống kê số liệu tổng quan và quản lý Người dùng, Đơn hàng, Sản phẩm trên KeebHub.</p>
    </div>

    <!-- 1. THỐNG KÊ NHANH -->
    <div class="stats-grid">
        <div class="stat-card clickable-card" data-nav-tab="users" title="Bấm để xem danh sách Người dùng">
            <div class="stat-details">
                <div class="stat-title">Người dùng</div>
                <div class="stat-value" id="stat-user-count">${stats.userCount}</div>
            </div>
            <div class="stat-icon icon-blue">👥</div>
        </div>

        <div class="stat-card clickable-card" data-nav-tab="orders" title="Bấm để xem danh sách Đơn hàng">
            <div class="stat-details">
                <div class="stat-title">Đơn hàng</div>
                <div class="stat-value" id="stat-order-count">${stats.orderCount}</div>
            </div>
            <div class="stat-icon icon-purple">🛒</div>
        </div>

        <div class="stat-card clickable-card" data-nav-tab="products" title="Bấm để xem danh sách Sản phẩm">
            <div class="stat-details">
                <div class="stat-title">Sản phẩm</div>
                <div class="stat-value" id="stat-product-count">${stats.productCount}</div>
            </div>
            <div class="stat-icon icon-orange">📦</div>
        </div>

        <div class="stat-card">
            <div class="stat-details">
                <div class="stat-title">Doanh thu đơn không hủy</div>
                <div class="stat-value" id="stat-total-value">
                    <fmt:formatNumber value="${stats.totalOrdersValue}" type="number" groupingUsed="true"/> ₫
                </div>
            </div>
            <div class="stat-icon icon-green">💰</div>
        </div>
    </div>

    <!-- 2. BIỂU ĐỒ CỘT & CHÚ THÍCH -->
    <div class="charts-grid">
        <!-- Biểu đồ Cột Roles -->
        <div class="panel" style="margin: 0;">
            <div class="panel-header">
                <h2>👥 Tỉ lệ Vai trò (Role) người dùng</h2>
            </div>
            <div class="chart-layout">
                <div class="chart-box" data-nav-tab="users" title="Bấm để chuyển sang Quản lý người dùng">
                    <canvas id="userRoleChart"></canvas>
                </div>
                <ul class="legend-list" id="roleLegendList">
                    <c:choose>
                        <c:when test="${not empty stats.roleStats}">
                            <c:forEach items="${stats.roleStats}" var="r">
                                <c:set var="roleColor" value="${r.key == 'ADMIN' ? '#dc2626' : (r.key == 'SELLER' ? '#7c3aed' : (r.key == 'MODERATOR' ? '#f59e0b' : '#2563eb'))}" />
                                <li data-nav-tab="users" style="cursor: pointer;" title="Bấm để xem danh sách Người dùng">
                                    <span><span class="legend-badge" style="background-color: ${roleColor};"></span> Vai trò <strong>${r.key}</strong></span>
                                    <strong>${r.value} tài khoản</strong>
                                </li>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <li><span>Chưa có dữ liệu vai trò</span><strong>0</strong></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>

        <!-- Biểu đồ Cột Đơn hàng -->
        <div class="panel" style="margin: 0;">
            <div class="panel-header">
                <h2>🛒 Tỉ lệ Trạng thái Đơn hàng</h2>
            </div>
            <div class="chart-layout">
                <div class="chart-box" data-nav-tab="orders" title="Bấm để chuyển sang Quản lý đơn hàng">
                    <canvas id="orderStatusChart"></canvas>
                </div>
                <ul class="legend-list" id="orderStatusLegendList">
                    <c:choose>
                        <c:when test="${not empty stats.orderStatusStats}">
                            <c:forEach items="${stats.orderStatusStats}" var="s">
                                <c:set var="statusColor" value="${s.key == 'COMPLETED' ? '#16a34a' : (s.key == 'PROCESSING' ? '#2563eb' : (s.key == 'PENDING' ? '#f59e0b' : (s.key == 'CANCELLED' ? '#dc2626' : (s.key == 'SHIPPED' ? '#7c3aed' : '#0891b2'))))}" />
                                <li data-nav-tab="orders" style="cursor: pointer;" title="Bấm để xem danh sách Đơn hàng">
                                    <span><span class="legend-badge" style="background-color: ${statusColor};"></span> Trạng thái <strong>${s.key}</strong></span>
                                    <strong>${s.value} đơn</strong>
                                </li>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <li><span>Chưa có dữ liệu đơn hàng</span><strong>0</strong></li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>
    </div>

    <!-- 3. THANH CHUYỂN TAB CÁC CHỨC NĂNG QUẢN LÝ -->
    <div class="admin-tabs" id="adminTabsSection">
        <button class="tab-btn active" data-tab="users" data-switch-tab="users">👥 Quản lý người dùng</button>
        <button class="tab-btn" data-tab="orders" data-switch-tab="orders">🛒 Quản lý đơn hàng</button>
        <button class="tab-btn" data-tab="products" data-switch-tab="products">📦 Quản lý sản phẩm</button>
    </div>

    <!-- ================= TAB 1: QUẢN LÝ NGƯỜI DÙNG ================= -->
    <div id="tab-users" class="tab-pane active">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách người dùng</h2>
                <button class="btn-action btn-update" type="button" data-add="user">+ Thêm người dùng</button>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Họ tên</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="userTableBody">
                    <c:forEach items="${users}" var="u">
                        <tr id="row-user-${u.id}" data-entity="user" data-id="${u.id}"
                            data-first-name="<c:out value='${u.first_name}'/>" data-last-name="<c:out value='${u.last_name}'/>"
                            data-email="<c:out value='${u.email}'/>" data-role="<c:out value='${u.role}'/>" data-status="<c:out value='${u.status}'/>">
                            <td><strong>#${u.id}</strong></td>
                            <td><c:out value="${u.first_name}"/> <c:out value="${u.last_name}"/></td>
                            <td><c:out value="${u.email}"/></td>
                            <td><span class="badge-status role-${u.role}">${u.role}</span></td>
                            <td><span class="badge-status status-${u.status}">${u.status}</span></td>
                            <td>
                                <div style="display:inline-flex; gap:6px;">
                                    <button type="button" class="btn-action btn-update" data-action="edit">Sửa</button>
                                    <button type="button" class="btn-action btn-delete" data-action="delete">Xóa</button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <!-- ================= TAB 2: QUẢN LÝ ĐƠN HÀNG ================= -->
    <div id="tab-orders" class="tab-pane">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách đơn hàng</h2>
                <button class="btn-action btn-update" type="button" data-add="order">+ Tạo đơn hàng</button>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Người nhận</th>
                        <th>Email</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="orderTableBody">
                    <c:forEach items="${orders}" var="o">
                        <tr id="row-order-${o.id}" data-entity="order" data-id="${o.id}"
                            data-order-code="<c:out value='${o.order_code}'/>" data-receiver-name="<c:out value='${o.receiver_name}'/>"
                            data-customer-email="<c:out value='${o.customer_email}'/>" data-total-amount="${o.total_amount}"
                            data-status="<c:out value='${o.order_status}'/>">
                            <td><strong><c:out value="${o.order_code}"/></strong></td>
                            <td><c:out value="${o.receiver_name}"/></td>
                            <td><c:out value="${o.customer_email}"/></td>
                            <td style="font-weight:700; color:#ea580c;">
                                <fmt:formatNumber value="${o.total_amount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td><span class="badge-status status-${o.order_status}">${o.order_status}</span></td>
                            <td>
                                <div style="display:inline-flex; gap:6px;">
                                    <button type="button" class="btn-action btn-update" data-action="edit">Sửa</button>
                                    <button type="button" class="btn-action btn-delete" data-action="delete">Xóa</button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <!-- ================= TAB 3: QUẢN LÝ SẢN PHẨM ================= -->
    <div id="tab-products" class="tab-pane">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách sản phẩm</h2>
                <button class="btn-action btn-update" type="button" data-add="product">+ Thêm sản phẩm</button>
            </div>
            <div class="table-responsive">
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên sản phẩm</th>
                        <th>SKU</th>
                        <th>Cửa hàng</th>
                        <th>Giá</th>
                        <th>Tồn kho</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody id="productTableBody">
                    <c:forEach items="${products}" var="p">
                        <tr id="row-product-${p.id}" data-entity="product" data-id="${p.id}"
                            data-name="<c:out value='${p.name}'/>" data-sku="<c:out value='${p.sku}'/>"
                            data-shop-name="<c:out value='${p.shop_name}'/>" data-price="${p.price}" data-stock="${p.stock}"
                            data-status="<c:out value='${p.status}'/>">
                            <td><strong>#${p.id}</strong></td>
                            <td><c:out value="${p.name}"/></td>
                            <td><c:out value="${p.sku}"/></td>
                            <td><c:out value="${p.shop_name}"/></td>
                            <td style="font-weight:700; color:#ea580c;">
                                <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td>${p.stock}</td>
                            <td><span class="badge-status status-${p.status}">${p.status}</span></td>
                            <td>
                                <div style="display:inline-flex; gap:6px;">
                                    <button type="button" class="btn-action btn-update" data-action="edit">Sửa</button>
                                    <button type="button" class="btn-action btn-delete" data-action="delete">Xóa</button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>

<!-- ================= MODALS ================= -->
<!-- Modal User -->
<div id="userModal" class="modal-backdrop">
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="userModalTitle">Thêm người dùng</h3>
            <button class="modal-close" data-close-modal="userModal">&times;</button>
        </div>
        <form id="formUser" data-entity="user">
            <input type="hidden" name="action" value="saveUser">
            <input type="hidden" name="id" id="userId">
            <div class="form-group">
                <label>Họ</label>
                <input type="text" name="first_name" id="userFirstName" required>
            </div>
            <div class="form-group">
                <label>Tên</label>
                <input type="text" name="last_name" id="userLastName" required>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" id="userEmail" required>
            </div>
            <div class="form-group">
                <label>Mật khẩu (Để trống nếu giữ nguyên)</label>
                <input type="password" name="password" id="userPassword">
            </div>
            <div class="form-group">
                <label>Vai trò</label>
                <select name="role" id="userRole">
                    <option value="CUSTOMER">CUSTOMER</option>
                    <option value="SELLER">SELLER</option>
                    <option value="ADMIN">ADMIN</option>
                    <option value="MODERATOR">MODERATOR</option>
                </select>
            </div>
            <div class="form-group">
                <label>Trạng thái</label>
                <select name="status" id="userStatus">
                    <option value="ACTIVE">ACTIVE</option>
                    <option value="INACTIVE">INACTIVE</option>
                    <option value="BLOCKED">BLOCKED</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" style="background:#cbd5e1; color:#1e293b;" data-close-modal="userModal">Hủy</button>
                <button type="submit" class="btn-action btn-update">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Order -->
<div id="orderModal" class="modal-backdrop">
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="orderModalTitle">Tạo / Sửa Đơn Hàng</h3>
            <button class="modal-close" data-close-modal="orderModal">&times;</button>
        </div>
        <form id="formOrder" data-entity="order">
            <input type="hidden" name="action" value="saveOrder">
            <input type="hidden" name="id" id="orderId">
            <div class="form-group">
                <label>Mã đơn hàng</label>
                <input type="text" name="order_code" id="orderCode" placeholder="Mã tự động nếu để trống">
            </div>
            <div class="form-group">
                <label>Tên người nhận</label>
                <input type="text" name="receiver_name" id="orderReceiver" required>
            </div>
            <div class="form-group">
                <label>Email khách hàng</label>
                <input type="email" name="customer_email" id="orderEmail" required>
            </div>
            <div class="form-group">
                <label>Tổng tiền (VNĐ)</label>
                <input type="number" name="total_amount" id="orderTotal" required min="0" style="width: 100%; text-align: left;">
            </div>
            <div class="form-group">
                <label>Trạng thái</label>
                <select name="status" id="orderStatus">
                    <option value="PENDING">PENDING</option>
                    <option value="CONFIRMED">CONFIRMED</option>
                    <option value="PROCESSING">PROCESSING</option>
                    <option value="SHIPPED">SHIPPED</option>
                    <option value="COMPLETED">COMPLETED</option>
                    <option value="CANCELLED">CANCELLED</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" style="background:#cbd5e1; color:#1e293b;" data-close-modal="orderModal">Hủy</button>
                <button type="submit" class="btn-action btn-update">Lưu đơn hàng</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Product -->
<div id="productModal" class="modal-backdrop">
    <div class="modal-box">
        <div class="modal-header">
            <h3 id="productModalTitle">Thêm / Sửa Sản Phẩm</h3>
            <button class="modal-close" data-close-modal="productModal">&times;</button>
        </div>
        <form id="formProduct" data-entity="product">
            <input type="hidden" name="action" value="saveProduct">
            <input type="hidden" name="id" id="productId">
            <div class="form-group">
                <label>Tên sản phẩm</label>
                <input type="text" name="name" id="productName" required>
            </div>
            <div class="form-group">
                <label>Mã SKU</label>
                <input type="text" name="sku" id="productSku" required>
            </div>
            <div class="form-group">
                <label>Tên Cửa Hàng / Thương Hiệu</label>
                <input type="text" name="shop_name" id="productShop" required>
            </div>
            <div class="form-group">
                <label>Giá bán (VNĐ)</label>
                <input type="number" name="price" id="productPrice" required min="0" style="width: 100%; text-align: left;">
            </div>
            <div class="form-group">
                <label>Số lượng tồn kho</label>
                <input type="number" name="stock" id="productStock" required min="0" style="width: 100%; text-align: left;">
            </div>
            <div class="form-group">
                <label>Trạng thái</label>
                <select name="status" id="productStatus">
                    <option value="ACTIVE">ACTIVE</option>
                    <option value="INACTIVE">INACTIVE</option>
                </select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" style="background:#cbd5e1; color:#1e293b;" data-close-modal="productModal">Hủy</button>
                <button type="submit" class="btn-action btn-update">Lưu sản phẩm</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<!-- Du lieu khoi tao tu server cho JS ben duoi (trong JS khong duoc dung ky tu dollar + ngoac nhon) -->
<script>
    window.ADMIN_BOOT = {
        contextPath: "<c:out value='${pageContext.request.contextPath}'/>",
        stats: {
            roleStats: {<c:forEach items="${stats.roleStats}" var="r" varStatus="loop">"<c:out value='${r.key}'/>": ${r.value}${loop.last ? '' : ','}</c:forEach>},
            orderStatusStats: {<c:forEach items="${stats.orderStatusStats}" var="s" varStatus="loop">"<c:out value='${s.key}'/>": ${s.value}${loop.last ? '' : ','}</c:forEach>}
        }
    };
</script>
<script>
    /* Trang quan tri KeebHub. JS nhung trong JSP: khong dung template string kieu dollar + ngoac nhon (JSP se coi la EL); dung noi chuoi bang dau + */
    (function () {
        'use strict';

        var BOOT = window.ADMIN_BOOT || {};
        var CTX = BOOT.contextPath || '';

        var ROLE_COLORS = {
            ADMIN: '#dc2626', SELLER: '#7c3aed', CUSTOMER: '#2563eb',
            USER: '#2563eb', MODERATOR: '#f59e0b'
        };
        var STATUS_COLORS = {
            COMPLETED: '#16a34a', PROCESSING: '#2563eb', PENDING: '#f59e0b',
            SHIPPED: '#7c3aed', CANCELLED: '#dc2626', CONFIRMED: '#0891b2'
        };
        var FALLBACK_COLOR = '#64748b';

        var roleChart = null;
        var orderChart = null;

        /* ---------------------------------------------------------------- */
        /* Tiện ích                                                         */
        /* ---------------------------------------------------------------- */
        function $(id) { return document.getElementById(id); }

        function esc(v) {
            return String(v == null ? '' : v)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        function formatVND(n) {
            return new Intl.NumberFormat('vi-VN').format(Number(n) || 0) + ' ₫';
        }

        function store(key, val) { try { localStorage.setItem(key, val); } catch (e) { /* bỏ qua */ } }
        function load(key) { try { return localStorage.getItem(key); } catch (e) { return null; } }

        /* ---------------------------------------------------------------- */
        /* Tab                                                              */
        /* ---------------------------------------------------------------- */
        function switchTab(name) {
            var pane = $('tab-' + name);
            if (!pane) return;
            document.querySelectorAll('.tab-pane').forEach(function (p) { p.classList.remove('active'); });
            document.querySelectorAll('.tab-btn').forEach(function (b) {
                b.classList.toggle('active', b.getAttribute('data-tab') === name);
            });
            pane.classList.add('active');
            store('activeAdminTab', name);
        }

        function navigateToTab(name) {
            switchTab(name);
            var section = $('adminTabsSection');
            if (section) section.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        /* ---------------------------------------------------------------- */
        /* Biểu đồ TRÒN (doughnut) + chú thích                              */
        /* ---------------------------------------------------------------- */
        function drawPie(canvasId, oldChart, labels, data, colorMap, tabName) {
            var canvas = $(canvasId);
            if (!canvas) return null;
            if (oldChart) oldChart.destroy();

            var box = canvas.parentNode;
            var note = box.querySelector('.chart-note');
            if (note) note.remove();

            if (typeof Chart === 'undefined') {            // CDN bị chặn / mất mạng
                canvas.style.display = 'none';
                note = document.createElement('div');
                note.className = 'chart-note';
                note.style.cssText = 'display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:13px;text-align:center;';
                note.textContent = 'Không tải được thư viện biểu đồ (Chart.js).';
                box.appendChild(note);
                return null;
            }
            canvas.style.display = '';

            if (!labels.length) return null;

            return new Chart(canvas.getContext('2d'), {
                type: 'doughnut',                           // đổi thành 'pie' nếu muốn tròn đặc
                data: {
                    labels: labels,
                    datasets: [{
                        data: data,
                        backgroundColor: labels.map(function (l) { return colorMap[l] || FALLBACK_COLOR; }),
                        borderColor: '#ffffff',
                        borderWidth: 2,
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '58%',
                    plugins: { legend: { display: false } }
                }
            });
        }

        function drawLegend(ulId, keys, values, colorMap, prefix, unit, tabName, emptyText) {
            var ul = $(ulId);
            if (!ul) return;
            if (!keys.length) {
                ul.innerHTML = '<li><span>' + esc(emptyText) + '</span><strong>0</strong></li>';
                return;
            }
            ul.innerHTML = keys.map(function (k, i) {
                return '<li data-nav-tab="' + tabName + '" style="cursor:pointer;">' +
                    '<span><span class="legend-badge" style="background-color:' + (colorMap[k] || FALLBACK_COLOR) + ';"></span> ' +
                    prefix + ' <strong>' + esc(k) + '</strong></span>' +
                    '<strong>' + values[i] + ' ' + unit + '</strong></li>';
            }).join('');
        }

        function renderCharts(stats) {
            var roles = (stats && stats.roleStats) || {};
            var orders = (stats && stats.orderStatusStats) || {};

            var rKeys = Object.keys(roles);
            var oKeys = Object.keys(orders);
            var rVals = rKeys.map(function (k) { return roles[k]; });
            var oVals = oKeys.map(function (k) { return orders[k]; });

            roleChart = drawPie('userRoleChart', roleChart, rKeys, rVals, ROLE_COLORS, 'users');
            orderChart = drawPie('orderStatusChart', orderChart, oKeys, oVals, STATUS_COLORS, 'orders');

            drawLegend('roleLegendList', rKeys, rVals, ROLE_COLORS, 'Vai trò', 'tài khoản', 'users', 'Chưa có dữ liệu vai trò');
            drawLegend('orderStatusLegendList', oKeys, oVals, STATUS_COLORS, 'Trạng thái', 'đơn', 'orders', 'Chưa có dữ liệu đơn hàng');
        }

        function syncStats(stats) {
            if (!stats) return;
            if (stats.userCount !== undefined) $('stat-user-count').textContent = stats.userCount;
            if (stats.orderCount !== undefined) $('stat-order-count').textContent = stats.orderCount;
            if (stats.productCount !== undefined) $('stat-product-count').textContent = stats.productCount;
            if (stats.totalOrdersValue !== undefined) $('stat-total-value').textContent = formatVND(stats.totalOrdersValue);
            renderCharts(stats);
        }

        /* ---------------------------------------------------------------- */
        /* Cấu hình từng loại dữ liệu (user / order / product)              */
        /* Khóa trong `d` là camelCase, trùng với data-* trên thẻ <tr>      */
        /* ---------------------------------------------------------------- */
        var ENTITY = {
            user: {
                modal: 'userModal', form: 'formUser', tbody: 'userTableBody', rowPrefix: 'row-user-',
                addTitle: 'Thêm người dùng mới',
                editTitle: function (d) { return 'Chỉnh sửa người dùng #' + d.id; },
                deleteAction: 'deleteUser',
                fields: { id: 'userId', firstName: 'userFirstName', lastName: 'userLastName',
                    email: 'userEmail', role: 'userRole', status: 'userStatus' },
                fromForm: function (f, id) {
                    return { id: id, firstName: f.get('first_name'), lastName: f.get('last_name'),
                        email: f.get('email'), role: f.get('role'), status: f.get('status') };
                },
                cells: function (d) {
                    return '<td><strong>#' + esc(d.id) + '</strong></td>' +
                        '<td>' + esc(d.firstName) + ' ' + esc(d.lastName) + '</td>' +
                        '<td>' + esc(d.email) + '</td>' +
                        '<td><span class="badge-status role-' + esc(d.role) + '">' + esc(d.role) + '</span></td>' +
                        '<td><span class="badge-status status-' + esc(d.status) + '">' + esc(d.status) + '</span></td>';
                }
            },
            order: {
                modal: 'orderModal', form: 'formOrder', tbody: 'orderTableBody', rowPrefix: 'row-order-',
                addTitle: 'Tạo đơn hàng mới',
                editTitle: function (d) { return 'Chỉnh sửa đơn hàng #' + d.orderCode; },
                deleteAction: 'deleteOrder',
                fields: { id: 'orderId', orderCode: 'orderCode', receiverName: 'orderReceiver',
                    customerEmail: 'orderEmail', totalAmount: 'orderTotal', status: 'orderStatus' },
                fromForm: function (f, id, extra) {
                    return { id: id, orderCode: (extra && extra.orderCode) || f.get('order_code'),
                        receiverName: f.get('receiver_name'), customerEmail: f.get('customer_email'),
                        totalAmount: f.get('total_amount'), status: f.get('status') };
                },
                cells: function (d) {
                    return '<td><strong>' + esc(d.orderCode) + '</strong></td>' +
                        '<td>' + esc(d.receiverName) + '</td>' +
                        '<td>' + esc(d.customerEmail) + '</td>' +
                        '<td style="font-weight:700;color:#ea580c;">' + formatVND(d.totalAmount) + '</td>' +
                        '<td><span class="badge-status status-' + esc(d.status) + '">' + esc(d.status) + '</span></td>';
                }
            },
            product: {
                modal: 'productModal', form: 'formProduct', tbody: 'productTableBody', rowPrefix: 'row-product-',
                addTitle: 'Thêm sản phẩm mới',
                editTitle: function (d) { return 'Chỉnh sửa sản phẩm #' + d.id; },
                deleteAction: 'deleteProduct',
                fields: { id: 'productId', name: 'productName', sku: 'productSku', shopName: 'productShop',
                    price: 'productPrice', stock: 'productStock', status: 'productStatus' },
                fromForm: function (f, id) {
                    return { id: id, name: f.get('name'), sku: f.get('sku'), shopName: f.get('shop_name'),
                        price: f.get('price'), stock: f.get('stock'), status: f.get('status') };
                },
                cells: function (d) {
                    return '<td><strong>#' + esc(d.id) + '</strong></td>' +
                        '<td>' + esc(d.name) + '</td>' +
                        '<td>' + esc(d.sku) + '</td>' +
                        '<td>' + esc(d.shopName) + '</td>' +
                        '<td style="font-weight:700;color:#ea580c;">' + formatVND(d.price) + '</td>' +
                        '<td>' + esc(d.stock) + '</td>' +
                        '<td><span class="badge-status status-' + esc(d.status) + '">' + esc(d.status) + '</span></td>';
                }
            }
        };

        var ACTION_CELL =
            '<td><div style="display:inline-flex;gap:6px;">' +
            '<button type="button" class="btn-action btn-update" data-action="edit">Sửa</button>' +
            '<button type="button" class="btn-action btn-delete" data-action="delete">Xóa</button>' +
            '</div></td>';

        // đọc dữ liệu của 1 dòng từ data-* (JSP in sẵn / JS tự tạo đều dùng chung)
        function rowData(tr) {
            var d = {};
            Object.keys(tr.dataset).forEach(function (k) { d[k] = tr.dataset[k]; });
            return d;
        }

        function upsertRow(type, d) {
            var cfg = ENTITY[type];
            var tr = $(cfg.rowPrefix + d.id);
            var isNew = !tr;
            if (isNew) {
                tr = document.createElement('tr');
                tr.id = cfg.rowPrefix + d.id;
            }
            Object.keys(d).forEach(function (k) { tr.dataset[k] = d[k] == null ? '' : d[k]; });
            tr.dataset.entity = type;                       // để nút Sửa/Xóa của dòng mới nhận ra loại dữ liệu
            tr.innerHTML = cfg.cells(d) + ACTION_CELL;
            if (isNew) {
                var body = $(cfg.tbody);
                body.insertBefore(tr, body.firstChild);     // bản ghi mới lên đầu (server cũng ORDER BY id DESC)
            }
        }

        /* ---------------------------------------------------------------- */
        /* Modal                                                            */
        /* ---------------------------------------------------------------- */
        function openModal(id) { $(id).style.display = 'flex'; }
        function closeModal(id) { $(id).style.display = 'none'; }

        function openAdd(type) {
            var cfg = ENTITY[type];
            $(cfg.form).reset();
            $(cfg.fields.id).value = '';
            document.querySelector('#' + cfg.modal + ' .modal-header h3').textContent = cfg.addTitle;
            openModal(cfg.modal);
        }

        function openEdit(type, tr) {
            var cfg = ENTITY[type];
            var d = rowData(tr);
            $(cfg.form).reset();
            Object.keys(cfg.fields).forEach(function (k) {
                var el = $(cfg.fields[k]);
                if (!el) return;
                var v = d[k] == null ? '' : d[k];
                if (el.tagName === 'SELECT' && v !== '') {
                    var has = Array.prototype.some.call(el.options, function (o) { return o.value === v; });
                    if (!has) el.add(new Option(v, v));        // giá trị lạ trong DB: giữ nguyên, không bị mất khi lưu
                }
                el.value = v;
            });
            document.querySelector('#' + cfg.modal + ' .modal-header h3').textContent = cfg.editTitle(d);
            openModal(cfg.modal);
        }

        /* ---------------------------------------------------------------- */
        /* Gọi server                                                       */
        /* ---------------------------------------------------------------- */
        function post(params) {
            return fetch(CTX + '/admin', {
                method: 'POST',
                credentials: 'same-origin',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: params
            }).then(function (res) {
                return res.text().then(function (text) {
                    try { return JSON.parse(text); }
                    catch (e) {
                        // thường là bị đá về trang login / trang lỗi HTML
                        throw new Error('Server không trả JSON (HTTP ' + res.status + '). Hãy đăng nhập lại bằng tài khoản ADMIN.');
                    }
                });
            });
        }

        function submitForm(form) {
            var type = form.getAttribute('data-entity');
            var cfg = ENTITY[type];
            var f = new FormData(form);
            var btn = form.querySelector('button[type="submit"]');
            if (btn) btn.disabled = true;

            post(new URLSearchParams(f)).then(function (result) {
                if (!result.success) { alert('Lỗi: ' + result.message); return; }
                closeModal(cfg.modal);
                var id = result.id || f.get('id');
                upsertRow(type, cfg.fromForm(f, id, result));
                syncStats(result.stats);
            }).catch(function (err) {
                console.error(err);
                alert(err.message || 'Có lỗi xảy ra khi xử lý dữ liệu!');
            }).then(function () { if (btn) btn.disabled = false; });
        }

        function deleteRow(type, tr) {
            var cfg = ENTITY[type];
            var id = tr.dataset.id;
            if (!id) { alert('Không xác định được ID dòng cần xóa.'); return; }
            if (!confirm('Bạn có chắc chắn muốn xóa mục này?')) return;

            var p = new URLSearchParams();
            p.append('action', cfg.deleteAction);
            p.append('id', id);

            post(p).then(function (result) {
                if (!result.success) { alert('Lỗi xóa: ' + result.message); return; }
                tr.style.transition = 'opacity 0.3s ease';
                tr.style.opacity = '0';
                setTimeout(function () { tr.remove(); }, 300);
                syncStats(result.stats);
            }).catch(function (err) {
                console.error(err);
                alert(err.message || 'Không thể thực hiện câu lệnh xóa!');
            });
        }

        /* ---------------------------------------------------------------- */
        /* Gắn sự kiện (event delegation: dòng mới thêm bằng JS cũng chạy)  */
        /* ---------------------------------------------------------------- */
        document.addEventListener('click', function (e) {
            var t = e.target;

            var nav = t.closest('[data-nav-tab]');
            if (nav) { navigateToTab(nav.getAttribute('data-nav-tab')); return; }

            var tabBtn = t.closest('[data-switch-tab]');
            if (tabBtn) { switchTab(tabBtn.getAttribute('data-switch-tab')); return; }

            var add = t.closest('[data-add]');
            if (add) { openAdd(add.getAttribute('data-add')); return; }

            var close = t.closest('[data-close-modal]');
            if (close) { closeModal(close.getAttribute('data-close-modal')); return; }

            var actBtn = t.closest('button[data-action]');
            if (actBtn) {
                var tr = actBtn.closest('tr[data-entity]');
                if (!tr) return;
                var type = tr.getAttribute('data-entity');
                if (actBtn.getAttribute('data-action') === 'edit') openEdit(type, tr);
                else deleteRow(type, tr);
                return;
            }

            // bấm vào nền mờ để đóng modal
            if (t.classList && t.classList.contains('modal-backdrop')) closeModal(t.id);
        });

        document.addEventListener('submit', function (e) {
            var form = e.target;
            if (form.getAttribute && form.getAttribute('data-entity')) {
                e.preventDefault();
                submitForm(form);
            }
        });

        var started = false;
        function init() {
            if (started) return;
            started = true;
            var saved = load('activeAdminTab');
            if (saved) switchTab(saved);
            renderCharts(BOOT.stats || {});
        }

        if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
        else init();
    })();
</script>
</body>
</html>