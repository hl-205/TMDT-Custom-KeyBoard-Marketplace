<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Order" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn hàng của tôi - KeebHub</title>

    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/features.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />
<main class="container">
    <h1 class="page-title">Lịch sử mua hàng</h1>

    <div class="card">
        <%
            List<Order> orders = (List<Order>) request.getAttribute("orders");
            if (orders != null && !orders.isEmpty()) {
                Locale localeVN = new Locale("vi", "VN");
                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(localeVN);
        %>
        <table>
            <thead>
            <tr>
                <th>Mã đơn hàng</th>
                <th>Ngày đặt</th>
                <th>Tổng tiền</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (Order o : orders) {
                    String status = o.getOrderStatus() != null ? o.getOrderStatus() : "PENDING";
                    String statusClass = "status-" + status;
                    String dateStr = o.getCreatedAt() != null ? o.getCreatedAt().toString().replace(".0", "") : "";
            %>
            <tr>
                <td class="order-code"><%= o.getOrderCode() %></td>
                <td class="order-date"><%= dateStr %></td>
                <td class="price"><%= currencyFormatter.format(o.getTotalAmount()) %></td>
                <td>
                        <span class="status-badge <%= statusClass %>">
                            <%= status %>
                        </span>
                </td>
                <td>
                    <a href="order-detail?id=<%= o.getId() %>" class="btn-detail">Chi tiết</a>
                </td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
        <%
        } else {
        %>
        <div class="empty-state">
            <p>Bạn chưa có đơn hàng nào.</p>
            <a href="products" class="btn-home">Khám phá sản phẩm</a>
        </div>
        <%
            }
        %>
    </div>
</main>
<jsp:include page="includes/footer.jsp" />
</body>
</html>