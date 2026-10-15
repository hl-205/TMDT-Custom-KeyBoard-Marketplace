<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />
<main class="wrap">
    <h1>Admin</h1>
    <p>Quản lý Admin.</p>

    <div class="stats">
        <div class="stat">Người dùng<br><strong>${stats.userCount}</strong></div>
        <div class="stat">Đơn hàng<br><strong>${stats.orderCount}</strong></div>
        <div class="stat">Sản phẩm<br><strong>${stats.productCount}</strong></div>
        <div class="stat">Tổng giá trị đơn không hủy<br><strong>${stats.totalOrdersValue} đ</strong></div>
    </div>

    <section class="panel">
        <h2>Người dùng</h2>
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
                    <td>${u.id}</td>
                    <td><c:out value="${u.first_name}"/> <c:out value="${u.last_name}"/></td>
                    <td><c:out value="${u.email}"/></td>
                    <td>${u.role}</td>
                    <td>${u.status}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/admin">
                            <input type="hidden" name="action" value="userStatus">
                            <input type="hidden" name="id" value="${u.id}">
                            <select name="status">
                                <option value="ACTIVE">ACTIVE</option>
                                <option value="INACTIVE">INACTIVE</option>
                                <option value="BLOCKED">BLOCKED</option>
                            </select>
                            <button type="submit">Cập nhật</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>

    <section class="panel">
        <h2>Đơn hàng</h2>
        <table>
            <thead>
            <tr>
                <th>Mã</th>
                <th>Người nhận</th>
                <th>Email</th>
                <th>Tổng tiền</th>
                <th>Trạng thái</th>
                <th>Cập nhật</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${orders}" var="o">
                <tr>
                    <td><c:out value="${o.order_code}"/></td>
                    <td><c:out value="${o.receiver_name}"/></td>
                    <td><c:out value="${o.customer_email}"/></td>
                    <td>${o.total_amount} đ</td>
                    <td>${o.order_status}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/admin">
                            <input type="hidden" name="action" value="orderStatus">
                            <input type="hidden" name="id" value="${o.id}">
                            <select name="status">
                                <option>PENDING</option>
                                <option>CONFIRMED</option>
                                <option>PROCESSING</option>
                                <option>SHIPPED</option>
                                <option>COMPLETED</option>
                                <option>CANCELLED</option>
                            </select>
                            <button type="submit">Cập nhật</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>

    <section class="panel">
        <h2>Sản phẩm</h2>
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
                    <td>${p.id}</td>
                    <td><c:out value="${p.name}"/></td>
                    <td><c:out value="${p.sku}"/></td>
                    <td><c:out value="${p.shop_name}"/></td>
                    <td>${p.price} đ</td>
                    <td>${p.stock}</td>
                    <td>${p.status}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/admin" style="display:inline-block;">
                            <input type="hidden" name="action" value="productStatus">
                            <input type="hidden" name="id" value="${p.id}">
                            <select name="status">
                                <option>ACTIVE</option>
                                <option>INACTIVE</option>
                            </select>
                            <button type="submit">Cập nhật</button>
                        </form>
                        <form method="post" action="${pageContext.request.contextPath}/admin" onsubmit="return confirm('Xóa sản phẩm này?')" style="display:inline-block;">
                            <input type="hidden" name="action" value="deleteProduct">
                            <input type="hidden" name="id" value="${p.id}">
                            <button type="submit">Xóa</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </section>
</main>
<jsp:include page="includes/footer.jsp" />
</body>
</html>