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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</head>
<body>
<div class="admin-shell">
    <aside class="sidebar">
        <a class="brand" href="${pageContext.request.contextPath}/admin" aria-label="KeebHub Admin">
            <span class="brand-mark">K</span>
            <span><strong>KeebHub</strong><small>TRUNG TÂM QUẢN TRỊ</small></span>
        </a>
        <nav id="sidebar-nav" class="sidebar-nav">
            <div class="sidebar-label">TỔNG QUAN</div>
            <button type="button" class="nav-item active" data-page="dashboard"><span class="nav-icon">▦</span>Tổng quan</button>
            <button type="button" class="nav-item" data-page="analytics"><span class="nav-icon">📊</span>Thống kê biểu đồ</button>

            <div class="sidebar-label">NGƯỜI DÙNG</div>
            <button type="button" class="nav-item" data-page="users"><span class="nav-icon">♙</span>Người dùng</button>
            <button type="button" class="nav-item" data-page="shops"><span class="nav-icon">🏪</span>Tài khoản Seller/Shop<span class="nav-badge" id="badge-shops" hidden></span></button>

            <div class="sidebar-label">KIỂM DUYỆT</div>
            <button type="button" class="nav-item" data-page="moderation"><span class="nav-icon">✓</span>Kiểm duyệt sản phẩm<span class="nav-badge" id="badge-mod" hidden></span></button>

            <div class="sidebar-label">QUẢN LÝ</div>
            <button type="button" class="nav-item" data-page="products"><span class="nav-icon">⌨</span>Quản lý sản phẩm</button>
            <button type="button" class="nav-item" data-page="orders"><span class="nav-icon">▤</span>Quản lý đơn hàng</button>

            <div class="sidebar-label">ĐIỀU HƯỚNG</div>
            <a class="nav-item" href="${pageContext.request.contextPath}/index.jsp"><span class="nav-icon">↩</span>Về sàn KeebHub</a>
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
                <div class="eyebrow" id="page-eyebrow">KEEBHUB / ADMIN</div>
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
<script id="data-shops-full" type="application/json"><c:out value="${shopsFullJson}" default="[]" escapeXml="false"/></script>
<script id="data-services" type="application/json"><c:out value="${servicesJson}" default="[]" escapeXml="false"/></script>
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
            analyticsMetric: 'revenue',
            userTab: 'all',
            userChip: 'all',
            userPage: 1,
            productPage: 1,
            shopsFull: parseJson('data-shops-full'),
            services: parseJson('data-services'),
            shopTab: 'all', shopPage: 1, shopExpand: false,
            modTab: 'pending', modChip: 'all', modExpand: false,
            catSel: 0,
            orderPage: 1,
            userSel: {}
        };
        var analyticsChartInstance = null;
        var orderPieChartInstance = null;
        var categoryPieChartInstance = null;
        var paymentPieChartInstance = null;
        var ctxPath = "<c:out value='${pageContext.request.contextPath}'/>";

        var ORDER_STATUSES = ['PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPING', 'SHIPPED', 'COMPLETED', 'CANCELLED'];
        var USER_ROLES = ['CUSTOMER', 'USER', 'SELLER', 'ADMIN', 'MODERATOR'];
        var USER_STATUSES = ['ACTIVE', 'INACTIVE', 'BLOCKED'];
        var PRODUCT_STATUSES = [
            {value: 'ACTIVE', label: 'Đang bán'}, {value: 'INACTIVE', label: 'Ngừng bán'}, {value: 'PENDING', label: 'Chờ duyệt'},
            {value: 'REJECTED', label: 'Bị từ chối'}, {value: 'NEEDS_EDIT', label: 'Cần sửa'}
        ];
        var PRODUCT_STATUS_LABELS = {ACTIVE: 'Đang bán', INACTIVE: 'Ngừng bán', PENDING: 'Chờ duyệt', REJECTED: 'Bị từ chối', NEEDS_EDIT: 'Cần sửa'};
        var TITLES = {
            dashboard: ['Tổng quan', 'Số liệu tổng hợp cơ sở dữ liệu.'],
            analytics: ['Thống kê & Biểu đồ', 'Biểu đồ cột doanh thu và biểu đồ tròn tỷ lệ trạng thái đơn hàng.'],
            users: ['Quản lý người dùng', 'Theo dõi tài khoản, vai trò và trạng thái.'],
            shops: ['Tài khoản Seller / Shop', 'Hồ sơ cửa hàng, xưởng gia công và chủ shop.'],
            moderation: ['Kiểm duyệt sản phẩm & dịch vụ', 'Duyệt sản phẩm và dịch vụ gia công trước khi đăng bán.'],
            categories: ['Danh mục kỹ thuật', 'Cấu trúc danh mục và bộ quy tắc tương thích dùng cho Custom Builder.'],
            products: ['Quản lý sản phẩm', 'Thêm, sửa thông tin sản phẩm, cửa hàng, danh mục và tồn kho.'],
            orders: ['Quản lý đơn hàng', 'Xem danh sách và cập nhật trạng thái đơn hàng.']
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
        function statusPill(value, kind) {
            var state = String(value || '').toLowerCase();
            var css = 'status-neutral';
            if (['active', 'completed', 'confirmed', 'shipped'].indexOf(state) >= 0) css = 'status-success';
            else if (['pending', 'processing', 'shipping'].indexOf(state) >= 0) css = 'status-warning';
            else if (['inactive', 'blocked', 'cancelled', 'rejected', 'needs_edit'].indexOf(state) >= 0) css = 'status-danger';
            var label = kind === 'product' ? PRODUCT_STATUS_LABELS[value] : ORDER_STATUS_LABELS[value];
            return '<span class="status-pill ' + css + '">' + esc(label || nice(value)) + '</span>';
        }
        function emptyRow(columns, message) {
            return '<tr><td colspan="' + columns + '" class="empty-cell"><span class="empty-icon">⌕</span><strong>' + esc(message) + '</strong><small>Thử thay đổi từ khóa tìm kiếm.</small></td></tr>';
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
        function heading(title, note) {
            return '<div class="section-heading"><div><h2>' + esc(title) + '</h2><p>' + esc(note) + '</p></div></div>';
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

        var USER_PAGE_SIZE = 8;
        var AVATAR_COLORS = ['#1d63ed', '#7c3aed', '#ea4a0c', '#0f9d58', '#475569', '#1e40af', '#dc2626', '#0891b2'];
        var DAY = 86400000;

        function isCustomer(u) { return u.role === 'CUSTOMER' || u.role === 'USER'; }
        function isStaff(u) { return u.role === 'ADMIN' || u.role === 'MODERATOR'; }
        function userState(u) {
            if (u.status === 'BLOCKED') return 'blocked';
            if (u.status === 'INACTIVE') return 'inactive';
            if (u.verified === false) return 'pending';
            return 'active';
        }
        var USER_STATE_LABEL = {active: 'Hoạt động', pending: 'Chờ xác thực', blocked: 'Bị khoá', inactive: 'Không hoạt động'};
        function roleInfo(u) {
            if (u.role === 'SELLER') return {cls: 'role-seller', label: 'Chủ shop'};
            if (u.role === 'ADMIN') return {cls: 'role-admin', label: 'Admin'};
            if (u.role === 'MODERATOR') return {cls: 'role-admin', label: 'Điều hành viên'};
            return {cls: 'role-customer', label: 'Khách hàng'};
        }
        function parseDate(value) {
            if (!value) return null;
            var d = new Date(String(value).replace(' ', 'T'));
            return isNaN(d.getTime()) ? null : d;
        }
        function pad2(n) { return (n < 10 ? '0' : '') + n; }
        function joinedLabel(value) {
            var d = parseDate(value);
            if (!d) return '—';
            // Tài khoản mới (30 ngày gần đây) hiển thị đủ ngày, còn lại hiển thị tháng/năm.
            if (Date.now() - d.getTime() <= 30 * DAY) return pad2(d.getDate()) + '/' + pad2(d.getMonth() + 1) + '/' + d.getFullYear();
            return pad2(d.getMonth() + 1) + '/' + d.getFullYear();
        }
        function moneyShort(value) {
            var n = Number(value) || 0;
            if (n <= 0) return '0đ';
            var fixed = function (x) { return (Math.round(x * 10) / 10).toString().replace(/\.0$/, ''); };
            if (n >= 1e9) return fixed(n / 1e9) + ' tỷ';
            if (n >= 1e6) return fixed(n / 1e6) + 'tr';
            if (n >= 1e3) return fixed(n / 1e3) + 'k';
            return n + 'đ';
        }
        function nfmt(n) { return (Number(n) || 0).toLocaleString('vi-VN'); }
        function fullName(u) { return ((u.first_name || '') + ' ' + (u.last_name || '')).trim(); }

        function userTabMatch(u, tab) {
            if (tab === 'customer') return isCustomer(u);
            if (tab === 'seller') return u.role === 'SELLER';
            if (tab === 'admin') return isStaff(u);
            if (tab === 'pending') return userState(u) === 'pending';
            if (tab === 'blocked') return u.status === 'BLOCKED';
            return true;
        }
        function userChipMatch(u, chip) {
            if (chip === 'recent') { var d = parseDate(u.created_at); return !!d && Date.now() - d.getTime() <= 30 * DAY; }
            if (chip === 'ordered') return Number(u.order_count) > 0;
            return true;
        }
        function visibleUsers() {
            return filter(S.users, ['first_name', 'last_name', 'email', 'phone', 'role', 'status', 'id']).filter(function (u) {
                return userTabMatch(u, S.userTab) && userChipMatch(u, S.userChip);
            });
        }
        function pageList(current, total) {
            var set = {1: 1, 2: 1, 3: 1};
            set[total] = 1; set[current - 1] = 1; set[current] = 1; set[current + 1] = 1;
            var nums = Object.keys(set).map(Number).filter(function (n) { return n >= 1 && n <= total; }).sort(function (x, y) { return x - y; });
            var out = [], prev = 0;
            nums.forEach(function (n) { if (n - prev > 1) out.push('…'); out.push(n); prev = n; });
            return out;
        }
        function userStat(icon, tone, label, value, hint, hintTone) {
            return '<article class="um-stat"><div class="um-stat-head"><span class="um-stat-icon ' + tone + '">' + icon + '</span><span>' + esc(label) + '</span></div>' +
                '<div class="um-stat-value">' + esc(nfmt(value)) + '</div>' +
                '<div class="um-stat-hint ' + (hintTone || '') + '">' + (hint ? esc(hint) : '&nbsp;') + '</div></article>';
        }

        function renderUsers() {
            var all = S.users;
            var total = all.length;
            var weekAgo = Date.now() - 7 * DAY;
            var weekNew = all.filter(function (u) { var d = parseDate(u.created_at); return d && d.getTime() >= weekAgo; }).length;
            var customers = all.filter(isCustomer).length;
            var sellers = all.filter(function (u) { return u.role === 'SELLER'; }).length;
            var staff = all.filter(isStaff).length;
            var pending = all.filter(function (u) { return userState(u) === 'pending'; }).length;
            var blocked = all.filter(function (u) { return u.status === 'BLOCKED'; }).length;
            var share = function (n) { return total ? (Math.round(n / total * 1000) / 10) + '% tổng tài khoản' : ''; };

            var tabs = [
                ['all', 'Tất cả', total], ['customer', 'Khách hàng', customers], ['seller', 'Chủ shop', sellers],
                ['admin', 'Admin', staff], ['pending', 'Chờ xác thực', pending], ['blocked', 'Bị khoá', blocked]
            ].map(function (t) {
                return '<button type="button" class="um-tab' + (S.userTab === t[0] ? ' active' : '') + '" data-act="user-tab" data-tab="' + t[0] + '">' + t[1] + ' (' + nfmt(t[2]) + ')</button>';
            }).join('');
            var chips = [['all', 'Mọi trạng thái'], ['recent', 'Đăng ký 30 ngày'], ['ordered', 'Có đơn hàng']].map(function (c) {
                return '<button type="button" class="um-chip' + (S.userChip === c[0] ? ' active' : '') + '" data-act="user-chip" data-chip="' + c[0] + '">' + c[1] + '</button>';
            }).join('');

            var list = visibleUsers();
            var pages = Math.max(1, Math.ceil(list.length / USER_PAGE_SIZE));
            if (S.userPage > pages) S.userPage = pages;
            if (S.userPage < 1) S.userPage = 1;
            var from = (S.userPage - 1) * USER_PAGE_SIZE;
            var slice = list.slice(from, from + USER_PAGE_SIZE);

            var rows = slice.map(function (u) {
                var role = roleInfo(u), state = userState(u);
                var staffRow = isStaff(u);
                var color = AVATAR_COLORS[Math.abs(Number(u.id) || 0) % AVATAR_COLORS.length];
                return '<tr><td class="um-check"><input type="checkbox" data-sel="' + esc(u.id) + '"' + (S.userSel[u.id] ? ' checked' : '') + ' aria-label="Chọn ' + esc(fullName(u)) + '"></td>' +
                    '<td><div class="um-person"><span class="um-avatar" style="background:' + color + '">' + esc(initials(u.first_name, u.last_name)) + '</span><span><strong>' + esc(fullName(u)) + '</strong><small>' + esc(u.email) + '</small></span></div></td>' +
                    '<td class="um-phone">' + esc(u.phone || '—') + '</td>' +
                    '<td><span class="um-role ' + role.cls + '">' + role.label + '</span></td>' +
                    '<td class="um-num">' + (staffRow ? '—' : nfmt(u.order_count)) + '</td>' +
                    '<td class="um-num um-spent">' + (staffRow ? '—' : moneyShort(u.total_spent)) + '</td>' +
                    '<td class="um-joined">' + esc(joinedLabel(u.created_at)) + '</td>' +
                    '<td><span class="um-state um-state-' + state + '">' + USER_STATE_LABEL[state] + '</span></td>' +
                    '<td class="um-action"><button type="button" class="um-detail" data-act="user-detail" data-id="' + esc(u.id) + '">Chi tiết</button></td></tr>';
            }).join('');
            var allChecked = slice.length > 0 && slice.every(function (u) { return S.userSel[u.id]; });

            var pager = pageList(S.userPage, pages).map(function (p) {
                if (p === '…') return '<span class="um-page um-page-gap">…</span>';
                return '<button type="button" class="um-page' + (p === S.userPage ? ' active' : '') + '" data-act="user-page" data-page-no="' + p + '">' + nfmt(p) + '</button>';
            }).join('');
            var shown = list.length ? (from + 1) + '–' + (from + slice.length) : '0';

            return '<div class="um-stats">' +
                userStat('👥', 'tone-blue', 'Tổng tài khoản', total, weekNew ? '▲ ' + nfmt(weekNew) + ' đăng ký tuần này' : 'Chưa có đăng ký mới tuần này', weekNew ? 'up' : '') +
                userStat('🛒', 'tone-green', 'Khách hàng', customers, share(customers)) +
                userStat('🏪', 'tone-orange', 'Chủ shop', sellers, share(sellers)) +
                userStat('🚫', 'tone-red', 'Bị khoá', blocked, blocked ? '▼ ' + nfmt(blocked) + ' tài khoản đang bị khoá' : 'Không có tài khoản bị khoá', blocked ? 'down' : '') +
                '</div>' +
                '<section class="um-card"><nav class="um-tabs">' + tabs + '</nav>' +
                '<div class="um-filters"><div class="um-chips">' + chips + '</div><div class="um-tools">' +
                '<button type="button" class="um-tool" data-act="export-users">⭳ Xuất danh sách</button>' +
                '<button type="button" class="um-tool" data-act="notify-users">✉ Gửi thông báo</button></div></div>' +
                '<div class="table-scroll"><table class="um-table"><thead><tr><th class="um-check"><input type="checkbox" data-sel-all' + (allChecked ? ' checked' : '') + ' aria-label="Chọn tất cả"></th>' +
                '<th>Người dùng</th><th>Điện thoại</th><th>Vai trò</th><th class="um-num">Đơn</th><th class="um-num">Chi tiêu</th><th>Tham gia</th><th>Trạng thái</th><th></th></tr></thead><tbody>' +
                (rows || emptyRow(9, 'Không tìm thấy người dùng')) + '</tbody></table></div>' +
                '<div class="um-footer"><span>Hiển thị ' + shown + ' trong ' + nfmt(list.length) + ' tài khoản</span><div class="um-pager">' +
                '<button type="button" class="um-page" data-act="user-page" data-page-no="' + (S.userPage - 1) + '"' + (S.userPage <= 1 ? ' disabled' : '') + ' aria-label="Trang trước">‹</button>' + pager +
                '<button type="button" class="um-page" data-act="user-page" data-page-no="' + (S.userPage + 1) + '"' + (S.userPage >= pages ? ' disabled' : '') + ' aria-label="Trang sau">›</button></div></div></section>';
        }

        function exportUsersCsv() {
            var list = visibleUsers();
            var picked = list.filter(function (u) { return S.userSel[u.id]; });
            if (picked.length) list = picked;
            if (!list.length) { toast('Không có người dùng để xuất.', true); return; }
            var cell = function (v) { return '"' + String(v == null ? '' : v).replace(/"/g, '""') + '"'; };
            var lines = [['ID', 'Họ tên', 'Email', 'Điện thoại', 'Vai trò', 'Số đơn', 'Chi tiêu (VNĐ)', 'Tham gia', 'Trạng thái'].map(cell).join(',')];
            list.forEach(function (u) {
                lines.push([u.id, fullName(u), u.email, u.phone || '', roleInfo(u).label, u.order_count, u.total_spent, u.created_at || '', USER_STATE_LABEL[userState(u)]].map(cell).join(','));
            });
            var blob = new Blob(['\ufeff' + lines.join('\r\n')], {type: 'text/csv;charset=utf-8;'});
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = 'danh-sach-nguoi-dung.csv';
            document.body.appendChild(link); link.click(); link.remove();
            window.setTimeout(function () { URL.revokeObjectURL(link.href); }, 1000);
            toast('Đã xuất ' + list.length + ' tài khoản.');
        }

        var LIST_PAGE_SIZE = 10;
        function pagedFooter(key, total, label) {
            var pages = Math.max(1, Math.ceil(total / LIST_PAGE_SIZE));
            if (S[key] > pages) S[key] = pages;
            if (S[key] < 1) S[key] = 1;
            var cur = S[key];
            var from = (cur - 1) * LIST_PAGE_SIZE;
            var shown = total ? (from + 1) + '–' + Math.min(total, from + LIST_PAGE_SIZE) : '0';
            var nums = pageList(cur, pages).map(function (p) {
                if (p === '…') return '<span class="um-page um-page-gap">…</span>';
                return '<button type="button" class="um-page' + (p === cur ? ' active' : '') + '" data-act="page-nav" data-key="' + key + '" data-page-no="' + p + '">' + nfmt(p) + '</button>';
            }).join('');
            return '<div class="um-footer"><span>Hiển thị ' + shown + ' trong ' + nfmt(total) + ' ' + label + '</span><div class="um-pager">' +
                '<button type="button" class="um-page" data-act="page-nav" data-key="' + key + '" data-page-no="' + (cur - 1) + '"' + (cur <= 1 ? ' disabled' : '') + ' aria-label="Trang trước">‹</button>' + nums +
                '<button type="button" class="um-page" data-act="page-nav" data-key="' + key + '" data-page-no="' + (cur + 1) + '"' + (cur >= pages ? ' disabled' : '') + ' aria-label="Trang sau">›</button></div></div>';
        }
        function pageSlice(key, list) {
            var pages = Math.max(1, Math.ceil(list.length / LIST_PAGE_SIZE));
            if (S[key] > pages) S[key] = pages;
            if (S[key] < 1) S[key] = 1;
            var from = (S[key] - 1) * LIST_PAGE_SIZE;
            return list.slice(from, from + LIST_PAGE_SIZE);
        }

        function renderProducts() {
            var products = filter(S.products, ['name', 'sku', 'shop_name', 'category_name', 'status', 'id']);
            var rows = pageSlice('productPage', products).map(function (p) {
                return '<tr><td class="id-cell">#' + esc(p.id) + '</td><td><div class="product-cell"><span class="product-icon">⌨</span><span><strong>' + esc(p.name) + '</strong><small class="cell-sub">SKU: ' + esc(p.sku || '—') + '</small></span></div></td>' +
                    '<td>' + esc(p.shop_name) + '</td><td>' + esc(p.category_name) + '</td><td class="money-cell">' + money(p.price) + '</td><td><span class="stock-value ' + (Number(p.stock) <= 5 ? 'stock-low': '') + '">' + esc(p.stock) + '</span></td><td>' + statusPill(p.status, 'product') + '</td>' +
                    '<td><div class="action-group"><button type="button" class="btn btn-small btn-light" data-act="edit-product" data-id="' + esc(p.id) + '">Sửa</button></div></td></tr>';
            }).join('');
            return '<div class="section-heading"><div><h2>Danh sách sản phẩm</h2><p>' + esc(S.products.length + ' sản phẩm, bao gồm cả sản phẩm ngừng bán.') + '</p></div>' +
                '<button type="button" class="btn btn-primary" data-act="add-product"><span>＋</span>Thêm sản phẩm</button></div>' +
                '<div class="table-card"><div class="table-scroll"><table class="product-table"><thead><tr><th>ID</th><th>Sản phẩm</th><th>Cửa hàng</th><th>Danh mục</th><th>Giá bán</th><th>Tồn kho</th><th>Trạng thái</th><th class="action-col">Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(8, 'Không tìm thấy sản phẩm')) + '</tbody></table></div>' + pagedFooter('productPage', products.length, 'sản phẩm') + '</div>';
        }

        function renderOrders() {
            var orders = filter(S.orders, ['order_code', 'receiver_name', 'receiver_phone', 'shipping_address', 'customer_email', 'order_status', 'product_name', 'id']);
            var rows = pageSlice('orderPage', orders).map(function (o) {
                var allowed = allowedOrderStatuses(o.order_status);
                return '<tr><td><strong class="mono">' + esc(o.order_code) + '</strong><small class="cell-sub">ID #' + esc(o.id) + '</small></td>' +
                    '<td><strong>' + esc(o.receiver_name) + '</strong><small class="cell-sub">' + esc(o.customer_email) + '</small></td>' +
                    '<td><strong>' + esc(o.product_name || 'Sản phẩm') + '</strong><small class="cell-sub">' + esc(o.receiver_phone || '') + '</small></td>' +
                    '<td class="money-cell">' + money(o.total_amount) + '</td><td>' + statusPill(o.order_status) + '</td>' +
                    '<td><div class="action-group"><button type="button" class="btn btn-small btn-light" data-act="update-order-status" data-id="' + esc(o.id) + '"' +
                    (allowed.length ? '' : ' disabled') + '>' + (allowed.length ? 'Cập nhật trạng thái' : 'Đã kết thúc') + '</button></div></td></tr>';
            }).join('');
            return heading('Danh sách đơn hàng', S.orders.length + ' đơn hàng.') +
                '<div class="table-card"><div class="table-scroll"><table><thead><tr><th>Mã đơn</th><th>Người nhận</th><th>Sản phẩm</th><th>Tổng tiền</th><th>Trạng thái</th><th class="action-col">Thao tác</th></tr></thead><tbody>' +
                (rows || emptyRow(6, 'Không tìm thấy đơn hàng')) + '</tbody></table></div>' + pagedFooter('orderPage', orders.length, 'đơn hàng') + '</div>';
        }


        /* ================= Tài khoản Seller / Shop ================= */
        var SHOP_STATE_LABEL = {active: 'Hoạt động', pending: 'Chờ xác minh', watch: 'Đang theo dõi', locked: 'Đã khoá'};
        function shopWatched(s) { return Number(s.cancel_rate) > 5 || Number(s.on_time_rate) < 90; }
        function shopState(s) {
            if (s.owner_status === 'BLOCKED') return 'locked';
            if (!s.verified) return 'pending';
            if (shopWatched(s)) return 'watch';
            return 'active';
        }
        function shopTypeText(s) { return s.workshop ? 'Xưởng gia công' : 'Bán lẻ'; }
        function shopAvatar(s, size) {
            return '<span class="sh-avatar" style="background:' + esc(s.avatar_color || '#1d63ed') + ';width:' + size + 'px;height:' + size + 'px;font-size:' + Math.round(size * 0.32) + 'px">' + esc(s.avatar_text || initials(s.shop_name, '')) + '</span>';
        }
        function shopChecks(s) {
            return [
                ['Có mô tả cửa hàng', String(s.description || '').length >= 20],
                ['Có địa chỉ cửa hàng', !!String(s.address || '').trim()],
                ['Chủ shop có số điện thoại', !!String(s.owner_phone || '').trim()],
                s.workshop ? ['Đã đăng ký dịch vụ gia công', Number(s.services) > 0] : ['Đã có sản phẩm', Number(s.products) > 0]
            ];
        }
        function checkList(checks) {
            return '<div class="md-checks">' + checks.map(function (c) {
                return '<span class="md-check ' + (c[1] ? 'ok' : 'bad') + '"><i>' + (c[1] ? '✓' : '✕') + '</i>' + esc(c[0]) + '</span>';
            }).join('') + '</div>';
        }
        function visibleShops() {
            return filter(S.shopsFull, ['shop_name', 'owner_name', 'owner_email', 'address']).filter(function (s) {
                if (S.shopTab === 'workshop') return s.workshop;
                if (S.shopTab === 'watch') return shopState(s) === 'watch';
                if (S.shopTab === 'locked') return shopState(s) === 'locked';
                return true;
            });
        }
        function renderShops() {
            var all = S.shopsFull;
            var pending = all.filter(function (s) { return shopState(s) === 'pending'; });
            var locked = all.filter(function (s) { return shopState(s) === 'locked'; });
            var watch = all.filter(function (s) { return shopState(s) === 'watch'; });
            var workshops = all.filter(function (s) { return s.workshop; });
            var activeCount = all.filter(function (s) { var st = shopState(s); return st === 'active' || st === 'watch'; }).length;

            var cards = (S.shopExpand ? pending : pending.slice(0, 3)).map(function (s) {
                return '<article class="sh-card"><div class="sh-card-top">' + shopAvatar(s, 56) + '<div class="sh-card-body">' +
                    '<div class="sh-card-title"><strong>' + esc(s.shop_name) + '</strong><span class="sh-tag' + (s.workshop ? ' workshop' : '') + '">' + (s.workshop ? 'Đăng ký xưởng gia công' : 'Bán lẻ') + '</span></div>' +
                    '<div class="sh-card-sub">' + esc([s.owner_name, s.owner_phone, s.address, s.joined_date ? 'tham gia ' + s.joined_date : ''].filter(Boolean).join(' · ')) + '</div>' +
                    checkList(shopChecks(s)) + '</div></div>' +
                    '<div class="sh-card-foot"><button type="button" class="link-btn" data-act="shop-profile" data-id="' + esc(s.id) + '">Xem hồ sơ đầy đủ</button><div class="sh-card-actions">' +
                    '<button type="button" class="um-tool danger" data-act="shop-reject" data-id="' + esc(s.id) + '">Từ chối</button>' +
                    '<button type="button" class="um-tool primary" data-act="shop-approve" data-id="' + esc(s.id) + '">✓ Duyệt &amp; kích hoạt</button></div></div></article>';
            }).join('');
            var pendingBlock = '<section class="um-card sh-pending"><div class="sh-pending-head"><div><h3>Hồ sơ chờ xác minh</h3><p>Kiểm tra hồ sơ rồi duyệt để cửa hàng được phép đăng bán.</p></div>' +
                '<span class="sh-count">' + nfmt(pending.length) + ' hồ sơ</span></div>' +
                (cards || '<div class="sh-empty">Không có hồ sơ nào đang chờ xác minh.</div>') +
                (!S.shopExpand && pending.length > 3 ? '<div class="sh-more"><button type="button" class="um-tool" data-act="shop-expand">Xem ' + (pending.length - 3) + ' hồ sơ còn lại</button></div>' : '') +
                '</section>';

            var tabs = [['all', 'Tất cả', all.length], ['workshop', 'Xưởng gia công', workshops.length], ['watch', 'Đang theo dõi', watch.length], ['locked', 'Đã khoá', locked.length]].map(function (t) {
                return '<button type="button" class="um-tab' + (S.shopTab === t[0] ? ' active' : '') + '" data-act="shop-tab" data-tab="' + t[0] + '">' + t[1] + ' (' + nfmt(t[2]) + ')</button>';
            }).join('');
            var list = visibleShops();
            var rows = pageSlice('shopPage', list).map(function (s) {
                var st = shopState(s);
                var good = function (ok, text) { return '<span class="' + (ok ? 'rate-good' : 'rate-bad') + '">' + text + '</span>'; };
                return '<tr><td><div class="um-person">' + shopAvatar(s, 40) + '<span><strong>' + esc(s.shop_name) + '</strong><small>' + esc(shopTypeText(s) + (s.address ? ' · ' + s.address : '')) + '</small></span></div></td>' +
                    '<td class="um-num">' + nfmt(s.order_count) + '</td><td class="um-num um-spent">' + moneyShort(s.gmv_month) + '</td>' +
                    '<td class="um-num">' + (Number(s.rating_avg) ? Number(s.rating_avg).toFixed(1) + ' ★' : '—') + '</td>' +
                    '<td class="um-num">' + good(Number(s.on_time_rate) >= 90, Number(s.on_time_rate).toFixed(0) + '%') + '</td>' +
                    '<td class="um-num">' + good(Number(s.cancel_rate) <= 5, Number(s.cancel_rate).toFixed(1) + '%') + '</td>' +
                    '<td><span class="um-state sh-state-' + st + '">' + SHOP_STATE_LABEL[st] + '</span></td>' +
                    '<td class="um-action"><button type="button" class="um-detail" data-act="shop-manage" data-id="' + esc(s.id) + '">Quản lý</button></td></tr>';
            }).join('');

            var warn = watch.length ? '<div class="note-banner warn"><strong>' + esc(watch.map(function (s) { return s.shop_name; }).slice(0, 3).join(', ')) + (watch.length > 3 ? ' và ' + (watch.length - 3) + ' shop khác' : '') + '</strong> ' +
                'vượt ngưỡng cảnh báo của sàn (huỷ đơn &gt; 5% hoặc giao đúng hẹn &lt; 90%). Hãy mở "Quản lý" để xem số liệu chi tiết.</div>' : '';

            return '<div class="um-stats">' +
                userStat('🏪', 'tone-blue', 'Shop hoạt động', activeCount, share2(activeCount, all.length)) +
                userStat('🛠️', 'tone-orange', 'Xưởng gia công', workshops.length, share2(workshops.length, all.length)) +
                userStat('🕑', 'tone-green', 'Chờ xác minh', pending.length, pending.length ? '▼ Cần duyệt sớm' : 'Không có hồ sơ chờ', pending.length ? 'down' : '') +
                userStat('🚫', 'tone-red', 'Đã khoá', locked.length, '') + '</div>' +
                pendingBlock +
                '<section class="um-card" style="margin-top:20px"><nav class="um-tabs">' + tabs + '</nav>' +
                '<div class="table-scroll"><table class="um-table"><thead><tr><th>Shop</th><th class="um-num">Đơn</th><th class="um-num">GMV tháng</th><th class="um-num">Đánh giá</th><th class="um-num">Đúng hẹn</th><th class="um-num">Tỉ lệ huỷ</th><th>Trạng thái</th><th></th></tr></thead><tbody>' +
                (rows || emptyRow(8, 'Không tìm thấy cửa hàng')) + '</tbody></table></div>' + pagedFooter('shopPage', list.length, 'cửa hàng') + '</section>' + warn;
        }
        function share2(n, total) { return total ? (Math.round(n / total * 1000) / 10) + '% tổng cửa hàng' : ''; }

        function showInfo(title, rows, actions) {
            var host = $('modal-container');
            host.innerHTML = '<div class="modal-backdrop"><section class="modal-dialog" role="dialog" aria-modal="true" aria-label="' + esc(title) + '"><div class="modal-heading"><div><span class="eyebrow">KEEBHUB ADMIN</span><h2>' + esc(title) + '</h2></div><button type="button" class="close-modal" aria-label="Đóng">×</button></div>' +
                '<div class="info-body"><dl class="info-grid">' + rows.map(function (r) {
                    return '<div class="info-row' + (r[2] ? ' full' : '') + '"><dt>' + esc(r[0]) + '</dt><dd>' + esc(r[1] == null || r[1] === '' ? '—' : r[1]) + '</dd></div>';
                }).join('') + '</dl></div><div class="modal-footer info-foot"><div class="modal-footer-actions">' +
                '<button type="button" class="btn btn-light" id="info-close">Đóng</button>' +
                (actions || []).map(function (a, i) { return '<button type="button" class="btn ' + (a.cls || 'btn-light') + '" data-info-act="' + i + '">' + esc(a.label) + '</button>'; }).join('') + '</div></div></section></div>';
            function close() { host.innerHTML = ''; }
            host.querySelector('.close-modal').onclick = close;
            $('info-close').onclick = close;
            host.querySelector('.modal-backdrop').addEventListener('click', function (e) { if (e.target === e.currentTarget) close(); });
            Array.prototype.forEach.call(host.querySelectorAll('[data-info-act]'), function (btn) {
                btn.onclick = function () { var a = actions[Number(btn.dataset.infoAct)]; close(); if (a && a.run) a.run(); };
            });
        }
        function shopInfoRows(s) {
            return [
                ['Tên cửa hàng', s.shop_name], ['Loại hình', shopTypeText(s)],
                ['Chủ shop', s.owner_name], ['Email', s.owner_email], ['Điện thoại', s.owner_phone], ['Tham gia', s.joined_date],
                ['Địa chỉ', s.address, true], ['Mô tả', s.description, true],
                ['Sản phẩm', nfmt(s.products)], ['Dịch vụ gia công', nfmt(s.services)],
                ['Tổng đơn', nfmt(s.order_count)], ['GMV tháng này', money(s.gmv_month)],
                ['Đánh giá', Number(s.rating_avg) ? Number(s.rating_avg).toFixed(1) + ' ★' : '—'], ['Trạng thái', SHOP_STATE_LABEL[shopState(s)]]
            ];
        }
        function shopAction(id, action) {
            return call({action: action, id: id}, function (r) { if (r.shopsFull) S.shopsFull = r.shopsFull; });
        }

        /* ================= Kiểm duyệt ================= */
        function modItems() {
            var items = [];
            S.products.forEach(function (p) {
                items.push({key: 'P' + p.id, type: 'PRODUCT', id: p.id, title: p.name, status: p.status, thumb: p.image_url, shop: p.shop_name,
                    meta: [p.shop_name, p.category_name, money(p.price), p.created_at ? 'gửi ' + String(p.created_at).slice(0, 16) : ''].filter(Boolean).join(' · '),
                    checks: [
                        ['Thông tin cơ bản đầy đủ (SKU, thương hiệu, giá)', !!String(p.sku || '').trim() && !!String(p.brand || '').trim() && Number(p.price) > 0],
                        ['Mô tả trên 100 ký tự', Number(p.desc_len) >= 100],
                        ['Đủ thông số bắt buộc (từ 3 dòng)', Number(p.spec_count) >= 3],
                        ['Có dữ liệu tương thích (UC27)', Number(p.compat_count) >= 1]
                    ], raw: p});
            });
            S.services.forEach(function (v) {
                items.push({key: 'S' + v.id, type: 'SERVICE', id: v.id, title: v.name, status: v.status, thumb: '', shop: v.shop_name,
                    meta: [v.shop_name, 'Dịch vụ gia công', money(v.price), v.duration].filter(Boolean).join(' · '),
                    checks: [
                        ['Mô tả trên 100 ký tự', Number(v.desc_len) >= 100],
                        ['Giá dịch vụ hợp lệ', Number(v.price) > 0],
                        ['Có thời gian thực hiện', !!String(v.duration || '').trim()],
                        ['Shop là xưởng gia công', !!v.workshop]
                    ], raw: v});
            });
            items.forEach(function (it) { it.pass = it.checks.every(function (c) { return c[1]; }); });
            return items;
        }
        function modGroup(it) {
            if (it.status === 'PENDING') return 'pending';
            if (it.status === 'ACTIVE') return 'approved';
            if (it.status === 'REJECTED' || it.status === 'NEEDS_EDIT') return 'rejected';
            return 'other';
        }
        function pendingModCount() { return modItems().filter(function (it) { return it.status === 'PENDING'; }).length; }
        function thumbHtml(it) {
            var icon = it.type === 'SERVICE' ? '🛠️' : '⌨';
            var src = '';
            if (it.thumb) src = /^(https?:)?\/\//.test(it.thumb) ? it.thumb : ctxPath + '/' + String(it.thumb).replace(/^\//, '');
            return '<div class="md-thumb"><span>' + icon + '</span>' + (src ? '<img src="' + esc(src) + '" alt="" onerror="this.remove()">' : '') + '</div>';
        }
        function renderModeration() {
            var items = modItems();
            var q = ($('quick-search').value || '').trim().toLocaleLowerCase('vi-VN');
            var groups = {pending: 0, approved: 0, rejected: 0};
            items.forEach(function (it) { var g = modGroup(it); if (groups[g] != null) groups[g]++; });
            var pendingItems = items.filter(function (it) { return it.status === 'PENDING'; });
            var autoPass = pendingItems.filter(function (it) { return it.pass; }).length;
            var autoFail = pendingItems.length - autoPass;

            var list = items.filter(function (it) {
                if (modGroup(it) !== S.modTab) return false;
                if (S.modChip === 'product' && it.type !== 'PRODUCT') return false;
                if (S.modChip === 'service' && it.type !== 'SERVICE') return false;
                if (S.modChip === 'fail' && it.pass) return false;
                if (q && (it.title + ' ' + it.shop).toLocaleLowerCase('vi-VN').indexOf(q) < 0) return false;
                return true;
            });
            var shown = S.modExpand ? list : list.slice(0, 5);

            var tabs = [['pending', 'Chờ duyệt', groups.pending], ['approved', 'Đã duyệt', groups.approved], ['rejected', 'Từ chối / Cần sửa', groups.rejected]].map(function (t) {
                return '<button type="button" class="um-tab' + (S.modTab === t[0] ? ' active' : '') + '" data-act="mod-tab" data-tab="' + t[0] + '">' + t[1] + ' (' + nfmt(t[2]) + ')</button>';
            }).join('');
            var chips = [['all', 'Tất cả loại'], ['product', 'Sản phẩm'], ['service', 'Dịch vụ gia công']].concat(S.modTab === 'pending' ? [['fail', 'Không đạt tự động (' + autoFail + ')']] : []).map(function (c) {
                return '<button type="button" class="um-chip' + (S.modChip === c[0] ? ' active' : '') + '" data-act="mod-chip" data-chip="' + c[0] + '">' + c[1] + '</button>';
            }).join('');

            var cards = shown.map(function (it) {
                var failed = it.checks.filter(function (c) { return !c[1]; }).map(function (c) { return c[0]; });
                var badge = it.status === 'PENDING' ? '<span class="md-badge ' + (it.pass ? 'pass' : 'fail') + '">' + (it.pass ? 'Đạt tự động' : 'Không đạt') + '</span>'
                    : '<span class="md-badge ' + (it.status === 'ACTIVE' ? 'pass' : 'fail') + '">' + (PRODUCT_STATUS_LABELS[it.status] || it.status) + '</span>';
                var btn = function (to, label, cls) { return '<button type="button" class="um-tool ' + cls + '" data-act="mod-act" data-type="' + it.type + '" data-id="' + esc(it.id) + '" data-to="' + to + '">' + label + '</button>'; };
                var actions = it.status === 'PENDING' ? btn('NEEDS_EDIT', 'Yêu cầu sửa', '') + btn('REJECTED', 'Từ chối', 'danger') + btn('ACTIVE', '✓ Duyệt đăng bán', 'primary')
                    : it.status === 'ACTIVE' ? btn('PENDING', 'Đưa về chờ duyệt', '')
                        : btn('PENDING', 'Đưa về chờ duyệt', '') + btn('ACTIVE', '✓ Duyệt đăng bán', 'primary');
                return '<article class="md-item">' + '<div class="md-top">' + thumbHtml(it) + '<div class="md-body"><div class="md-title"><strong>' + esc(it.title) + '</strong>' + badge + '</div>' +
                    '<div class="md-meta">' + esc(it.meta) + '</div>' + checkList(it.checks) + '</div></div>' +
                    (it.status === 'PENDING' && failed.length ? '<div class="md-reason">✕ Chưa đạt: ' + esc(failed.join('; ')) + '.</div>' : '') +
                    '<div class="sh-card-foot"><button type="button" class="link-btn" data-act="mod-detail" data-key="' + it.key + '">Xem chi tiết</button><div class="sh-card-actions">' + actions + '</div></div></article>';
            }).join('');

            return '<div class="um-stats">' +
                userStat('🕑', 'tone-orange', 'Chờ duyệt', groups.pending, groups.pending ? '▼ Cần xử lý' : 'Hàng đợi trống', groups.pending ? 'down' : '') +
                userStat('✅', 'tone-green', 'Đạt tự động', autoPass, 'Có thể duyệt hàng loạt', autoPass ? 'up' : '') +
                userStat('✕', 'tone-red', 'Không đạt tự động', autoFail, autoFail ? 'Cần xem lại thủ công' : '') +
                userStat('📦', 'tone-blue', 'Đã duyệt', groups.approved, '') + '</div>' +
                '<section class="um-card"><nav class="um-tabs">' + tabs + '</nav>' +
                '<div class="um-filters"><div class="um-chips">' + chips + '</div><div class="um-tools">' +
                (S.modTab === 'pending' ? '<button type="button" class="um-tool" data-act="mod-bulk">✓ Duyệt hàng loạt mục đạt</button>' : '') + '</div></div>' +
                '<div class="md-list">' + (cards || '<div class="sh-empty">Không có mục nào trong danh sách này.</div>') + '</div>' +
                (!S.modExpand && list.length > 5 ? '<div class="sh-more"><button type="button" class="um-tool" data-act="mod-expand">Xem ' + (list.length - 5) + ' mục còn lại</button></div>' : '') + '</section>' +
                '<div class="note-banner info">Hệ thống tự kiểm 4 tiêu chí (thông tin cơ bản, độ dài mô tả, thông số bắt buộc, dữ liệu tương thích) cho sản phẩm; dịch vụ gia công kiểm mô tả, giá, thời gian và tư cách xưởng. Sản phẩm chỉ hiển thị cho khách sau khi được duyệt (trạng thái "Đang bán").</div>';
        }
        function moderate(type, id, to) {
            return call({action: 'moderate', type: type, id: id, status: to}, function (r) {
                if (r.products) S.products = r.products;
                if (r.services) S.services = r.services;
            });
        }

        /* ================= Danh mục kỹ thuật ================= */
        var CAT_ATTRS = [
            {key: 'layout', label: 'Layout', uc: true}, {key: 'mount_type', label: 'Kiểu mount', uc: true},
            {key: 'pin_type', label: 'Loại pin / chân switch', uc: true}, {key: 'switch_type', label: 'Loại switch', uc: false},
            {key: 'actuation_force', label: 'Lực nhấn', uc: false}, {key: 'brand', label: 'Thương hiệu', uc: false}
        ];
        var COMPAT_RULES = [
            ['Switch đời cũ phải khớp socket hotswap', 'Chân switch đời cũ dày hơn chuẩn MX sẽ làm hỏng socket của kit.', 'Chặn'],
            ['Số chân switch phải khớp PCB', 'Kit chỉ hỗ trợ 3-pin thì switch 5-pin cần cắt chân phụ trước khi lắp.', 'Chặn'],
            ['Layout keycap phải khớp kit', 'Keycap ISO không vừa kit layout ANSI.', 'Chặn'],
            ['Bộ keycap phải đủ phím cho layout', 'Bộ base 60% thiếu phím điều hướng và F-row cho kit TKL trở lên.', 'Chặn'],
            ['Kiểu mount stabilizer phải khớp PCB', 'Stab plate-mount không gắn được vào PCB chỉ khoét lỗ PCB-mount.', 'Chặn']
        ];
        function catProducts(catId) { return S.products.filter(function (p) { return String(p.category_id) === String(catId); }); }
        function groupBy(list, key) {
            var map = {};
            list.forEach(function (p) { var v = String(p[key] || '').trim(); if (v) map[v] = (map[v] || 0) + 1; });
            return Object.keys(map).map(function (k) { return [k, map[k]]; }).sort(function (a, b) { return b[1] - a[1]; });
        }
        function catChildren(list) {
            var best = null, bestFill = 0;
            ['layout', 'switch_type', 'mount_type', 'brand'].forEach(function (k) {
                var fill = list.filter(function (p) { return String(p[k] || '').trim(); }).length;
                if (fill > bestFill) { bestFill = fill; best = k; }
            });
            return best ? groupBy(list, best).slice(0, 6) : [];
        }
        function renderCategories() {
            var cats = S.categories;
            if (!cats.length) return heading('Danh mục kỹ thuật', 'Chưa có danh mục nào.') + '<div class="sh-empty">Hãy thêm danh mục đầu tiên.</div>';
            if (!byId(cats, S.catSel)) S.catSel = cats[0].id;
            var selected = byId(cats, S.catSel);
            var totalProducts = S.products.length;

            var tree = cats.map(function (c) {
                var list = catProducts(c.id);
                var kids = catChildren(list).map(function (k) {
                    return '<div class="ct-child"><span>' + esc(k[0]) + '</span><em>' + nfmt(k[1]) + '</em></div>';
                }).join('');
                return '<div class="ct-node"><div class="ct-root' + (String(c.id) === String(S.catSel) ? ' active' : '') + '" data-act="cat-select" data-id="' + esc(c.id) + '" role="button" tabindex="0">' +
                    '<span class="ct-icon">' + esc(c.icon || '📁') + '</span><strong>' + esc(c.name) + '</strong><em>' + nfmt(list.length) + '</em>' +
                    '<button type="button" class="link-btn" data-act="cat-edit" data-id="' + esc(c.id) + '">Sửa</button></div>' + kids + '</div>';
            }).join('');

            var list = catProducts(selected.id);
            var attrRows = CAT_ATTRS.map(function (a) {
                var filled = list.filter(function (p) { return String(p[a.key] || '').trim(); }).length;
                var vals = groupBy(list, a.key).slice(0, 4).map(function (v) { return v[0]; }).join(', ');
                var pct = list.length ? Math.round(filled / list.length * 100) : 0;
                return '<tr><td><strong>' + esc(a.label) + '</strong><small class="cell-sub">' + esc(vals || 'Chưa có dữ liệu') + '</small></td>' +
                    '<td class="um-num">' + nfmt(filled) + '/' + nfmt(list.length) + ' <span class="' + (pct >= 80 ? 'rate-good' : 'rate-bad') + '">(' + pct + '%)</span></td>' +
                    '<td class="um-num"><input type="checkbox" disabled' + (a.uc ? ' checked' : '') + ' aria-label="Dùng cho UC27"></td></tr>';
            }).join('');
            var ruleRows = COMPAT_RULES.map(function (r) {
                return '<tr><td><strong>' + esc(r[0]) + '</strong><small class="cell-sub wrap">' + esc(r[1]) + '</small></td><td><span class="um-state um-state-blocked">' + r[2] + '</span></td></tr>';
            }).join('');

            return '<div class="ct-grid"><section class="um-card"><div class="ct-head"><div><h3>Cây danh mục</h3><p>' + nfmt(cats.length) + ' danh mục · ' + nfmt(totalProducts) + ' sản phẩm</p></div>' +
                '<button type="button" class="um-tool primary" data-act="cat-add">+ Thêm danh mục</button></div><div class="ct-tree">' + tree + '</div></section>' +
                '<div class="ct-side"><section class="um-card"><div class="ct-head"><div><h3>Thuộc tính của “' + esc(selected.name) + '”</h3><p>Mức độ khai báo thuộc tính của các sản phẩm trong danh mục</p></div></div>' +
                '<div class="table-scroll"><table class="um-table"><thead><tr><th>Thuộc tính</th><th class="um-num">Đã khai báo</th><th class="um-num">Dùng cho UC27</th></tr></thead><tbody>' + attrRows + '</tbody></table></div></section>' +
                '<section class="um-card"><div class="ct-head"><div><h3>Quy tắc tương thích (UC27)</h3><p>Quy tắc Custom Builder đang áp dụng (cố định trong mã nguồn)</p></div></div>' +
                '<div class="table-scroll"><table class="um-table"><thead><tr><th>Quy tắc</th><th>Mức</th></tr></thead><tbody>' + ruleRows + '</tbody></table></div></section></div></div>';
        }
        function slugify(text) {
            return String(text || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/đ/g, 'd').replace(/Đ/g, 'd').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
        }
        function categoryFields(cat) {
            return [
                {key: 'name', label: 'Tên danh mục', value: cat ? cat.name : '', required: true, full: true},
                {key: 'slug', label: 'Slug', value: cat ? cat.slug : '', help: 'Để trống để tự tạo từ tên. Chỉ gồm chữ thường, số, dấu gạch ngang.'},
                {key: 'icon', label: 'Biểu tượng (emoji)', value: cat ? cat.icon : '', placeholder: '⌨️'}
            ];
        }
        function saveCategoryForm(form, id) {
            form.action = 'saveCategory'; form.id = id;
            if (!form.slug) form.slug = slugify(form.name);
            return call(form, function (r) { if (r.categories) S.categories = r.categories; if (!id && r.id) S.catSel = r.id; });
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
                '<div class="chart-panel-head"><div>' +
                '<h3>Biểu đồ tròn trạng thái đơn hàng</h3>' +
                '<p>Tỷ lệ trạng thái hiện tại của tất cả đơn hàng trong database</p>' +
                '</div></div>' +
                '<div class="pie-chart-layout">' +
                '<div class="pie-canvas-wrap"><canvas id="orderStatusPieChart" aria-label="Biểu đồ tròn trạng thái đơn hàng" role="img"></canvas></div>' +
                '<div id="order-pie-legend" class="pie-legend"></div>' +
                '</div>' +
                '</div>' +

                '<div class="category-payment-charts">' +

                '<div class="chart-panel pie-panel">' +
                '<div class="chart-panel-head">' +
                '<div>' +
                '<h3>Sản phẩm theo danh mục</h3>' +
                '<p>Phân bố số lượng sản phẩm theo từng danh mục</p>' +
                '</div>' +
                '</div>' +
                '<div class="pie-chart-layout">' +
                '<div class="pie-canvas-wrap">' +
                '<canvas id="categoryPieChart"></canvas>' +
                '</div>' +
                '<div id="category-pie-legend" class="pie-legend"></div>' +
                '</div>' +
                '</div>' +

                '<div class="chart-panel pie-panel">' +
                '<div class="chart-panel-head">' +
                '<div>' +
                '<h3>Đơn hàng theo phương thức thanh toán</h3>' +
                '<p>Phân bố đơn hàng theo phương thức thanh toán</p>' +
                '</div>' +
                '</div>' +
                '<div class="pie-chart-layout">' +
                '<div class="pie-canvas-wrap">' +
                '<canvas id="paymentPieChart"></canvas>' +
                '</div>' +
                '<div id="payment-pie-legend" class="pie-legend"></div>' +
                '</div>' +
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
            drawCategoryPieChart();
            drawPaymentPieChart();
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
                PENDING: 'Chờ xác nhận',
                CONFIRMED: 'Đã xác nhận',
                PROCESSING: 'Đang xử lý',
                SHIPPING: 'Đang giao',
                SHIPPED: 'Đã giao',
                COMPLETED: 'Hoàn thành',
                CANCELLED: 'Đã hủy',
                UNKNOWN: 'Chưa xác định'
            };

            var colors = {
                PENDING: '#f59e0b',
                CONFIRMED: '#3b82f6',
                PROCESSING: '#8b5cf6',
                SHIPPING: '#06b6d4',
                SHIPPED: '#14b8a6',
                COMPLETED: '#10b981',
                CANCELLED: '#ef4444',
                UNKNOWN: '#94a3b8'
            };

            var keys = Object.keys(breakdown).filter(function(k) {
                return Number(breakdown[k]) > 0;
            });
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

        function drawCategoryPieChart() {
            if (categoryPieChartInstance) {
                categoryPieChartInstance.destroy();
                categoryPieChartInstance = null;
            }

            var canvas = $('categoryPieChart');
            var legend = $('category-pie-legend');

            if (!canvas || !legend) return;

            if (typeof Chart === 'undefined') {
                legend.textContent = 'Không tải được thư viện Chart.js.';
                return;
            }

            // Đếm số sản phẩm trong từng danh mục.
            var categoryCounts = {};

            (S.products || []).forEach(function(product) {
                var category = product.category_name || 'Chưa phân loại';

                categoryCounts[category] =
                    (categoryCounts[category] || 0) + 1;
            });

            var labels = Object.keys(categoryCounts);
            var values = labels.map(function(category) {
                return categoryCounts[category];
            });

            var total = values.reduce(function(sum, value) {
                return sum + value;
            }, 0);

            if (total === 0) {
                legend.textContent = 'Chưa có dữ liệu sản phẩm.';
                return;
            }

            var colors = [
                '#2563eb',
                '#10b981',
                '#f59e0b',
                '#ef4444',
                '#8b5cf6',
                '#06b6d4',
                '#ec4899',
                '#64748b'
            ];

            legend.innerHTML = labels.map(function(label, index) {
                    var count = values[index];

                    return '<div class="pie-legend-row">' +
                        '<span class="pie-dot" style="background:' +
                        colors[index % colors.length] + '"></span>' +
                        '<span>' + esc(label) + '</span>' +
                        '<strong>' + count + ' (' +
                        (count / total * 100).toFixed(1) + '%)</strong>' +
                        '</div>';
                }).join('') +
                '<div class="pie-legend-total">Tổng sản phẩm: <strong>' +
                total + '</strong></div>';

            categoryPieChartInstance = new Chart(canvas.getContext('2d'), {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: labels.map(function(_, index) {
                            return colors[index % colors.length];
                        }),
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function(item) {
                                    var count = item.raw;
                                    var percent = (count / total * 100).toFixed(1);

                                    return ' ' + item.label + ': ' +
                                        count + ' sản phẩm (' + percent + '%)';
                                }
                            }
                        }
                    }
                }
            });
        }

        function drawPaymentPieChart() {
            if (paymentPieChartInstance) {
                paymentPieChartInstance.destroy();
                paymentPieChartInstance = null;
            }

            var canvas = $('paymentPieChart');
            var legend = $('payment-pie-legend');

            if (!canvas || !legend) return;

            if (typeof Chart === 'undefined') {
                legend.textContent = 'Không tải được thư viện Chart.js.';
                return;
            }

            // Đếm số đơn hàng theo phương thức thanh toán.
            var paymentCounts = {};

            (S.orders || []).forEach(function(order) {
                var payment = order.payment_method || 'Chưa xác định';

                paymentCounts[payment] =
                    (paymentCounts[payment] || 0) + 1;
            });

            var labels = Object.keys(paymentCounts);
            var values = labels.map(function(payment) {
                return paymentCounts[payment];
            });

            var total = values.reduce(function(sum, value) {
                return sum + value;
            }, 0);

            if (total === 0) {
                legend.textContent = 'Chưa có dữ liệu đơn hàng.';
                return;
            }

            var colors = [
                '#2563eb',
                '#10b981',
                '#f59e0b',
                '#ef4444',
                '#8b5cf6',
                '#06b6d4',
                '#ec4899'
            ];

            legend.innerHTML = labels.map(function(label, index) {
                    var count = values[index];

                    return '<div class="pie-legend-row">' +
                        '<span class="pie-dot" style="background:' +
                        colors[index % colors.length] + '"></span>' +
                        '<span>' + esc(label) + '</span>' +
                        '<strong>' + count + ' (' +
                        (count / total * 100).toFixed(1) + '%)</strong>' +
                        '</div>';
                }).join('') +
                '<div class="pie-legend-total">Tổng đơn hàng: <strong>' +
                total + '</strong></div>';

            paymentPieChartInstance = new Chart(canvas.getContext('2d'), {
                type: 'pie',
                data: {
                    labels: labels,
                    datasets: [{
                        data: values,
                        backgroundColor: labels.map(function(_, index) {
                            return colors[index % colors.length];
                        }),
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function(item) {
                                    var count = item.raw;
                                    var percent = (count / total * 100).toFixed(1);

                                    return ' ' + item.label + ': ' +
                                        count + ' đơn (' + percent + '%)';
                                }
                            }
                        }
                    }
                }
            });
        }

        function refreshOrderAnalytics() {
            // Tải lại dữ liệu thống kê sau khi trạng thái đơn hàng đã được ghi vào MySQL.
            // DAO trả về breakdown trạng thái toàn bộ đơn hàng, không phụ thuộc bộ lọc ngày doanh thu.
            return post({ action: 'getRevenueStats', from_date: '', to_date: '' })
                .then(function (res) {
                    if (!res || !res.success || !res.revStats) {
                        throw new Error((res && res.message) || 'Máy chủ không trả về dữ liệu thống kê.');
                    }
                    S.revenueStats = res.revStats;
                    // Nếu trang thống kê đang mở, hủy và vẽ lại biểu đồ với dữ liệu mới.
                    if (S.page === 'analytics') renderPage();
                    return true;
                })
                .catch(function (error) {
                    console.error('Không thể làm mới biểu đồ sau khi cập nhật đơn hàng:', error);
                    toast('Đã cập nhật đơn hàng nhưng chưa tải lại được biểu đồ. Hãy mở lại mục Thống kê biểu đồ.', true);
                    return false;
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
            $('quick-search').placeholder = (page === 'dashboard' || page === 'analytics') ? 'Tìm nhanh trong các mục...': 'Tìm trong ' + (page === 'users' ? 'người dùng': page === 'shops' ? 'cửa hàng': (page === 'products' || page === 'moderation') ? 'sản phẩm': page === 'categories' ? 'danh mục': 'đơn hàng') + '...';
            Array.prototype.forEach.call(document.querySelectorAll('[data-page]'), function (button) {
                if (button.classList.contains('nav-item')) button.classList.toggle('active', button.dataset.page === page);
            });
            if (page === 'users') $('main-content').innerHTML = renderUsers();
            else if (page === 'products') $('main-content').innerHTML = renderProducts();
            else if (page === 'orders') $('main-content').innerHTML = renderOrders();
            else if (page === 'shops') $('main-content').innerHTML = renderShops();
            else if (page === 'moderation') $('main-content').innerHTML = renderModeration();
            else if (page === 'categories') $('main-content').innerHTML = renderCategories();
            else if (page === 'analytics') {
                $('main-content').innerHTML = renderAnalytics();
                afterRenderAnalytics();
            }
            else $('main-content').innerHTML = renderDashboard();
            updateEyebrow(page);
            updateBadges();
        }
        function updateBadges() {
            var pendingShops = S.shopsFull.filter(function (s) { return shopState(s) === 'pending'; }).length;
            var pm = pendingModCount();
            [['badge-shops', pendingShops], ['badge-mod', pm]].forEach(function (b) {
                var el = $(b[0]); if (!el) return;
                el.hidden = !b[1]; el.textContent = b[1];
            });
        }
        function updateEyebrow(page) {
            var el = $('page-eyebrow');
            if (!el) return;
            if (page === 'shops') {
                var sf = S.shopsFull;
                el.textContent = nfmt(sf.length) + ' shop · ' + sf.filter(function (s) { return shopState(s) === 'pending'; }).length + ' chờ duyệt · ' + sf.filter(function (s) { return shopState(s) === 'watch'; }).length + ' đang theo dõi';
                return;
            }
            if (page === 'moderation') { el.textContent = nfmt(pendingModCount()) + ' mục chờ duyệt'; return; }
            if (page === 'categories') { el.textContent = 'KEEBHUB / DANH MỤC'; return; }
            if (page !== 'users') { el.textContent = 'KEEBHUB / ADMIN'; return; }
            var today = new Date().toDateString();
            var todayNew = S.users.filter(function (u) { var d = parseDate(u.created_at); return d && d.toDateString() === today; }).length;
            el.textContent = nfmt(S.users.length) + ' tài khoản · ' + nfmt(todayNew) + ' đăng ký mới hôm nay';
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
        function userFields(user) {
            var creating = !user;
            return [
                {key:'first_name', label:'Họ', value:user ? user.first_name: '', required:true},
                {key:'last_name', label:'Tên', value:user ? user.last_name: '', required:true},
                {key:'email', label:'Email', type:'email', value:user ? user.email: '', required:true},
                {key:'password', label:creating ? 'Mật khẩu': 'Mật khẩu mới', type:'password', value:'', required:creating, autocomplete:'new-password', help:creating ? 'Ít nhất 6 ký tự.': 'Để trống nếu không muốn đổi mật khẩu.'},
                {key:'role', label:'Vai trò', type:'select', options:USER_ROLES, value:user ? user.role: 'CUSTOMER', required:true},
                {key:'status', label:'Trạng thái', type:'select', options:USER_STATUSES, value:user ? user.status: 'ACTIVE', required:true}
            ].concat(creating ? [] : [
                {key:'phone_view', label:'Điện thoại', value:user.phone || '—', readonly:true},
                {key:'joined_view', label:'Tham gia', value:user.created_at ? String(user.created_at).slice(0, 10) : '—', readonly:true},
                {key:'orders_view', label:isStaff(user) ? 'Số đơn' : 'Số đơn', value:isStaff(user) ? '—' : nfmt(user.order_count), readonly:true},
                {key:'spent_view', label:user.role === 'SELLER' ? 'Doanh thu' : 'Chi tiêu', value:isStaff(user) ? '—' : money(user.total_spent), readonly:true}
            ]);
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
            if (action === 'user-detail') {
                var user = byId(S.users, id);
                if (!user) return;
                showModal('Chi tiết người dùng #' + id, userFields(user), function (form) {
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
                        delete S.userSel[id];
                    });
                });
            } else if (action === 'user-tab') {
                S.userTab = button.dataset.tab; S.userPage = 1; renderPage();
            } else if (action === 'user-chip') {
                S.userChip = button.dataset.chip; S.userPage = 1; renderPage();
            } else if (action === 'user-page') {
                if (button.disabled) return;
                S.userPage = Number(button.dataset.pageNo) || 1; renderPage();
            } else if (action === 'export-users') {
                exportUsersCsv();
            } else if (action === 'notify-users') {
                var emails = visibleUsers().filter(function (u) { return S.userSel[u.id]; }).map(function (u) { return u.email; });
                if (!emails.length) { toast('Hãy chọn ít nhất một người dùng để gửi thông báo.', true); return; }
                window.location.href = 'mailto:?bcc=' + encodeURIComponent(emails.join(','));
            } else if (action === 'shop-tab') {
                S.shopTab = button.dataset.tab; S.shopPage = 1; renderPage();
            } else if (action === 'shop-expand') {
                S.shopExpand = true; renderPage();
            } else if (action === 'shop-approve') {
                shopAction(id, 'approveShop');
            } else if (action === 'shop-reject') {
                var rs = byId(S.shopsFull, id);
                if (rs && window.confirm('Từ chối hồ sơ "' + rs.shop_name + '"? Tài khoản chủ shop sẽ bị khoá.')) shopAction(id, 'rejectShop');
            } else if (action === 'shop-profile' || action === 'shop-manage') {
                var sh = byId(S.shopsFull, id);
                if (!sh) return;
                var st = shopState(sh), acts = [];
                if (st === 'pending') {
                    acts.push({label: 'Từ chối', cls: 'btn-danger-light', run: function () { if (window.confirm('Từ chối hồ sơ "' + sh.shop_name + '"? Tài khoản chủ shop sẽ bị khoá.')) shopAction(id, 'rejectShop'); }});
                    acts.push({label: '✓ Duyệt & kích hoạt', cls: 'btn-primary', run: function () { shopAction(id, 'approveShop'); }});
                } else if (st === 'locked') {
                    acts.push({label: 'Mở khoá tài khoản', cls: 'btn-primary', run: function () { shopAction(id, 'unlockShop'); }});
                } else {
                    acts.push({label: 'Khoá tài khoản chủ shop', cls: 'btn-danger-light', run: function () { if (window.confirm('Khoá tài khoản chủ shop "' + sh.shop_name + '"?')) shopAction(id, 'lockShop'); }});
                }
                showInfo((action === 'shop-profile' ? 'Hồ sơ ' : 'Quản lý ') + sh.shop_name, shopInfoRows(sh), acts);
            } else if (action === 'mod-tab') {
                S.modTab = button.dataset.tab; S.modChip = 'all'; S.modExpand = false; renderPage();
            } else if (action === 'mod-chip') {
                S.modChip = button.dataset.chip; S.modExpand = false; renderPage();
            } else if (action === 'mod-expand') {
                S.modExpand = true; renderPage();
            } else if (action === 'mod-act') {
                var to = button.dataset.to;
                if (to === 'REJECTED' && !window.confirm('Từ chối mục này?')) return;
                moderate(button.dataset.type, id, to);
            } else if (action === 'mod-bulk') {
                var autoOk = modItems().filter(function (it) { return it.status === 'PENDING' && it.pass; }).length;
                if (!autoOk) { toast('Không có mục nào đạt đủ tiêu chí để duyệt hàng loạt.', true); return; }
                var bt = S.modChip === 'product' ? 'PRODUCT' : S.modChip === 'service' ? 'SERVICE' : 'ALL';
                if (window.confirm('Duyệt đăng bán các mục đạt đủ tiêu chí tự động?')) {
                    call({action: 'bulkApprove', type: bt}, function (r) { if (r.products) S.products = r.products; if (r.services) S.services = r.services; });
                }
            } else if (action === 'mod-detail') {
                var it = modItems().filter(function (x) { return x.key === button.dataset.key; })[0];
                if (!it) return;
                var raw = it.raw;
                var rows = it.type === 'PRODUCT'
                    ? [['Tên sản phẩm', raw.name, true], ['Cửa hàng', raw.shop_name], ['Danh mục', raw.category_name], ['SKU', raw.sku], ['Thương hiệu', raw.brand], ['Giá bán', money(raw.price)], ['Tồn kho', raw.stock],
                        ['Số dòng thông số', raw.spec_count], ['Số mục tương thích', raw.compat_count], ['Độ dài mô tả', raw.desc_len + ' ký tự'], ['Mô tả', raw.description, true]]
                    : [['Tên dịch vụ', raw.name, true], ['Cửa hàng', raw.shop_name], ['Giá', money(raw.price)], ['Thời gian', raw.duration], ['Độ dài mô tả', raw.desc_len + ' ký tự'], ['Mô tả', raw.description, true]];
                showInfo('Chi tiết ' + (it.type === 'PRODUCT' ? 'sản phẩm' : 'dịch vụ'), rows, []);
            } else if (action === 'cat-select') {
                if (event.target.closest('[data-act="cat-edit"]')) return;
                S.catSel = Number(id); renderPage();
            } else if (action === 'cat-add') {
                showModal('Thêm danh mục', categoryFields(null), function (form) { return saveCategoryForm(form, 0); });
            } else if (action === 'cat-edit') {
                var cat = byId(S.categories, id);
                if (!cat) return;
                showModal('Sửa danh mục #' + id, categoryFields(cat), function (form) { return saveCategoryForm(form, id); });
            } else if (action === 'page-nav') {
                if (button.disabled) return;
                S[button.dataset.key] = Number(button.dataset.pageNo) || 1; renderPage();
            } else if (action === 'add-product') {
                if (!S.shops.length || !S.categories.length) { toast('Cần có ít nhất một cửa hàng và một danh mục trước khi thêm sản phẩm.', true); return; }
                showModal('Thêm sản phẩm', productFields(null), function (form) {
                    form.action = 'saveProduct'; form.id = 0;
                    return call(form, function (result) {
                        var shop = byId(S.shops, form.shop_id), category = byId(S.categories, form.category_id);
                        S.products.unshift({id:result.id, name:form.name, sku:form.sku, shop_id:+form.shop_id, category_id:+form.category_id,
                            shop_name:shop ? shop.shop_name: '', category_name:category ? category.name: '', price:+form.price, stock:+form.stock, status:form.status});
                        S.productPage = 1;
                    });
                });
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
                });
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
                        // Đồng bộ lại số liệu biểu đồ từ CSDL, không tải lại toàn bộ trang.
                        refreshOrderAnalytics();
                    });
                });
            }
        });

        document.addEventListener('change', function (event) {
            var t = event.target;
            if (!t || t.type !== 'checkbox') return;
            if (t.hasAttribute('data-sel-all')) {
                Array.prototype.forEach.call(document.querySelectorAll('input[data-sel]'), function (box) {
                    box.checked = t.checked;
                    if (t.checked) S.userSel[box.dataset.sel] = true; else delete S.userSel[box.dataset.sel];
                });
            } else if (t.hasAttribute('data-sel')) {
                if (t.checked) S.userSel[t.dataset.sel] = true; else delete S.userSel[t.dataset.sel];
                var head = document.querySelector('input[data-sel-all]');
                if (head) head.checked = Array.prototype.every.call(document.querySelectorAll('input[data-sel]'), function (b) { return b.checked; });
            }
        });
        $('quick-search').addEventListener('input', function () {
            S.userPage = 1; S.productPage = 1; S.orderPage = 1; S.shopPage = 1;
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