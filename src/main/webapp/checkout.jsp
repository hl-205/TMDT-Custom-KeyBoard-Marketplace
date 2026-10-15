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
  <!-- Chuyển checkout.css xuống cuối để đè các file CSS khác -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css">
</head>
<body>

<main class="container checkout-container">
  <h1 class="page-title">Thông tin đặt hàng</h1>

  <c:if test="${not empty error}">
    <div class="alert-error">
      <c:out value="${error}"/>
    </div>
  </c:if>

  <div class="checkout-layout">

    <!-- BÊN TRÁI: Form thông tin giao hàng (Form 1) -->
    <form method="post" action="${pageContext.request.contextPath}/checkout" class="checkout-form">
      <div class="form-body">
        <h2 class="form-section-title">1. Thông tin người nhận</h2>

        <div class="form-group">
          <label for="receiverName">Họ và tên người nhận <span class="required">*</span></label>
          <input type="text" id="receiverName" name="receiverName" required maxlength="100" placeholder="Ví dụ: Nguyễn Văn A">
        </div>

        <div class="form-group">
          <label for="receiverPhone">Số điện thoại <span class="required">*</span></label>
          <input type="tel" id="receiverPhone" name="receiverPhone" required maxlength="20" placeholder="Ví dụ: 0912345678">
        </div>

        <div class="form-group">
          <label for="shippingAddress">Địa chỉ giao hàng <span class="required">*</span></label>
          <textarea id="shippingAddress" name="shippingAddress" required maxlength="255" rows="4" placeholder="Nhập địa chỉ nhận hàng chi tiết (Số nhà, tên đường, phường/xã, quận/huyện...)"></textarea>
        </div>
      </div>

      <div class="checkout-actions">
        <button type="submit" class="btn btn-primary">Xác nhận đặt hàng (COD)</button>
        <a href="#" class="btn btn-outline">Thanh toán trực tuyến</a>
      </div>
    </form>

    <!-- BÊN PHẢI: Tóm tắt sản phẩm (Form 2 / Order Summary) -->
    <aside class="order-summary">
      <h2 class="summary-title">Sản phẩm trong đơn</h2>

      <div class="summary-items-list">
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
                  <span class="summary-price">
                    <fmt:formatNumber value="${item.product.price}" pattern="#,###"/>₫
                  </span>
                  <c:if test="${item.product.oldPrice > item.product.price}">
                    <span class="summary-old">
                      <fmt:formatNumber value="${item.product.oldPrice}" pattern="#,###"/>₫
                    </span>
                  </c:if>
                </span>
                <span class="summary-qty">x${item.quantity}</span>
              </div>
              <div class="summary-line-total">
                <fmt:formatNumber value="${item.lineTotal}" pattern="#,###"/>₫
              </div>
            </div>
          </div>
        </c:forEach>
      </div>

      <div class="summary-totals">
        <div class="row">
          <span>Tạm tính</span>
          <span><fmt:formatNumber value="${total}" pattern="#,###"/>₫</span>
        </div>
        <div class="row">
          <span>Phí vận chuyển</span>
          <span class="free-shipping">Thỏa thuận</span>
        </div>
        <div class="row grand">
          <span>Tổng cộng</span>
          <span class="grand-total"><fmt:formatNumber value="${total}" pattern="#,###"/>₫</span>
        </div>
      </div>

      <a class="summary-back" href="${pageContext.request.contextPath}/cart">
        &larr; Quay lại giỏ hàng
      </a>
    </aside>

  </div>
</main>

</body>
</html>