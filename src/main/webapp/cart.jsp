<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,java.math.BigDecimal,model.CartItem" %>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />

<main class="container">
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
        <a href="${pageContext.request.contextPath}/shop" class="btn-home">Tiếp tục mua sắm</a>
    </div>
    <%
    } else {
    %>
    <div class="card">
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
                <td class="price"><%= i.getProduct().getPrice() %> ₫</td>
                <td>
                    <form method="post" action="${pageContext.request.contextPath}/cart" style="display:inline-flex; gap: 4px;">
                        <input type="hidden" name="productId" value="<%= i.getProduct().getId() %>">
                        <input type="hidden" name="action" value="update">
                        <input type="number" name="quantity" min="1" max="99" value="<%= i.getQuantity() %>">
                        <button type="submit" class="btn-action btn-update">Cập nhật</button>
                    </form>
                </td>
                <td class="price"><%= i.getLineTotal() %> ₫</td>
                <td>
                    <form method="post" action="${pageContext.request.contextPath}/cart">
                        <input type="hidden" name="productId" value="<%= i.getProduct().getId() %>">
                        <input type="hidden" name="action" value="remove">
                        <button type="submit" class="btn-action btn-delete">Xóa</button>
                    </form>
                </td>
            </tr>
            <%  } %>
            </tbody>
        </table>
    </div>

    <h2 style="margin-top: 20px;">Tổng cộng: <span class="price" style="font-size: 24px;"><%= total %> ₫</span></h2>
    <a class="btn-home" href="${pageContext.request.contextPath}/checkout" style="margin-top: 12px; display: inline-block;">Tiến hành đặt hàng</a>
    <%  } %>
</main>

<jsp:include page="includes/footer.jsp" />
</body>
</html>