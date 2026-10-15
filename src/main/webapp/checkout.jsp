<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đặt hàng - KeebHub</title>
  <link rel="stylesheet" href="assets/css/features.css">
  <link rel="stylesheet" href="assets/css/style.css">
  <link rel="stylesheet" href="assets/css/checkout.css">
</head>
<body>
<main class="container">
  <h1>Thông tin đặt hàng</h1>

  <c:if test="${not empty error}">
    <p class="error"><c:out value="${error}"/></p>
  </c:if>

  <div class="checkout-layout">

    <!-- BÊN TRÁI: thông tin giao hàng -->
    <form method="post" action="${pageContext.request.contextPath}/checkout" class="checkout-form">
      <label>Người nhận</label>
      <input name="receiverName" required maxlength="100">

      <label>Số điện thoại</label>
      <input name="receiverPhone" required maxlength="20">

      <label>Địa chỉ giao hàng</label>
      <textarea name="shippingAddress" required maxlength="255"></textarea>

      <div class="checkout-actions">
        <button type="submit">Xác nhận đặt hàng</button>
        <a href="#" class="button button-outline">Thanh toán trực tuyến</a>
      </div>
    </form>

    <!-- BÊN PHẢI: thông tin sản phẩm trong đơn -->
    <aside class="order-summary">
      <h2>Sản phẩm trong đơn</h2>

      <c:set var="total" value="${0}"/>
      <c:forEach items="${cartItems}" var="item">
        <c:set var="total" value="${total + item.lineTotal}"/>
        <div class="summary-item">
          <div class="summary-thumb">
            <c:choose>
              <c:when test="${item.product.categoryId == 1}"><div class="illus-kit"></div></c:when>
              <c:when test="${item.product.categoryId == 2}"><div class="illus-switch yellow"></div></c:when>
              <c:when test="${item.product.categoryId == 3}"><div class="illus-keycap"></div></c:when>
              <c:otherwise><div class="illus-switch purple"></div></c:otherwise>
            </c:choose>
          </div>
          <div class="summary-info">
            <p class="summary-name"><c:out value="${item.product.name}"/></p>
            <c:if test="${not empty item.product.shopName}">
              <div class="summary-shop"><c:out value="${item.product.shopName}"/></div>
            </c:if>
            <div class="summary-price-row">
              <span>
                <span class="summary-price">${item.product.formattedPrice}</span>
                <c:if test="${item.product.oldPrice > item.product.price}">
                  <span class="summary-old">${item.product.formattedOldPrice}</span>
                </c:if>
              </span>
              <span class="summary-qty">× ${item.quantity}</span>
            </div>
            <div class="summary-line-total">
              <fmt:formatNumber value="${item.lineTotal}" pattern="#,###"/>₫
            </div>
          </div>
        </div>
      </c:forEach>

      <div class="summary-totals">
        <div class="row">
          <span>Tạm tính</span>
          <span><fmt:formatNumber value="${total}" pattern="#,###"/>₫</span>
        </div>
        <div class="row">
          <span>Phí vận chuyển</span>
          <span>Thỏa thuận</span>
        </div>
        <div class="row grand">
          <span>Tổng cộng</span>
          <span><fmt:formatNumber value="${total}" pattern="#,###"/>₫</span>
        </div>
      </div>

      <a class="summary-back" href="${pageContext.request.contextPath}/cart">← Quay lại giỏ hàng</a>
    </aside>

  </div>
</main>
</body>
</html>
