<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.Order" %>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử mua hàng</title>
    <link rel="stylesheet" href="assets/css/features.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />
<main class="container">
    <h1>Lịch sử mua hàng</h1>

    <% if ("1".equals(request.getParameter("success"))) { %>
    <p class="success">Đặt hàng thành công!</p>
    <% } %>

    <table>
        <thead>
        <tr>
            <th>Mã đơn</th>
            <th>Ngày đặt</th>
            <th>Tổng tiền</th>
            <th>Trạng thái</th>
        </tr>
        </thead>
        <tbody>
        <%
            List<Order> orders = (List<Order>) request.getAttribute("orders");
            if (orders != null) {
                for (Order o : orders) {
        %>
        <tr>
            <td><%= o.getOrderCode() %></td>
            <td><%= o.getCreatedAt() %></td>
            <td><%= o.getTotalAmount() %> ₫</td>
            <td><%= o.getOrderStatus() %></td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
    <a href="${pageContext.request.contextPath}/shop">Tiếp tục mua sắm</a>
</main>
<jsp:include page="includes/header.jsp" />
</body>
</html>