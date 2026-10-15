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
    <link rel="stylesheet" href="assets/css/features.css">

    <!-- Chart.js CDN để vẽ biểu đồ tròn -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<jsp:include page="includes/header.jsp" />
<main class="wrap">
    <!-- Header Admin -->
    <div class="admin-header">
        <h1>Bảng Quản Trị Hệ Thống</h1>
        <p>Thống kê số liệu tổng quan và quản lý Người dùng, Đơn hàng, Sản phẩm trên KeebHub.</p>
    </div>

    <!-- 1. THỐNG KÊ NHANH (CARDS DẠNG CỘT CHUẨN UX/UI) -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-details">
                <div class="stat-title">Người dùng</div>
                <div class="stat-value">${stats.userCount}</div>
            </div>
            <div class="stat-icon icon-blue">👥</div>
        </div>

        <div class="stat-card">
            <div class="stat-details">
                <div class="stat-title">Đơn hàng</div>
                <div class="stat-value">${stats.orderCount}</div>
            </div>
            <div class="stat-icon icon-purple">🛒</div>
        </div>

        <div class="stat-card">
            <div class="stat-details">
                <div class="stat-title">Sản phẩm</div>
                <div class="stat-value">${stats.productCount}</div>
            </div>
            <div class="stat-icon icon-orange">📦</div>
        </div>

        <div class="stat-card">
            <div class="stat-details">
                <div class="stat-title">Doanh thu đơn không hủy</div>
                <div class="stat-value">
                    <fmt:formatNumber value="${stats.totalOrdersValue}" type="number" groupingUsed="true"/> ₫
                </div>
            </div>
            <div class="stat-icon icon-green">💰</div>
        </div>
    </div>

    <!-- 2. BIỂU ĐỒ TRÒN THỐNG KÊ ĐỘNG (ROLES & TRẠNG THÁI ĐƠN HÀNG) -->
    <div class="charts-grid">
        <!-- Biểu đồ 1: Cơ cấu tất cả Roles (Động cho CUSTOM, SELLER, ADMIN, MODERATOR...) -->
        <div class="panel" style="margin: 0;">
            <div class="panel-header">
                <h2>👥 Tỉ lệ Vai trò (Role) người dùng</h2>
            </div>
            <div class="chart-layout">
                <div class="chart-box">
                    <canvas id="userRoleChart"></canvas>
                </div>
                <ul class="legend-list">
                    <c:choose>
                        <c:when test="${not empty stats.roleStats}">
                            <c:forEach items="${stats.roleStats}" var="r">
                                <li>
                                    <span>🔷 Vai trò <strong>${r.key}</strong></span>
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

        <!-- Biểu đồ 2: Trạng thái Đơn hàng (Động) -->
        <div class="panel" style="margin: 0;">
            <div class="panel-header">
                <h2>🛒 Tỉ lệ Trạng thái Đơn hàng</h2>
            </div>
            <div class="chart-layout">
                <div class="chart-box">
                    <canvas id="orderStatusChart"></canvas>
                </div>
                <ul class="legend-list">
                    <c:choose>
                        <c:when test="${not empty stats.orderStatusStats}">
                            <c:forEach items="${stats.orderStatusStats}" var="s">
                                <li>
                                    <span>📙 Trạng thái <strong>${s.key}</strong></span>
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
    <div class="admin-tabs">
        <button class="tab-btn active" onclick="switchTab('users', this)">
            👥 Quản lý người dùng
        </button>
        <button class="tab-btn" onclick="switchTab('orders', this)">
            🛒 Quản lý đơn hàng
        </button>
        <button class="tab-btn" onclick="switchTab('products', this)">
            📦 Quản lý sản phẩm
        </button>
    </div>

    <!-- TAB 1: QUẢN LÝ NGƯỜI DÙNG -->
    <div id="tab-users" class="tab-pane active">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách người dùng</h2>
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
                    <tbody>
                    <c:forEach items="${users}" var="u">
                        <tr>
                            <td><strong>#${u.id}</strong></td>
                            <td><c:out value="${u.first_name}"/> <c:out value="${u.last_name}"/></td>
                            <td><c:out value="${u.email}"/></td>
                            <td>
                                <span class="badge-status ${u.role == 'ADMIN' ? 'status-CANCELLED' : (u.role == 'SELLER' ? 'status-CONFIRMED' : 'status-ACTIVE')}">
                                        ${u.role}
                                </span>
                            </td>
                            <td>
                                <span class="badge-status status-${u.status}">
                                        ${u.status}
                                </span>
                            </td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline-flex; gap:6px;">
                                    <input type="hidden" name="action" value="userStatus">
                                    <input type="hidden" name="id" value="${u.id}">
                                    <select name="status">
                                        <option value="ACTIVE" ${u.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="INACTIVE" ${u.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                        <option value="BLOCKED" ${u.status == 'BLOCKED' ? 'selected' : ''}>BLOCKED</option>
                                    </select>
                                    <button type="submit" class="btn-action btn-update">Cập nhật</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <!-- TAB 2: QUẢN LÝ ĐƠN HÀNG -->
    <div id="tab-orders" class="tab-pane">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách đơn hàng</h2>
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
                        <th>Cập nhật trạng thái</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${orders}" var="o">
                        <tr>
                            <td><strong><c:out value="${o.order_code}"/></strong></td>
                            <td><c:out value="${o.receiver_name}"/></td>
                            <td><c:out value="${o.customer_email}"/></td>
                            <td style="font-weight:700; color:#ea580c;">
                                <fmt:formatNumber value="${o.total_amount}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td>
                                <span class="badge-status status-${o.order_status}">
                                        ${o.order_status}
                                </span>
                            </td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline-flex; gap:6px;">
                                    <input type="hidden" name="action" value="orderStatus">
                                    <input type="hidden" name="id" value="${o.id}">
                                    <select name="status">
                                        <option value="PENDING" ${o.order_status == 'PENDING' ? 'selected' : ''}>PENDING</option>
                                        <option value="CONFIRMED" ${o.order_status == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                                        <option value="PROCESSING" ${o.order_status == 'PROCESSING' ? 'selected' : ''}>PROCESSING</option>
                                        <option value="SHIPPED" ${o.order_status == 'SHIPPED' ? 'selected' : ''}>SHIPPED</option>
                                        <option value="COMPLETED" ${o.order_status == 'COMPLETED' ? 'selected' : ''}>COMPLETED</option>
                                        <option value="CANCELLED" ${o.order_status == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                                    </select>
                                    <button type="submit" class="btn-action btn-update">Cập nhật</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </div>

    <!-- TAB 3: QUẢN LÝ SẢN PHẨM -->
    <div id="tab-products" class="tab-pane">
        <section class="panel">
            <div class="panel-header">
                <h2>Danh sách sản phẩm</h2>
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
                    <tbody>
                    <c:forEach items="${products}" var="p">
                        <tr>
                            <td><strong>#${p.id}</strong></td>
                            <td><c:out value="${p.name}"/></td>
                            <td><c:out value="${p.sku}"/></td>
                            <td><c:out value="${p.shop_name}"/></td>
                            <td style="font-weight:700; color:#ea580c;">
                                <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/> ₫
                            </td>
                            <td>${p.stock}</td>
                            <td>
                                <span class="badge-status status-${p.status}">
                                        ${p.status}
                                </span>
                            </td>
                            <td>
                                <div style="display:inline-flex; gap:6px;">
                                    <form method="post" action="${pageContext.request.contextPath}/admin" style="margin:0;">
                                        <input type="hidden" name="action" value="productStatus">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <select name="status">
                                            <option value="ACTIVE" ${p.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                            <option value="INACTIVE" ${p.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                        </select>
                                        <button type="submit" class="btn-action btn-update">Sửa</button>
                                    </form>

                                    <form method="post" action="${pageContext.request.contextPath}/admin" onsubmit="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?')" style="margin:0;">
                                        <input type="hidden" name="action" value="deleteProduct">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <button type="submit" class="btn-action btn-delete">Xóa</button>
                                    </form>
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
<jsp:include page="includes/footer.jsp" />

<!-- SCRIPT VẼ BIỂU ĐỒ & XỬ LÝ CHUYỂN TAB -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const colorPalette = [
            '#2563eb', '#16a34a', '#dc2626', '#7c3aed',
            '#ea580c', '#0891b2', '#ec4899', '#84cc16'
        ];

        // 1. Biểu đồ vai trò người dùng (Tự động thích ứng với CUSTOM, ADMIN, SELLER...)
        const roleLabels = [
            <c:forEach items="${stats.roleStats}" var="r" varStatus="loop">
            "${r.key}"${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        const roleData = [
            <c:forEach items="${stats.roleStats}" var="r" varStatus="loop">
            ${r.value}${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        const ctxRole = document.getElementById('userRoleChart');
        if (ctxRole && roleLabels.length > 0) {
            new Chart(ctxRole.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: roleLabels,
                    datasets: [{
                        data: roleData,
                        backgroundColor: colorPalette.slice(0, roleLabels.length),
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    cutout: '65%'
                }
            });
        }

        // 2. Biểu đồ trạng thái đơn hàng (PENDING, COMPLETED, CANCELLED...)
        const orderStatusLabels = [
            <c:forEach items="${stats.orderStatusStats}" var="s" varStatus="loop">
            "${s.key}"${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        const orderStatusData = [
            <c:forEach items="${stats.orderStatusStats}" var="s" varStatus="loop">
            ${s.value}${!loop.last ? ',' : ''}
            </c:forEach>
        ];

        const ctxOrder = document.getElementById('orderStatusChart');
        if (ctxOrder && orderStatusLabels.length > 0) {
            new Chart(ctxOrder.getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: orderStatusLabels,
                    datasets: [{
                        data: orderStatusData,
                        backgroundColor: ['#f59e0b', '#2563eb', '#16a34a', '#dc2626', '#8b5cf6', '#64748b'].slice(0, orderStatusLabels.length),
                        borderWidth: 2,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    cutout: '65%'
                }
            });
        }
    });

    // Chuyển Tab
    function switchTab(tabName, element) {
        document.querySelectorAll('.tab-pane').forEach(pane => pane.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));

        document.getElementById('tab-' + tabName).classList.add('active');
        element.classList.add('active');
    }
</script>

</body>
</html>