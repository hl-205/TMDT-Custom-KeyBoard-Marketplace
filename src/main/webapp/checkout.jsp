```
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Thanh toán - KeebHub</title>

  <link rel="stylesheet" href="assets/css/style.css">
  <link rel="stylesheet" href="assets/css/checkout.css">
</head>
<body>
<jsp:include page="includes/header.jsp" />

<main class="container checkout-container">
  <nav class="checkout-steps" aria-label="Các bước thanh toán">
    <span>✓ Giỏ hàng</span>
    <b>›</b>
    <strong>2 · Thông tin &amp; thanh toán</strong>
    <b>›</b>
    <span>3 · Hoàn tất</span>
  </nav>

  <c:if test="${not empty requestScope.error}">
    <div class="alert-error"><c:out value="${requestScope.error}" /></div>
  </c:if>

  <%-- Ưu tiên số giảm giá do CartServlet tính, kế đến session. --%>
  <c:set var="checkoutDiscount" value="${not empty requestScope.appliedCouponDiscount ? requestScope.appliedCouponDiscount : (not empty sessionScope.appliedCouponDiscount ? sessionScope.appliedCouponDiscount : (not empty sessionScope.appliedDiscountAmount ? sessionScope.appliedDiscountAmount : 0))}" />
  <c:set var="checkoutCouponCode" value="${not empty requestScope.appliedCouponCode ? requestScope.appliedCouponCode : sessionScope.appliedCouponCode}" />

  <div class="checkout-layout">
    <form id="checkoutForm"
          class="checkout-form"
          method="post"
          action="${pageContext.request.contextPath}/checkout">

      <input type="hidden"
             id="hiddenCouponCode"
             name="couponCode"
             value="<c:out value='${checkoutCouponCode}' />">

      <!-- 1. Thông tin nhận hàng -->
      <section class="checkout-panel">
        <h2 class="section-heading"><i>1</i> Địa chỉ nhận hàng</h2>
        <p class="section-hint">Nhập trực tiếp thông tin nhận hàng cho đơn này.</p>

        <div class="address-fields">
          <div class="form-group">
            <label for="receiverName">Họ tên người nhận <em>*</em></label>
            <input id="receiverName"
                   name="receiverName"
                   type="text"
                   maxlength="100"
                   placeholder="Họ và tên"
                   value="<c:out value='${customer.fullName}' />"
                   required>
          </div>

          <div class="form-group">
            <label for="receiverPhone">Số điện thoại <em>*</em></label>
            <input id="receiverPhone"
                   name="receiverPhone"
                   type="tel"
                   maxlength="20"
                   placeholder="Số điện thoại liên hệ"
                   value="<c:out value='${customer.phone}' />"
                   required>
          </div>

          <div class="form-group wide">
            <label for="shippingAddress">Địa chỉ nhận hàng chi tiết <em>*</em></label>
            <textarea id="shippingAddress"
                      name="shippingAddress"
                      rows="2"
                      maxlength="255"
                      placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố"
                      required><c:out value="${customer.address}" /></textarea>
          </div>

          <div class="form-group">
            <label for="orderNote">Ghi chú đơn hàng</label>
            <input id="orderNote"
                   type="text"
                   maxlength="255"
                   placeholder="Ghi chú cho người bán (tùy chọn)">
          </div>

          <div class="form-group">
            <label for="orderEmail">Email nhận hóa đơn</label>
            <input id="orderEmail"
                   type="email"
                   placeholder="Địa chỉ email (tùy chọn)">
          </div>
        </div>
      </section>

      <!-- 2. Phương thức vận chuyển -->
      <section class="checkout-panel">
        <h2 class="section-heading"><i>2</i> Phương thức vận chuyển</h2>

        <div class="shipping-options">
          <label class="shipping-card selected">
            <input type="radio" name="shippingMethod" value="STANDARD" data-fee="30000" checked>
            <span>
                            <b>Tiêu chuẩn</b>
                            <small>Giao 3-4 ngày làm việc</small>
                            <strong>30.000₫</strong>
                        </span>
          </label>

          <label class="shipping-card">
            <input type="radio" name="shippingMethod" value="EXPRESS" data-fee="50000">
            <span>
                            <b>Nhanh</b>
                            <small>Giao 1–2 ngày làm việc</small>
                            <strong>50.000₫</strong>
                        </span>
          </label>

          <label class="shipping-card">
            <input type="radio" name="shippingMethod" value="SAME_DAY" data-fee="90000">
            <span>
                            <b>Hỏa tốc</b>
                            <small>Tùy khu vực và khả năng giao hàng</small>
                            <strong>90.000₫</strong>
                        </span>
          </label>
        </div>

        <p class="shipping-note">
          ⓘ Thời gian giao hàng chỉ mang tính tham khảo và có thể thay đổi tùy sản phẩm, khu vực.
        </p>
      </section>

      <!-- 3. Phương thức thanh toán -->
      <section class="checkout-panel">
        <h2 class="section-heading"><i>3</i> Phương thức thanh toán</h2>

        <div class="payment-methods-grid">
          <label class="payment-method-card selected" id="card-vnpay">
            <input type="radio" name="paymentMethod" value="VNPAY-QR" checked>
            <span class="payment-icon-box">▣</span>
            <span class="payment-info">
                            <strong>Ví điện tử / QR Code</strong>
                            <small>Thanh toán qua cổng VNPAY</small>
                        </span>
            <span class="payment-tag">VNPAY</span>
          </label>

          <label class="payment-method-card" id="card-vietqr">
            <input type="radio" name="paymentMethod" value="VIETQR">
            <span class="payment-icon-box">▤</span>
            <span class="payment-info">
                            <strong>Chuyển khoản ngân hàng</strong>
                            <small>Quét mã VietQR để chuyển khoản</small>
                        </span>
            <span class="payment-tag">VIETQR</span>
          </label>

          <label class="payment-method-card" id="card-cod">
            <input type="radio" name="paymentMethod" value="COD">
            <span class="payment-icon-box">▣</span>
            <span class="payment-info">
                            <strong>Thanh toán khi nhận hàng (COD)</strong>
                            <small>Thanh toán cho nhân viên giao hàng</small>
                        </span>
          </label>
        </div>

        <p class="payment-note">🔒 Thanh toán trực tuyến được chuyển đến phương thức thanh toán đã chọn.</p>
      </section>
    </form>

    <!-- Cột phải: Tóm tắt đơn hàng -->
    <aside class="checkout-right">
      <div class="order-summary">
        <div class="summary-header">
          <h2>Đơn hàng</h2>
          <a href="${pageContext.request.contextPath}/cart">Sửa</a>
        </div>

        <div class="summary-items-list">
          <c:set var="total" value="${0}" />
          <c:forEach items="${cartItems}" var="item">
            <c:set var="total" value="${total + item.lineTotal}" />

            <div class="summary-item">
              <div class="summary-thumb">
                <c:choose>
                  <c:when test="${item.product.categoryId == 1}">
                    <div class="illus-kit"></div>
                  </c:when>
                  <c:when test="${item.product.categoryId == 2}">
                    <div class="illus-switch yellow"></div>
                  </c:when>
                  <c:otherwise>
                    <div class="illus-keycap"></div>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="summary-info">
                <p class="summary-name"><c:out value="${item.product.name}" /></p>
                <small>Số lượng: <c:out value="${item.quantity}" /></small>
              </div>

              <b class="item-total">
                <fmt:formatNumber value="${item.lineTotal}" pattern="#,###" />₫
              </b>
            </div>
          </c:forEach>
        </div>

        <%-- Mã giảm giá được chọn ở giỏ hàng; checkout chỉ hiển thị khoản đã giảm. --%>
        <!-- Tổng tiền -->
        <div class="summary-totals">
          <div class="row">
            <span>Tạm tính</span>
            <b><fmt:formatNumber value="${total}" pattern="#,###" />₫</b>
          </div>

          <div id="discountRow"
               class="row discount-row ${checkoutDiscount > 0 ? 'show' : ''}">
            <span>
              Giảm giá (<span id="appliedCodeText"><c:out value="${checkoutCouponCode}" /></span>)
            </span>
            <b id="discountVal">
              -<fmt:formatNumber value="${checkoutDiscount}" pattern="#,###" />₫
            </b>
          </div>

          <div class="row">
            <span>Phí vận chuyển</span>
            <b id="shippingVal">30.000₫</b>
          </div>

          <div class="row grand">
            <strong>Tổng thanh toán</strong>
            <strong id="grandTotalVal"></strong>
          </div>
        </div>

        <label class="terms-row">
          <input form="checkoutForm" type="checkbox" required checked>
          Tôi đã đọc và đồng ý với điều khoản mua hàng
        </label>

        <button form="checkoutForm"
                type="submit"
                id="submitOrderBtn"
                class="submit-order">
          Đặt hàng &amp; thanh toán
        </button>
      </div>

      <div class="trust-box">
        <p>🔒 Thanh toán qua phương thức đã chọn</p>
        <p>↩ Theo dõi đơn hàng trong tài khoản của bạn</p>
        <p>🛡 Hỗ trợ khách hàng khi cần thiết</p>
      </div>
    </aside>
  </div>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
  const baseSubtotal = Number('${total}') || 0;
  const currentDiscount = Number('${checkoutDiscount}') || 0;

  const formatCurrency = amount => new Intl.NumberFormat('vi-VN').format(amount) + '₫';
  const byId = id => document.getElementById(id);

  const paymentButtons = {
    'COD': 'Đặt hàng (COD)',
    'VNPAY-QR': 'Đặt hàng & thanh toán VNPAY',
    'VIETQR': 'Mở mã QR thanh toán Napas VietQR'
  };

  // Đổi lựa chọn thanh toán và nội dung nút đặt hàng.
  function selectPaymentMethod(method) {
    document.querySelectorAll('.payment-method-card').forEach(card => {
      const radio = card.querySelector('input[name="paymentMethod"]');
      const selected = radio.value === method;
      radio.checked = selected;
      card.classList.toggle('selected', selected);
    });

    byId('submitOrderBtn').textContent = paymentButtons[method] || 'Đặt hàng & thanh toán';
  }

  // Mã giảm giá lấy từ giỏ hàng, chỉ thay đổi phí khi chọn vận chuyển.
  function updateTotal() {
    const selectedShipping = document.querySelector('input[name="shippingMethod"]:checked');
    const shippingFee = selectedShipping ? Number(selectedShipping.dataset.fee) : 0;
    const grandTotal = Math.max(0, baseSubtotal - currentDiscount + shippingFee);

    byId('shippingVal').textContent = shippingFee === 0 ? 'Miễn phí' : formatCurrency(shippingFee);
    byId('grandTotalVal').textContent = formatCurrency(grandTotal);

    document.querySelectorAll('.shipping-card').forEach(card => {
      card.classList.toggle('selected', card.querySelector('input').checked);
    });
  }

  // Khởi tạo sự kiện giao diện.
  document.querySelectorAll('input[name="shippingMethod"]').forEach(radio => {
    radio.addEventListener('change', updateTotal);
  });

  document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
    radio.addEventListener('change', () => selectPaymentMethod(radio.value));
  });

  const initialPayment = document.querySelector('input[name="paymentMethod"]:checked');
  if (initialPayment) {
    selectPaymentMethod(initialPayment.value);
  }

  updateTotal();
</script>
</body>
</html>

```