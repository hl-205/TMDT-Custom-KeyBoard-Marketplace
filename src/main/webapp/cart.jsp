<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.math.BigDecimal,model.CartItem" %>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="assets/css/features.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />

    <%
        String err = (String) session.getAttribute("flashError");
        if (err != null) {
    %>
    <p class="error"><%= err %></p>
    <%
            session.removeAttribute("flashError");
        }
    %>

    <%
        Collection<CartItem> items = (Collection<CartItem>) request.getAttribute("cartItems");
        BigDecimal total = BigDecimal.ZERO;
        if (items == null || items.isEmpty()) {
    %>
    <div class="cart-empty">
        <p class="cart-empty-text">Không có gì</p>
        <a href="${pageContext.request.contextPath}/shop" class="button">Tiếp tục mua sắm</a>
    </div>
    <%
    } else {
    %>
    <table>
        <thead>
        <tr>
            <th>Sản phẩm</th>
            <th>Đơn giá</th>
            <th>Số lượng</th>
            <th>Tạm tính</th>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <%
            for (CartItem i : items) {
                total = total.add(i.getLineTotal());
        %>
        <tr>
            <td><%= i.getProduct().getName() %></td>
            <td><%= i.getProduct().getPrice() %> ₫</td>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/cart">
                    <input type="hidden" name="productId" value="<%= i.getProduct().getId() %>">
                    <input type="hidden" name="action" value="update">
                    <input type="number" name="quantity" min="1" max="99" value="<%= i.getQuantity() %>">
                    <button type="submit">Cập nhật</button>
                </form>
            </td>
            <td><%= i.getLineTotal() %> ₫</td>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/cart">
                    <input type="hidden" name="productId" value="<%= i.getProduct().getId() %>">
                    <input type="hidden" name="action" value="remove">
                    <button type="submit">Xóa</button>
                </form>
            </td>
        </tr>
        <%  } %>
        </tbody>
    </table>

    <h2>Tổng cộng: <%= total %> ₫</h2>
    <a class="button" href="${pageContext.request.contextPath}/checkout">Tiến hành đặt hàng</a>
    <%  } %>
</main>
<jsp:include page="includes/footer.jsp" />
</body>
</html>