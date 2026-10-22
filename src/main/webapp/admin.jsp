<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản trị KeebHub</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/admin.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body>
<div class="admin-shell">
    <aside class="sidebar">
        <a class="brand" href="${pageContext.request.contextPath}/admin" aria-label="KeebHub Admin">
            <span class="brand-mark">K</span>
            <span><strong>KeebHub</strong><small>TRUNG TÂM QUẢN TRỊ</small></span>
        </a>
        <div class="sidebar-label">QUẢN LÝ</div>
        <nav id="sidebar-nav" class="sidebar-nav">
            <button type="button" class="nav-item active" data-page="dashboard"><span class="nav-icon">▦</span>Tổng quan</button>
            <button type="button" class="nav-item" data-page="analytics"><span class="nav-icon">📊</span>Thống kê biểu đồ</button>
            <button type="button" class="nav-item" data-page="users"><span class="nav-icon">♙</span>Người dùng</button>
            <button type="button" class="nav-item" data-page="products"><span class="nav-icon">⌨</span>Sản phẩm</button>
            <button type="button" class="nav-item" data-page="orders"><span class="nav-icon">▤</span>Quản lý đơn hàng</button>
            <button type="button" class="nav-item" data-page="order-status"><span class="nav-icon">✓</span>Cập nhật trạng thái đơn hàng</button>
        </nav>
        <div class="sidebar-bottom">
            <div class="admin-avatar">AD</div>
            <div class="admin-account">
                <strong><c:out value="${sessionScope.userFullName != null ? sessionScope.userFullName: 'Quản trị viên'}"/></strong>
                <small>Quản trị</small>
            </div>
            <a class="sidebar-logout" href="${pageContext.request.contextPath}/logout" title="Đăng xuất" aria-label="Đăng xuất">↗</a>
        </div>
    </aside>

    <main class="main-panel">
        <header class="topbar">
            <div>
                <div class="eyebrow">KEEBHUB / ADMIN</div>
                <h1 id="page-title">Tổng quan</h1>
            </div>
            <div class="topbar-actions">
                <label class="search-field" for="quick-search"><span>⌕</span><input id="quick-search" type="search" placeholder="Tìm kiếm dữ liệu..." autocomplete="off"></label>

                <div class="admin-profile-menu" id="admin-profile-menu">
                    <div class="top-avatar" title="Quản trị viên">AD</div>
                    <div class="profile-dropdown">
                        <div class="dropdown-header">
                            <strong><c:out value="${sessionScope.userFullName != null ? sessionScope.userFullName: 'Quản trị viên'}"/></strong>
                            <small>Quản trị viên</small>
                        </div>
                        <hr>
                        <a href="${pageContext.request.contextPath}/" class="dropdown-item">🏠 Trở về trang chủ</a>
                        <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">↗ Đăng xuất</a>
                    </div>
                </div>
            </div>
        </header>
        <section id="main-content" class="content-area" aria-live="polite"></section>
        <footer class="page-footer">KeebHub Admin <span>·</span> Quản lý người dùng, sản phẩm và đơn hàng</footer>
    </main>
</div>

<div id="toast-container" class="toast-container" aria-live="polite"></div>
<div id="modal-container"></div>

<!-- Nhúng JSON an toàn chống lỗi cú pháp & XSS -->
<script id="data-users" type="application/json"><c:out value="${usersJson}" default="[]" escapeXml="false"/></script>
<script id="data-orders" type="application/json"><c:out value="${ordersJson}" default="[]" escapeXml="false"/></script>
<script id="data-products" type="application/json"><c:out value="${productsJson}" default="[]" escapeXml="false"/></script>
<script id="data-shops" type="application/json"><c:out value="${shopsJson}" default="[]" escapeXml="false"/></script>
<script id="data-categories" type="application/json"><c:out value="${categoriesJson}" default="[]" escapeXml="false"/></script>
<script id="data-stats" type="application/json"><c:out value="${statsJson}" default="{}" escapeXml="false"/></script>
<script id="data-revenue-stats" type="application/json"><c:out value="${revenueStatsJson}" default="{}" escapeXml="false"/></script>

