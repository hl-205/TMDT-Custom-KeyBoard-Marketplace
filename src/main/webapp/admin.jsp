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

    <!-- CSS Hệ thống & CSS Admin riêng -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
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

    <!-- 2. THANH CHUYỂN TAB CÁC CHỨC NĂNG QUẢN LÝ -->
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
                                <span class="badge-status ${u.role == 'ADMIN' ? 'status-CONFIRMED' : 'status-ACTIVE'}">
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

<!-- JAVASCRIPT CHUYỂN TAB MƯỢT MÀ -->
<script>
    function switchTab(tabName, element) {
        // 1. Dừng hiển thị tất cả các tab
        const tabPanes = document.querySelectorAll('.tab-pane');
        tabPanes.forEach(pane => pane.classList.remove('active'));

        // 2. Bỏ trạng thái active của tất cả các nút
        const tabBtns = document.querySelectorAll('.tab-btn');
        tabBtns.forEach(btn => btn.classList.remove('active'));

        // 3. Bật Tab được chọn & nút tương ứng
        document.getElementById('tab-' + tabName).classList.add('active');
        element.classList.add('active');
    }
</script>

</body>
</html>