<script>
    (function () {
        'use strict';
        function parseJson(id) {
            try {
                var el = document.getElementById(id);
                var isObj = (id === 'data-stats' || id === 'data-revenue-stats');
                return el ? JSON.parse(el.textContent) : (isObj ? {} : []);
            } catch (e) {
                var isObj = (id === 'data-stats' || id === 'data-revenue-stats');
                return isObj ? {} : [];
            }
        }

        var $ = function (id) { return document.getElementById(id); };
        var S = {
            page: 'dashboard',
            users: parseJson('data-users'),
            orders: parseJson('data-orders'),
            products: parseJson('data-products'),
            shops: parseJson('data-shops'),
            categories: parseJson('data-categories'),
            stats: parseJson('data-stats'),
            revenueStats: parseJson('data-revenue-stats'),
            analyticsMetric: 'revenue'
        };
        var analyticsChartInstance = null;
        var orderPieChartInstance = null;
        var ctxPath = "<c:out value='${pageContext.request.contextPath}'/>";

        var ORDER_STATUSES = ['PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'SHIPPED', 'COMPLETED', 'CANCELLED'];
        var USER_ROLES = ['CUSTOMER', 'USER', 'SELLER', 'ADMIN', 'MODERATOR'];
        var USER_STATUSES = ['ACTIVE', 'INACTIVE', 'BLOCKED'];
        var PRODUCT_STATUSES = ['ACTIVE', 'INACTIVE'];
        var TITLES = {
            dashboard: ['Tổng quan', 'Số liệu tổng hợp cơ sở dữ liệu.'],
            analytics: ['Thống kê & Biểu đồ', 'Biểu đồ cột doanh thu và biểu đồ tròn tỷ lệ trạng thái đơn hàng.'],
            users: ['Quản lý người dùng', 'Thêm, cập nhật vai trò và trạng thái tài khoản.'],
            products: ['Quản lý sản phẩm', 'Quản lý thông tin, cửa hàng, danh mục và tồn kho.'],
            orders: ['Quản lý đơn hàng', 'Chỉnh sửa thông tin đơn hàng và quản lý danh sách.'],
            'order-status': ['Cập nhật trạng thái đơn hàng', 'Xác nhận, xử lý, giao hàng, hoàn thành hoặc hủy đơn hàng.']
        };

        function esc(value) {
            return String(value == null ? '': value).replace(/[&<>"']/g, function (ch) {
                return {'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;'}[ch];
            });
        }
        function money(value) { return (Number(value) || 0).toLocaleString('vi-VN') + ' ₫'; }
        function nice(value) { return String(value || '').replace(/_/g, ' ').toLowerCase().replace(/(^|\s)\S/g, function (m) { return m.toUpperCase(); }); }
        function byId(list, id) { return list.find(function (item) { return String(item.id) === String(id); }); }
        function opts(values) {
            return values.map(function (value) {
                if (typeof value === 'string' || typeof value === 'number') return {value: String(value), label: String(value)};
                return value;
            });
        }
        function initials(firstName, lastName) {
            var f = (firstName || '').trim().charAt(0) || 'K';
            var l = (lastName || '').trim().charAt(0) || 'H';
            return (f + l).toUpperCase();
        }
        function userOptions(selected) {
            return S.users.filter(function (u) { return u.status === 'ACTIVE' || String(u.email) === String(selected); })
                .map(function (u) { return {value: u.email, label: (u.first_name + ' ' + u.last_name + ' — ' + u.email)}; });
        }
        function productOptions(selected) {
            return S.products.filter(function (p) { return p.status === 'ACTIVE' || String(p.id) === String(selected); })
                .map(function (p) { return {value: p.id, label: p.name + ' · ' + money(p.price)}; });
        }
        function statusPill(value) {
            var state = String(value || '').toLowerCase();
            var css = 'status-neutral';
            if (['active', 'completed', 'confirmed', 'shipped'].indexOf(state) >= 0) css = 'status-success';
            else if (['pending', 'processing', 'shipping'].indexOf(state) >= 0) css = 'status-warning';
            else if (['inactive', 'blocked', 'cancelled'].indexOf(state) >= 0) css = 'status-danger';
            return '<span class="status-pill ' + css + '">' + esc((typeof ORDER_STATUS_LABELS !== 'undefined' && ORDER_STATUS_LABELS[value]) || nice(value)) + '</span>';
        }
        function emptyRow(columns, message) {
            return '<tr><td colspan="' + columns + '" class="empty-cell"><span class="empty-icon">⌕</span><strong>' + esc(message) + '</strong><small>Thử thay đổi từ khóa hoặc tạo bản ghi mới.</small></td></tr>';
        }
        function toast(message, error) {
            var el = document.createElement('div');
            el.className = 'toast-message' + (error ? ' toast-error': '');
            el.textContent = message;
            $('toast-container').appendChild(el);
            window.setTimeout(function () { el.remove(); }, 3800);
        }
        function post(data) {
            return fetch(ctxPath + '/admin', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                body: new URLSearchParams(data)
            }).then(function (response) {
                return response.text().then(function (text) {
                    var result;
                    try { result = JSON.parse(text); }
                    catch (e) { throw new Error('Máy chủ không trả về dữ liệu hợp lệ. Hãy đăng nhập lại.'); }
                    if (!response.ok && result.success !== false) throw new Error('Yêu cầu thất bại (HTTP ' + response.status + ').');
                    return result;
                });
            });
        }
        function call(data, onSuccess) {
            return post(data).then(function (result) {
                if (!result.success) {
                    toast(result.message || 'Không thể thực hiện thao tác.', true);
                    return false;
                }
                if (result.stats) S.stats = result.stats;
                if (onSuccess) onSuccess(result);
                toast(result.message || 'Đã lưu dữ liệu.');
                renderPage();
                return true;
            }).catch(function (error) {
                toast(error.message || 'Không thể kết nối máy chủ.', true);
                return false;
            });
        }
        function filter(list, fields) {
            var query = ($('quick-search').value || '').trim().toLocaleLowerCase('vi-VN');
            if (!query || S.page === 'dashboard') return list;
            return list.filter(function (item) {
                if (item.first_name || item.last_name) {
                    var fullName = ((item.first_name || '') + ' ' + (item.last_name || '')).trim();
                    if (fullName.toLocaleLowerCase('vi-VN').indexOf(query) >= 0) return true;
                }
                return fields.some(function (field) {
                    return String(item[field] == null ? '': item[field]).toLocaleLowerCase('vi-VN').indexOf(query) >= 0;
                });
            });
        }
        function kpi(icon, title, value, hint, tone, pageTarget) {
            var pageAttr = pageTarget ? ' data-page="' + pageTarget + '"' : '';
            return '<article class="stat-card"' + pageAttr + '><div class="stat-top"><span class="stat-icon ' + tone + '">' + icon + '</span><span class="stat-period"></span></div>' +
                '<div class="stat-label">' + esc(title) + '</div><div class="stat-value">' + esc(value) + '</div><div class="stat-hint">' + esc(hint) + '</div></article>';
        }
        function toolbar(title, note, buttonId, buttonLabel) {
            return '<div class="section-heading"><div><h2>' + esc(title) + '</h2><p>' + esc(note) + '</p></div>' +
                '<button type="button" class="btn btn-primary" id="' + buttonId + '"><span>＋</span>' + esc(buttonLabel) + '</button></div>';
        }

        function renderDashboard() {
            var st = S.stats || {};
            var recent = S.orders.slice(0, 5).map(function (o) {
                return '<tr><td><strong class="mono">' + esc(o.order_code) + '</strong><small class="cell-sub">' + esc(o.created_at || '') + '</small></td>' +
                    '<td><strong>' + esc(o.receiver_name) + '</strong><small class="cell-sub">' + esc(o.customer_email) + '</small></td>' +
                    '<td class="money-cell">' + money(o.total_amount) + '</td><td>' + statusPill(o.order_status) + '</td></tr>';
            }).join('');
            var roleStats = st.roleStats || {};
            var roleRows = Object.keys(roleStats).map(function (role) {
                return '<div class="summary-row"><span>' + esc(nice(role)) + '</span><strong>' + esc(roleStats[role]) + '</strong><div class="mini-track"><span style="width:' +
                    Math.min(100, Math.round((Number(roleStats[role]) / Math.max(1, Number(st.userCount))) * 100)) + '%"></span></div></div>';
            }).join('') || '<div class="empty-note">Chưa có dữ liệu người dùng.</div>';
            var orderStats = st.orderStatusStats || {};
            var statusRows = Object.keys(orderStats).map(function (status) {
                return '<div class="summary-row"><span>' + esc(nice(status)) + '</span><strong>' + esc(orderStats[status]) + '</strong></div>';
            }).join('') || '<div class="empty-note">Chưa có dữ liệu đơn hàng.</div>';

            return '<div class="welcome-row"><div><div class="eyebrow">WORKSPACE</div><h2>Chào mừng trở lại 👋</h2></div><div style="display:flex;align-items:center;gap:10px;"><button type="button" class="btn btn-primary btn-small" data-page="analytics" style="padding:6px 14px;font-size:12px;font-weight:700;"><span>📊</span> Biểu đồ doanh thu</button><span class="live-tag"><i></i> connected</span></div></div>' +
                '<div class="stat-grid">' +
                kpi('♙', 'Người dùng', st.userCount || 0, 'Tài khoản', 'icon-blue', 'users') +
                kpi('▤', 'Đơn hàng', st.orderCount || 0, 'Tổng số đơn hàng', 'icon-violet', 'orders') +
                kpi('⌨', 'Sản phẩm', st.productCount || 0, 'Bản ghi sản phẩm', 'icon-orange', 'products') +
                kpi('₫', 'Giá trị đơn không hủy', money(st.totalOrdersValue || 0), 'Cộng các đơn không bị hủy', 'icon-green') +
                '</div><div class="dashboard-grid"><section class="panel"><div class="panel-heading"><div><h3>Đơn hàng gần đây</h3><p>Các đơn mới nhất trong cơ sở dữ liệu</p></div><button type="button" class="text-action" data-page="orders">Xem tất cả →</button></div>' +
                '<div class="table-scroll"><table><thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Tổng tiền</th><th>Trạng thái</th></tr></thead><tbody>' + (recent || emptyRow(4, 'Chưa có đơn hàng')) + '</tbody></table></div></section>' +
                '<div class="side-panels"><section class="panel"><div class="panel-heading"><div><h3>Vai trò người dùng</h3><p>Phân bố tài khoản</p></div></div><div class="summary-list">' + roleRows + '</div></section>' +
                '<section class="panel"><div class="panel-heading"><div><h3>Trạng thái đơn hàng</h3><p>Tổng số theo trạng thái</p></div></div><div class="summary-list">' + statusRows + '</div></section></div></div>';
        }

        function renderUsers() {
            var users = filter(S.users, ['first_name', 'last_name', 'email', 'role', 'status', 'id']);
            var rows = users.map(function (u) {
                var avatarText = initials(u.first_name, u.last_name);
                return '<tr><td class="id-cell">#' + esc(u.id) + '</td><td><div class="person-cell"><span class="person-avatar">' + esc(avatarText) + '</span><span><strong>' + esc(u.first_name + ' ' + u.last_name) + '</strong><small class="cell-sub">' + esc(u.email) + '</small></span></div></td>' +
                    '<td><span class="role-pill">' + esc(nice(u.role)) + '</span></td><td>' + statusPill(u.status) + '</td><td><div class="action-group"><button type="button" class="btn btn-small btn-light" data-act="edit-user" data-id="' + esc(u.id) + '">Sửa</button><button type="button" class="btn btn-small btn-danger-light" data-act="delete-user" data-id="' + esc(u.id) + '">Xóa</button></div></td></tr>';
            }).join('');
            return toolbar('Danh sách người dùng', S.users.length + ' tài khoản.', 'add-user', 'Thêm người dùng') +
                '<div class="table-card"><div class="table-scroll"><table><thead><tr><th>ID</th><th>Người dùng</th><th>Vai trò</th><th>Trạng thái</th><th class="action-col">Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(5, 'Không tìm thấy người dùng')) + '</tbody></table></div><div class="table-footer"><span>Đang hiển thị ' + users.length + ' / ' + S.users.length + ' người dùng</span><span>Email phải là duy nhất</span></div></div>';
        }

        function renderProducts() {
            var products = filter(S.products, ['name', 'sku', 'shop_name', 'category_name', 'status', 'id']);
            var rows = products.map(function (p) {
                return '<tr><td class="id-cell">#' + esc(p.id) + '</td><td><div class="product-cell"><span class="product-icon">⌨</span><span><strong>' + esc(p.name) + '</strong><small class="cell-sub">SKU: ' + esc(p.sku || '—') + '</small></span></div></td>' +
                    '<td>' + esc(p.shop_name) + '</td><td>' + esc(p.category_name) + '</td><td class="money-cell">' + money(p.price) + '</td><td><span class="stock-value ' + (Number(p.stock) <= 5 ? 'stock-low': '') + '">' + esc(p.stock) + '</span></td><td>' + statusPill(p.status) + '</td>' +
                    '<td><div class="action-group"><button type="button" class="btn btn-small btn-light" data-act="edit-product" data-id="' + esc(p.id) + '">Sửa</button><button type="button" class="btn btn-small btn-danger-light" data-act="delete-product" data-id="' + esc(p.id) + '">Xóa</button></div></td></tr>';
            }).join('');
            return toolbar('Danh sách sản phẩm', S.products.length + ' sản phẩm, bao gồm cả sản phẩm ngừng bán.', 'add-product', 'Thêm sản phẩm') +
                '<div class="table-card"><div class="table-scroll"><table class="product-table"><thead><tr><th>ID</th><th>Sản phẩm</th><th>Cửa hàng</th><th>Danh mục</th><th>Giá bán</th><th>Tồn kho</th><th>Trạng thái</th><th class="action-col">Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(8, 'Không tìm thấy sản phẩm')) + '</tbody></table></div><div class="table-footer"><span>Đang hiển thị ' + products.length + ' / ' + S.products.length + ' sản phẩm</span><span>Sản phẩm đã có đơn hàng sẽ được lưu trữ khi xóa</span></div></div>';
        }

        function renderOrders() {
            var orders = filter(S.orders, ['order_code', 'receiver_name', 'receiver_phone', 'shipping_address', 'customer_email', 'order_status', 'product_name', 'id']);
            var rows = orders.map(function (o) {
                return '<tr><td><strong class="mono">' + esc(o.order_code) + '</strong><small class="cell-sub">ID #' + esc(o.id) + '</small></td>' +
                    '<td><strong>' + esc(o.receiver_name) + '</strong><small class="cell-sub">' + esc(o.customer_email) + '</small></td>' +
                    '<td><strong>' + esc(o.product_name || 'Sản phẩm') + '</strong><small class="cell-sub">' + esc(o.receiver_phone || '') + '</small></td>' +
                    '<td class="money-cell">' + money(o.total_amount) + '</td><td>' + statusPill(o.order_status) + '</td>' +
                    '<td><div class="action-group"><button type="button" class="btn btn-small btn-light" data-act="edit-order" data-id="' + esc(o.id) + '">Sửa</button><button type="button" class="btn btn-small btn-danger-light" data-act="delete-order" data-id="' + esc(o.id) + '">Xóa</button></div></td></tr>';
            }).join('');
            return toolbar('Danh sách đơn hàng', S.orders.length + ' đơn hàng.', 'add-order', 'Tạo đơn hàng') +
                '<div class="table-card"><div class="table-scroll"><table><thead><tr><th>Mã đơn</th><th>Người nhận</th><th>Sản phẩm</th><th>Tổng tiền</th><th>Trạng thái</th><th class="action-col">Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(6, 'Không tìm thấy đơn hàng')) + '</tbody></table></div><div class="table-footer"><span>Đang hiển thị ' + orders.length + ' / ' + S.orders.length + ' đơn hàng</span><span>Đơn mới sẽ tạo chi tiết đơn hàng</span></div></div>';
        }

        function renderOrderStatuses() {
            var orders = filter(S.orders, ['order_code', 'receiver_name', 'customer_email', 'order_status', 'id']);
            var rows = orders.map(function(o) {
                var allowed = allowedOrderStatuses(o.order_status);
                return '<tr><td class="id-cell">' + esc(o.order_code) + '</td>' +
                    '<td><strong>' + esc(o.receiver_name) + '</strong><small class="cell-sub">' + esc(o.customer_email) + '</small></td>' +
                    '<td class="money-cell">' + money(o.total_amount) + '</td><td>' + statusPill(o.order_status) + '</td>' +
                    '<td><button type="button" class="btn btn-small btn-light" data-act="update-order-status" data-id="' + esc(o.id) + '"' +
                    (allowed.length ? '' : ' disabled') + '>' + (allowed.length ? 'Cập nhật' : 'Đã kết thúc') + '</button></td></tr>';
            }).join('');
            return '<div class="table-card"><div class="table-scroll"><table><thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Tổng tiền</th><th>Trạng thái hiện tại</th><th>Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(5, 'Không tìm thấy đơn hàng')) + '</tbody></table></div></div>';
        }

        var ORDER_STATUS_LABELS = {
            PENDING:'Chờ xác nhận', CONFIRMED:'Đã xác nhận', PROCESSING:'Đang xử lý',
            SHIPPING:'Đang giao hàng', SHIPPED:'Đã giao hàng', COMPLETED:'Hoàn thành',
            CANCELLED:'Đã hủy'
        };
        function allowedOrderStatuses(status) {
            // Các trạng thái đã kết thúc không được thay đổi để tránh sai lệch tồn kho.
            if (status === 'COMPLETED' || status === 'CANCELLED') return [];
            var currentIndex = ORDER_STATUSES.indexOf(status);
            return ORDER_STATUSES.filter(function (next, i) {
                return next === 'CANCELLED' || (i > currentIndex && i < ORDER_STATUSES.length - 1);
            });
        }

        function renderAnalytics() {
            var rev = S.revenueStats || {};
            var fromDate = rev.fromDate || '';
            var toDate = rev.toDate || '';
            var totalRev = Number(rev.totalRevenue) || 0;
            var totalOrd = Number(rev.totalOrders) || 0;
            var avgRev = Number(rev.avgRevenuePerDay) || 0;
            var cancelOrd = Number(rev.cancelledOrders) || 0;
            var dailyList = rev.dailyList || [];

            var rows = dailyList.map(function(item) {
                var rAmount = Number(item.revenue) || 0;
                var oCount = Number(item.orders) || 0;
                var cCount = Number(item.cancelled) || 0;
                var percent = totalRev > 0 ? ((rAmount / totalRev) * 100).toFixed(1) : '0.0';
                return '<tr>' +
                    '<td class="mono"><strong>' + esc(item.date) + '</strong></td>' +
                    '<td class="money-cell"><strong>' + money(rAmount) + '</strong></td>' +
                    '<td><span class="status-pill status-success">' + oCount + ' đơn</span></td>' +
                    '<td>' + (cCount > 0 ? '<span class="status-pill status-danger">' + cCount + ' đơn</span>' : '<span class="status-pill status-neutral">0</span>') + '</td>' +
                    '<td><div style="display:flex;align-items:center;gap:8px;"><span>' + percent + '%</span><div class="mini-track" style="flex:1;max-width:80px;"><span style="width:' + percent + '%"></span></div></div></td>' +
                    '</tr>';
            }).join('');

            var emptyMsg = '<div class="chart-empty-state"><span class="icon">📅</span><p>Không có dữ liệu đơn hàng trong khoảng thời gian này.</p><small>Hãy chọn khoảng thời gian rộng hơn để xem thống kê.</small></div>';

            return '<div class="analytics-filter-card">' +
                '<div class="filter-header">' +
                '<div>' +
                '<h3 style="margin:0 0 4px;font-size:15px;font-weight:700;color:#0f172a;">Khoảng thời gian thống kê</h3>' +
                '<p style="margin:0;font-size:12px;color:#64748b;">Chọn khoảng ngày để lọc dữ liệu doanh thu và số lượng đơn hàng</p>' +
                '</div>' +
                '<div class="quick-filter-pills">' +
                '<button type="button" class="pill-btn" data-preset="7d">7 ngày qua</button>' +
                '<button type="button" class="pill-btn" data-preset="30d">30 ngày qua</button>' +
                '<button type="button" class="pill-btn" data-preset="this_month">Tháng này</button>' +
                '<button type="button" class="pill-btn" data-preset="all">Tất cả</button>' +
                '</div>' +
                '</div>' +
                '<form id="analytics-filter-form" class="filter-inputs-row" style="margin-top:14px;">' +
                '<div class="date-input-group">' +
                '<span>Từ ngày:</span>' +
                '<input type="date" id="stats-from-date" name="from_date" value="' + esc(fromDate) + '" required>' +
                '</div>' +
                '<div class="date-input-group">' +
                '<span>Đến ngày:</span>' +
                '<input type="date" id="stats-to-date" name="to_date" value="' + esc(toDate) + '" required>' +
                '</div>' +
                '<button type="submit" class="btn btn-primary" id="btn-apply-filter" style="padding:7px 18px;font-size:13px;">' +
                '<span>⚡</span> Áp dụng bộ lọc' +
                '</button>' +
                '</form>' +
                '</div>' +

                '<div class="stat-grid" style="margin-bottom:20px;">' +
                kpi('₫', 'Tổng doanh thu', money(totalRev), 'Doanh thu từ các đơn hoàn thành/đang xử lý', 'icon-green') +
                kpi('▤', 'Đơn thành công', totalOrd, 'Tổng đơn hàng đã ghi nhận', 'icon-blue') +
                kpi('📈', 'Doanh thu TB / ngày', money(avgRev), 'Trung bình mỗi ngày trong chu kỳ', 'icon-violet') +
                kpi('✕', 'Đơn bị hủy', cancelOrd, 'Số đơn bị hủy trong khoảng thời gian', 'icon-orange') +
                '</div>' +

                '<div class="chart-panel">' +
                '<div class="chart-panel-head">' +
                '<div>' +
                '<h3>Biểu đồ cột thống kê</h3>' +
                '<p>Dữ liệu từ <strong>' + (fromDate || '...') + '</strong> đến <strong>' + (toDate || '...') + '</strong></p>' +
                '</div>' +
                '<div class="chart-metric-switch">' +
                '<button type="button" class="chart-metric-btn ' + (S.analyticsMetric === 'revenue' ? 'active' : '') + '" data-metric="revenue">Doanh thu (₫)</button>' +
                '<button type="button" class="chart-metric-btn ' + (S.analyticsMetric === 'orders' ? 'active' : '') + '" data-metric="orders">Số lượng đơn hàng</button>' +
                '</div>' +
                '</div>' +
                '<div class="chart-canvas-wrap">' +
                (dailyList.length === 0 ? emptyMsg : '<canvas id="analyticsBarChart"></canvas>') +
                '</div>' +
                '</div>' +

                '<div class="chart-panel pie-panel">' +
                '<div class="chart-panel-head"><div><h3>Biểu đồ tròn trạng thái đơn hàng</h3>' +
                '<p>Tỷ lệ đơn hàng theo trạng thái từ <strong>' + esc(fromDate) + '</strong> đến <strong>' + esc(toDate) + '</strong></p></div></div>' +
                '<div class="pie-chart-layout">' +
                '<div class="pie-canvas-wrap"><canvas id="orderStatusPieChart" aria-label="Biểu đồ tròn tỷ lệ trạng thái đơn hàng" role="img"></canvas></div>' +
                '<div id="order-pie-legend" class="pie-legend"></div>' +
                '</div>' +
                '</div>' +

                '<div class="table-card">' +
                '<div class="section-heading" style="padding:16px 20px 12px;margin:0;border-bottom:1px solid var(--line);">' +
                '<div><h3 style="margin:0;font-size:15px;font-weight:700;">Chi tiết doanh thu theo từng ngày</h3><p style="margin:2px 0 0;font-size:12px;color:#64748b;">Số liệu chi tiết tương ứng với biểu đồ cột bên trên</p></div>' +
                '</div>' +
                '<div class="table-scroll">' +
                '<table>' +
                '<thead><tr><th>Ngày</th><th>Doanh thu</th><th>Đơn thành công</th><th>Đơn hủy</th><th>Tỷ trọng chu kỳ</th></tr></thead>' +
                '<tbody>' + (rows || emptyRow(5, 'Không có số liệu trong khoảng thời gian này')) + '</tbody>' +
                '</table>' +
                '</div>' +
                '</div>';
        }

        function afterRenderAnalytics() {
            var form = $('analytics-filter-form');
            if (form) {
                form.onsubmit = function(e) {
                    e.preventDefault();
                    var from = $('stats-from-date').value;
                    var to = $('stats-to-date').value;
                    if (from && to && from > to) {
                        toast('Ngày bắt đầu không được lớn hơn ngày kết thúc!', true);
                        return;
                    }
                    fetchRevenueStats(from, to);
                };
            }

            Array.prototype.forEach.call(document.querySelectorAll('.pill-btn[data-preset]'), function(btn) {
                btn.onclick = function() {
                    var preset = btn.dataset.preset;
                    var now = new Date();
                    var toStr = now.toISOString().slice(0, 10);
                    var fromStr = '';

                    if (preset === '7d') {
                        var d7 = new Date();
                        d7.setDate(now.getDate() - 6);
                        fromStr = d7.toISOString().slice(0, 10);
                    } else if (preset === '30d') {
                        var d30 = new Date();
                        d30.setDate(now.getDate() - 29);
                        fromStr = d30.toISOString().slice(0, 10);
                    } else if (preset === 'this_month') {
                        var dMonth = new Date(now.getFullYear(), now.getMonth(), 1);
                        fromStr = dMonth.toISOString().slice(0, 10);
                    } else if (preset === 'all') {
                        fromStr = '';
                        toStr = '';
                    }

                    fetchRevenueStats(fromStr, toStr);
                };
            });

            Array.prototype.forEach.call(document.querySelectorAll('.chart-metric-btn[data-metric]'), function(btn) {
                btn.onclick = function() {
                    S.analyticsMetric = btn.dataset.metric;
                    renderPage();
                };
            });

            drawAnalyticsChart();
            drawOrderPieChart();
        }

        function drawOrderPieChart() {
            if (orderPieChartInstance) {
                orderPieChartInstance.destroy();
                orderPieChartInstance = null;
            }
            var canvas = $('orderStatusPieChart');
            var legend = $('order-pie-legend');
            if (!canvas || !legend) return;
            var breakdown = (S.revenueStats || {}).orderStatusBreakdown || {};
            var names = {
                PENDING:'Chờ xác nhận', CONFIRMED:'Đã xác nhận', PROCESSING:'Đang xử lý',
                SHIPPING:'Đang giao', SHIPPED:'Đã giao', COMPLETED:'Hoàn thành',
                UNKNOWN:'Chưa xác định'
            };
            var colors = {
                PENDING:'#f59e0b', CONFIRMED:'#3b82f6', PROCESSING:'#8b5cf6',
                SHIPPING:'#06b6d4', SHIPPED:'#14b8a6', COMPLETED:'#10b981',
                UNKNOWN:'#94a3b8'
            };
            var keys = Object.keys(breakdown).filter(function(k) { return k !== 'CANCELLED' && Number(breakdown[k]) > 0; });
            var total = keys.reduce(function(sum, k) { return sum + Number(breakdown[k]); }, 0);
            if (!total) {
                canvas.style.display = 'none';
                legend.textContent = 'Chưa có đơn hàng trong khoảng thời gian được chọn.';
                return;
            }
            canvas.style.display = 'block';
            legend.innerHTML = keys.map(function(k) {
                var count = Number(breakdown[k]);
                var label = names[k] || k;
                return '<div class="pie-legend-row"><span class="pie-dot" style="background:' + (colors[k] || colors.UNKNOWN) + '"></span>' +
                    '<span>' + esc(label) + '</span><strong>' + count + ' (' + (count / total * 100).toFixed(1) + '%)</strong></div>';
            }).join('') + '<div class="pie-legend-total">Tổng cộng: <strong>' + total + ' đơn</strong></div>';
            if (typeof Chart === 'undefined') {
                legend.innerHTML += '<p>Không tải được thư viện Chart.js để vẽ biểu đồ.</p>';
                return;
            }
            orderPieChartInstance = new Chart(canvas.getContext('2d'), {
                type: 'pie',
                data: {
                    labels: keys.map(function(k) { return names[k] || k; }),
                    datasets: [{data: keys.map(function(k) { return Number(breakdown[k]); }),
                        backgroundColor: keys.map(function(k) { return colors[k] || colors.UNKNOWN; }),
                        borderWidth: 3, borderColor: '#ffffff', hoverOffset: 10}]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: {
                        legend: {display: false},
                        tooltip: {callbacks: {label: function(item) {
                                    return ' ' + item.label + ': ' + item.raw + ' đơn (' + (item.raw / total * 100).toFixed(1) + '%)';
                                }}}
                    }
                }
            });
        }

        function fetchRevenueStats(fromDate, toDate) {
            var btn = $('btn-apply-filter');
            if (btn) { btn.disabled = true; btn.textContent = 'Đang tải...'; }

            post({
                action: 'getRevenueStats',
                from_date: fromDate || '',
                to_date: toDate || ''
            }).then(function(res) {
                if (btn) { btn.disabled = false; btn.textContent = '⚡ Áp dụng bộ lọc'; }
                if (res.success && res.revStats) {
                    S.revenueStats = res.revStats;
                    renderPage();
                    toast('Đã cập nhật biểu đồ thống kê!');
                } else {
                    toast(res.message || 'Không thể tải thống kê', true);
                }
            }).catch(function() {
                if (btn) { btn.disabled = false; btn.textContent = '⚡ Áp dụng bộ lọc'; }
                toast('Lỗi kết nối máy chủ', true);
            });
        }

        function drawAnalyticsChart() {
            var canvas = $('analyticsBarChart');
            if (!canvas || typeof Chart === 'undefined') return;

            if (analyticsChartInstance) {
                analyticsChartInstance.destroy();
                analyticsChartInstance = null;
            }

            var rev = S.revenueStats || {};
            var labels = rev.labels || [];
            var fullDates = rev.fullDates || [];
            var isRevenue = (S.analyticsMetric !== 'orders');

            var datasetData = isRevenue ? (rev.revenueData || []) : (rev.orderData || []);
            var datasetLabel = isRevenue ? 'Doanh thu (₫)' : 'Số lượng đơn hàng';
            var barColor = isRevenue ? 'rgba(27, 100, 242, 0.85)' : 'rgba(16, 185, 129, 0.85)';
            var barHoverColor = isRevenue ? 'rgba(30, 64, 175, 1)' : 'rgba(5, 150, 105, 1)';
            var borderColor = isRevenue ? '#1b64f2' : '#10b981';

            var ctx = canvas.getContext('2d');
            analyticsChartInstance = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: datasetLabel,
                        data: datasetData,
                        backgroundColor: barColor,
                        hoverBackgroundColor: barHoverColor,
                        borderColor: borderColor,
                        borderWidth: 1,
                        borderRadius: 6,
                        maxBarThickness: 42
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top',
                            labels: {
                                boxWidth: 12,
                                font: { family: 'Inter', size: 12, weight: '600' },
                                color: '#475569'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(15, 23, 42, 0.92)',
                            titleFont: { family: 'Inter', size: 13, weight: '700' },
                            bodyFont: { family: 'Inter', size: 12 },
                            padding: 10,
                            cornerRadius: 8,
                            callbacks: {
                                title: function(items) {
                                    if (!items || !items.length) return '';
                                    var idx = items[0].dataIndex;
                                    return (fullDates && fullDates[idx]) ? fullDates[idx] : items[0].label;
                                },
                                label: function(item) {
                                    var val = item.raw || 0;
                                    return isRevenue ? ('Doanh thu: ' + (Number(val) || 0).toLocaleString('vi-VN') + ' ₫') : ('Số đơn hàng: ' + val + ' đơn');
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: {
                                font: { family: 'Inter', size: 11, weight: '500' },
                                color: '#64748b'
                            }
                        },
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: '#f1f5f9'
                            },
                            ticks: {
                                font: { family: 'Inter', size: 11 },
                                color: '#64748b',
                                callback: function(value) {
                                    if (isRevenue) {
                                        if (value >= 1000000) return (value / 1000000).toFixed(1) + ' tr';
                                        if (value >= 1000) return (value / 1000).toFixed(0) + ' k';
                                        return value;
                                    }
                                    return Number.isInteger(value) ? value : '';
                                }
                            }
                        }
                    }
                }
            });
        }

        function renderPage() {
            var page = S.page;
            $('page-title').textContent = (TITLES[page] || TITLES.dashboard)[0];
            document.title = (TITLES[page] || TITLES.dashboard)[0] + ' · KeebHub';
            $('quick-search').placeholder = (page === 'dashboard' || page === 'analytics') ? 'Tìm nhanh trong các mục...': 'Tìm trong ' + (page === 'users' ? 'người dùng': page === 'products' ? 'sản phẩm': 'đơn hàng') + '...';
            Array.prototype.forEach.call(document.querySelectorAll('[data-page]'), function (button) {
                if (button.classList.contains('nav-item')) button.classList.toggle('active', button.dataset.page === page);
            });
            if (page === 'users') $('main-content').innerHTML = renderUsers();
            else if (page === 'products') $('main-content').innerHTML = renderProducts();
            else if (page === 'orders') $('main-content').innerHTML = renderOrders();
            else if (page === 'order-status') $('main-content').innerHTML = renderOrderStatuses();
            else if (page === 'analytics') {
                $('main-content').innerHTML = renderAnalytics();
                afterRenderAnalytics();
            }
            else $('main-content').innerHTML = renderDashboard();
            bindAddButtons();
        }

        function fieldHtml(field) {
            var value = field.value == null ? '': field.value;
            var required = field.required ? ' required': '';
            var readonly = field.readonly ? ' readonly': '';
            var placeholder = field.placeholder ? ' placeholder="' + esc(field.placeholder) + '"': '';
            var input;
            if (field.type === 'select') {
                var options = opts(field.options || []);
                input = '<select name="' + esc(field.key) + '"' + required + '>' + options.map(function (option) {
                    var selected = String(option.value) === String(value) ? ' selected': '';
                    return '<option value="' + esc(option.value) + '"' + selected + '>' + esc(option.label) + '</option>';
                }).join('') + '</select>';
            } else if (field.type === 'textarea') {
                input = '<textarea name="' + esc(field.key) + '" rows="3"' + required + placeholder + '>' + esc(value) + '</textarea>';
            } else {
                var type = field.type || 'text';
                input = '<input type="' + esc(type) + '" name="' + esc(field.key) + '" value="' + esc(value) + '"' +
                    (field.min != null ? ' min="' + esc(field.min) + '"': '') + (field.max != null ? ' max="' + esc(field.max) + '"': '') +
                    (field.step != null ? ' step="' + esc(field.step) + '"': '') + (field.autocomplete ? ' autocomplete="' + esc(field.autocomplete) + '"': '') +
                    required + readonly + placeholder + '>';
            }
            return '<label class="form-field' + (field.full ? ' full-field': '') + '"><span>' + esc(field.label) + (field.required ? ' <em>*</em>': '') + '</span>' + input +
                (field.help ? '<small>' + esc(field.help) + '</small>': '') + '</label>';
        }

        function showModal(title, fields, saveHandler, deleteHandler) {
            var host = $('modal-container');
            host.innerHTML = '<div class="modal-backdrop"><section class="modal-dialog" role="dialog" aria-modal="true" aria-label="' + esc(title) + '"><div class="modal-heading"><div><span class="eyebrow">KEEBHUB ADMIN</span><h2>' + esc(title) + '</h2></div><button type="button" class="close-modal" aria-label="Đóng">×</button></div>' +
                '<form id="record-form" class="record-form"><div class="form-grid">' + fields.map(fieldHtml).join('') + '</div><div class="modal-footer">' +
                (deleteHandler ? '<button type="button" class="btn btn-danger-light" id="modal-delete">Xóa bản ghi</button>': '<span class="form-note">Các trường có dấu * là bắt buộc.</span>') +
                '<div class="modal-footer-actions"><button type="button" class="btn btn-light" id="modal-cancel">Hủy</button><button type="submit" class="btn btn-primary" id="modal-save">Lưu thay đổi</button></div></div></form></section></div>';
            function close() { host.innerHTML = ''; }
            host.querySelector('.close-modal').onclick = close;
            $('modal-cancel').onclick = close;
            host.querySelector('.modal-backdrop').addEventListener('click', function (event) { if (event.target === event.currentTarget) close(); });
            $('record-form').addEventListener('submit', function (event) {
                event.preventDefault();
                var data = {};
                new FormData(event.currentTarget).forEach(function (value, key) { data[key] = String(value).trim(); });
                var btnSave = $('modal-save');
                if (btnSave) { btnSave.disabled = true; btnSave.textContent = 'Đang lưu...'; }
                Promise.resolve(saveHandler(data)).then(function (ok) {
                    if (ok) close();
                    else if ($('modal-save')) { $('modal-save').disabled = false; $('modal-save').textContent = 'Lưu thay đổi'; }
                }).catch(function () {
                    if ($('modal-save')) { $('modal-save').disabled = false; $('modal-save').textContent = 'Lưu thay đổi'; }
                });
            });
            if (deleteHandler) {
                $('modal-delete').onclick = function () {
                    if (window.confirm('Bạn chắc chắn muốn xóa bản ghi này?')) {
                        Promise.resolve(deleteHandler()).then(function (ok) { if (ok) close(); });
                    }
                };
            }
            var first = host.querySelector('input,select,textarea');
            if (first) first.focus();
        }

        function userFields(user) {
            var creating = !user;
            return [
                {key:'first_name', label:'Họ', value:user ? user.first_name: '', required:true},
                {key:'last_name', label:'Tên', value:user ? user.last_name: '', required:true},
                {key:'email', label:'Email', type:'email', value:user ? user.email: '', required:true},
                {key:'password', label:creating ? 'Mật khẩu': 'Mật khẩu mới', type:'password', value:'', required:creating, autocomplete:'new-password', help:creating ? 'Ít nhất 6 ký tự.': 'Để trống nếu không muốn đổi mật khẩu.'},
                {key:'role', label:'Vai trò', type:'select', options:USER_ROLES, value:user ? user.role: 'CUSTOMER', required:true},
                {key:'status', label:'Trạng thái', type:'select', options:USER_STATUSES, value:user ? user.status: 'ACTIVE', required:true}
            ];
        }
        function productFields(product) {
            var shopOptions = S.shops.map(function (shop) { return {value:shop.id, label:shop.shop_name}; });
            var categoryOptions = S.categories.map(function (category) { return {value:category.id, label:category.name}; });
            return [
                {key:'name', label:'Tên sản phẩm', value:product ? product.name: '', required:true, full:true},
                {key:'sku', label:'Mã SKU', value:product ? product.sku: '', required:true},
                {key:'price', label:'Giá bán (VNĐ)', type:'number', min:0, step:1, value:product ? product.price: 0, required:true},
                {key:'shop_id', label:'Cửa hàng', type:'select', options:shopOptions, value:product ? product.shop_id: (shopOptions[0] ? shopOptions[0].value: ''), required:true},
                {key:'category_id', label:'Danh mục', type:'select', options:categoryOptions, value:product ? product.category_id: (categoryOptions[0] ? categoryOptions[0].value: ''), required:true},
                {key:'stock', label:'Số lượng tồn kho', type:'number', min:0, step:1, value:product ? product.stock: 0, required:true},
                {key:'status', label:'Trạng thái', type:'select', options:PRODUCT_STATUSES, value:product ? product.status: 'ACTIVE', required:true}
            ];
        }
        function orderFields(order) {
            var creating = !order;
            var fields = [
                {key:'order_code', label:'Mã đơn hàng', value:order ? order.order_code: '', placeholder:'Để trống để tự tạo', help:'Tối đa 30 ký tự.'},
                {key:'receiver_name', label:'Tên người nhận', value:order ? order.receiver_name: '', required:true},
                {key:'customer_email', label:'Tài khoản khách hàng', type:'select', options:userOptions(order ? order.customer_email: null), value:order ? order.customer_email: (userOptions(null)[0] ? userOptions(null)[0].value: ''), required:true, full:true},
                {key:'receiver_phone', label:'Số điện thoại', value:order ? order.receiver_phone: '', required:true},
                {key:'shipping_address', label:'Địa chỉ giao hàng', value:order ? order.shipping_address: '', required:true, full:true},
                {key:'status', label:'Trạng thái ban đầu', type:'select', options:['PENDING'], value:'PENDING', required:true}
            ];
            if (!creating) fields.pop(); // Trạng thái chỉ thay đổi ở tab cập nhật riêng.
            if (creating) {
                fields.splice(1, 0, {key:'product_id', label:'Sản phẩm', type:'select', options:productOptions(null), value:productOptions(null)[0] ? productOptions(null)[0].value: '', required:true, full:true});
                fields.splice(2, 0, {key:'quantity', label:'Số lượng', type:'number', min:1, max:10000, step:1, value:1, required:true, help:'Tổng tiền sẽ tính theo giá sản phẩm × số lượng.'});
            } else {
                fields.push({key:'order_total_display', label:'Tổng tiền hiện tại', type:'text', value:money(order.total_amount), readonly:true, help:'Giá trị thanh toán được giữ nguyên khi chỉnh sửa thông tin đơn.'});
            }
            return fields;
        }

        function bindAddButtons() {
            var addUser = $('add-user');
            if (addUser) addUser.onclick = function () {
                showModal('Thêm người dùng', userFields(null), function (form) {
                    form.action = 'saveUser'; form.id = 0;
                    return call(form, function (result) {
                        S.users.unshift({id:result.id, first_name:form.first_name, last_name:form.last_name, email:form.email.toLowerCase(), role:form.role, status:form.status});
                    });
                });
            };
            var addProduct = $('add-product');
            if (addProduct) addProduct.onclick = function () {
                if (!S.shops.length || !S.categories.length) { toast('Cần có ít nhất một cửa hàng và một danh mục trước khi thêm sản phẩm.', true); return; }
                showModal('Thêm sản phẩm', productFields(null), function (form) {
                    form.action = 'saveProduct'; form.id = 0;
                    return call(form, function (result) {
                        var shop = byId(S.shops, form.shop_id), category = byId(S.categories, form.category_id);
                        S.products.unshift({id:result.id, name:form.name, sku:form.sku, shop_id:+form.shop_id, category_id:+form.category_id,
                            shop_name:shop ? shop.shop_name: '', category_name:category ? category.name: '', price:+form.price, stock:+form.stock, status:form.status});
                    });
                });
            };
            var addOrder = $('add-order');
            if (addOrder) addOrder.onclick = function () {
                if (!userOptions(null).length || !productOptions(null).length) { toast('Cần có người dùng ACTIVE và sản phẩm ACTIVE trước khi tạo đơn hàng.', true); return; }
                showModal('Tạo đơn hàng', orderFields(null), function (form) {
                    form.action = 'saveOrder'; form.id = 0;
                    return call(form, function (result) {
                        var product = byId(S.products, form.product_id);
                        var qty = +form.quantity || 1;
                        var totalAmt = result.totalAmount || ((product ? +product.price : 0) * qty);
                        var finalCode = result.orderCode || form.order_code || ('ID-' + result.id);
                        S.orders.unshift({
                            id: result.id,
                            order_code: finalCode,
                            receiver_name: form.receiver_name,
                            receiver_phone: form.receiver_phone,
                            shipping_address: form.shipping_address,
                            customer_email: form.customer_email,
                            total_amount: totalAmt,
                            order_status: form.status,
                            product_id: +form.product_id,
                            product_name: product ? product.name : '',
                            created_at: new Date().toISOString().slice(0, 19).replace('T', ' ')
                        });
                    });
                });
            };
        }

        // Xử lý bật/tắt Admin Profile Menu khi bấm vào avatar
        var profileMenu = document.querySelector('.admin-profile-menu');
        if (profileMenu) {
            profileMenu.addEventListener('click', function (e) {
                if (e.target.closest('.dropdown-item')) return;
                e.stopPropagation();
                this.classList.toggle('active');
            });
        }

        document.addEventListener('click', function (event) {
            // Tự động đóng Profile Menu khi bấm ra ngoài khung
            if (profileMenu && !profileMenu.contains(event.target)) {
                profileMenu.classList.remove('active');
            }

            var nav = event.target.closest('[data-page]');
            if (nav) {
                S.page = nav.dataset.page;
                $('quick-search').value = '';
                renderPage();
                return;
            }
            var button = event.target.closest('[data-act]');
            if (!button) return;
            var action = button.dataset.act;
            var id = button.dataset.id;
            if (action === 'edit-user') {
                var user = byId(S.users, id);
                if (!user) return;
                showModal('Sửa người dùng #' + id, userFields(user), function (form) {
                    form.action = 'saveUser'; form.id = id;
                    return call(form, function () {
                        var oldEmail = user.email;
                        var newEmail = form.email.toLowerCase();
                        Object.assign(user, {first_name:form.first_name, last_name:form.last_name, email:newEmail, role:form.role, status:form.status});
                        if (oldEmail !== newEmail) {
                            S.orders.forEach(function (o) {
                                if (o.customer_email === oldEmail) o.customer_email = newEmail;
                            });
                        }
                    });
                }, function () {
                    var delEmail = user.email;
                    return call({action:'deleteUser', id:id}, function () {
                        S.users = S.users.filter(function (item) { return String(item.id) !== String(id); });
                        S.orders = S.orders.filter(function (o) { return o.customer_email !== delEmail; });
                    });
                });
            } else if (action === 'delete-user') {
                var deleteUser = byId(S.users, id);
                if (deleteUser && window.confirm('Xóa người dùng ' + deleteUser.email + '? Đơn hàng thuộc tài khoản này cũng sẽ bị xóa.')) {
                    var delEmail = deleteUser.email;
                    call({action:'deleteUser', id:id}, function () {
                        S.users = S.users.filter(function (item) { return String(item.id) !== String(id); });
                        S.orders = S.orders.filter(function (o) { return o.customer_email !== delEmail; });
                    });
                }
            } else if (action === 'edit-product') {
                var product = byId(S.products, id);
                if (!product) return;
                showModal('Sửa sản phẩm #' + id, productFields(product), function (form) {
                    form.action = 'saveProduct'; form.id = id;
                    return call(form, function () {
                        var shop = byId(S.shops, form.shop_id), category = byId(S.categories, form.category_id);
                        Object.assign(product, {name:form.name, sku:form.sku, shop_id:+form.shop_id, category_id:+form.category_id,
                            shop_name:shop ? shop.shop_name: '', category_name:category ? category.name: '', price:+form.price, stock:+form.stock, status:form.status});
                        S.orders.forEach(function (o) {
                            if (String(o.product_id) === String(id)) o.product_name = form.name;
                        });
                    });
                }, function () {
                    return call({action:'deleteProduct', id:id}, function (result) {
                        if (result.hardDeleted) S.products = S.products.filter(function (item) { return String(item.id) !== String(id); });
                        else product.status = 'INACTIVE';
                    });
                });
            } else if (action === 'delete-product') {
                var deleteProduct = byId(S.products, id);
                if (deleteProduct && window.confirm('Xóa/ngừng bán sản phẩm "' + deleteProduct.name + '"?')) {
                    call({action:'deleteProduct', id:id}, function (result) {
                        if (result.hardDeleted) S.products = S.products.filter(function (item) { return String(item.id) !== String(id); });
                        else deleteProduct.status = 'INACTIVE';
                    });
                }
            } else if (action === 'update-order-status') {
                var selectedOrder = byId(S.orders, id);
                if (!selectedOrder) return;
                var current = selectedOrder.order_status;
                var allowed = allowedOrderStatuses(current);
                if (!allowed.length) { toast('Đơn hàng này đã hoàn tất hoặc đã hủy, không thể cập nhật tiếp.', true); return; }
                var statusOptions = allowed.map(function (status) {
                    return {value:status, label:ORDER_STATUS_LABELS[status] || status};
                });
                showModal('Cập nhật trạng thái ' + selectedOrder.order_code, [
                    {key:'status', label:'Trạng thái mới', type:'select', options:statusOptions,
                        value:allowed[0], required:true}
                ], function (form) {
                    return call({action:'updateOrderStatus', id:id, status:form.status}, function () {
                        selectedOrder.order_status = form.status;
                    });
                });
            } else if (action === 'edit-order') {
                var order = byId(S.orders, id);
                if (!order) return;
                showModal('Sửa đơn hàng ' + order.order_code, orderFields(order), function (form) {
                    form.action = 'saveOrder'; form.id = id;
                    return call(form, function (result) {
                        Object.assign(order, {
                            order_code: (result.orderCode && result.orderCode.trim()) ? result.orderCode : (form.order_code || order.order_code),
                            receiver_name: form.receiver_name,
                            receiver_phone: form.receiver_phone,
                            shipping_address: form.shipping_address,
                            customer_email: form.customer_email
                        });
                    });
                }, function () {
                    return call({action:'deleteOrder', id:id}, function () { S.orders = S.orders.filter(function (item) { return String(item.id) !== String(id); }); });
                });
            } else if (action === 'delete-order') {
                var deleteOrder = byId(S.orders, id);
                if (deleteOrder && window.confirm('Xóa đơn hàng ' + deleteOrder.order_code + ' cùng các chi tiết liên quan?')) {
                    call({action:'deleteOrder', id:id}, function () { S.orders = S.orders.filter(function (item) { return String(item.id) !== String(id); }); });
                }
            }
        });

        $('quick-search').addEventListener('input', function () {
            if (S.page !== 'dashboard' && S.page !== 'analytics') renderPage();
        });
        window.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') $('modal-container').innerHTML = '';
        });
        renderPage();
    })();
</script>
</body>
</html>