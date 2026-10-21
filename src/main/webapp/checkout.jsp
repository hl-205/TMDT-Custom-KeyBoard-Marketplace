<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đặt hàng & Thanh toán - KeebHub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/checkout.css">
  <style>
    /* Bổ sung phong cách thanh toán và voucher */
    .payment-methods-grid {
      display: grid;
      gap: 12px;
      margin-top: 8px;
    }
    .payment-method-card {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 14px 18px;
      border: 1.5px solid #E2E8F0;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.2s ease;
      background: #FFFFFF;
    }
    .payment-method-card:hover {
      border-color: #3B82F6;
      background: #F8FAFC;
    }
    .payment-method-card.selected {
      border-color: #2563EB;
      background: #EFF6FF;
      box-shadow: 0 0 0 1px #2563EB;
    }
    .payment-method-card input[type="radio"] {
      width: 18px !important;
      height: 18px !important;
      cursor: pointer;
      accent-color: #2563EB;
      margin: 0 !important;
    }
    .payment-icon-box {
      width: 44px;
      height: 44px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
      background: #F1F5F9;
      flex-shrink: 0;
    }
    .payment-info strong {
      display: block;
      font-size: 14px;
      color: #0F172A;
      margin-bottom: 2px;
    }
    .payment-info span {
      display: block;
      font-size: 12px;
      color: #64748B;
    }
    .voucher-box {
      margin-top: 20px;
      padding: 18px;
      background: #F8FAFC;
      border: 1px dashed #CBD5E1;
      border-radius: 12px;
    }
    .voucher-box-title {
      font-size: 14px;
      font-weight: 700;
      color: #1E293B;
      margin-bottom: 10px;
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .voucher-input-group {
      display: flex;
      gap: 8px;
    }
    .voucher-input-group input {
      flex: 1;
      padding: 10px 14px !important;
      font-size: 14px !important;
      text-transform: uppercase;
      font-weight: 700;
      letter-spacing: 0.5px;
      border: 1.5px solid #CBD5E1 !important;
      border-radius: 8px !important;
    }
    .btn-apply-coupon {
      padding: 10px 16px;
      background: #1E293B;
      color: #FFFFFF;
      font-weight: 700;
      font-size: 13px;
      border: none;
      border-radius: 8px;
      cursor: pointer;
      transition: background 0.2s;
      white-space: nowrap;
    }
    .btn-apply-coupon:hover {
      background: #0F172A;
    }
    .coupon-tags-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      margin-top: 10px;
    }
    .coupon-tag {
      font-size: 11px;
      font-weight: 700;
      color: #2563EB;
      background: #EFF6FF;
      border: 1px solid #BFDBFE;
      padding: 3px 8px;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .coupon-tag:hover {
      background: #DBEAFE;
      border-color: #93C5FD;
    }
    .coupon-alert {
      margin-top: 10px;
      padding: 8px 12px;
      border-radius: 6px;
      font-size: 12px;
      display: none;
    }
    .coupon-alert.success {
      background: #ECFDF5;
      color: #065F46;
      border: 1px solid #A7F3D0;
      display: block;
    }
    .coupon-alert.error {
      background: #FEF2F2;
      color: #991B1B;
      border: 1px solid #FECACA;
      display: block;
    }
    .discount-row {
      display: none;
      color: #16A34A !important;
      font-weight: 700;
    }
    .discount-row.show {
      display: flex !important;
    }
    .btn-remove-coupon {
      color: #EF4444;
      font-size: 11px;
      font-weight: 700;
      cursor: pointer;
      margin-left: 6px;
      text-decoration: underline;
    }
  </style>
</head>
<body>

<jsp:include page="includes/header.jsp"/>

<main class="container checkout-container">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
    <h1 class="page-title" style="margin-bottom:0;">Thông tin đặt hàng & Thanh toán</h1>
    <a href="${pageContext.request.contextPath}/profile" style="font-size:13px;color:#2563EB;text-decoration:none;font-weight:600;">
      👤 Quản lý thông tin hồ sơ
    </a>
  </div>

  <c:if test="${not empty error}">
    <div class="alert-error">
      <c:out value="${error}"/>
    </div>
  </c:if>

  <div class="checkout-layout">

    <!-- BÊN TRÁI: Form thông tin giao hàng & Phương thức thanh toán -->
    <form id="checkoutForm" method="post" action="${pageContext.request.contextPath}/checkout" class="checkout-form">
      <input type="hidden" id="hiddenCouponCode" name="couponCode" value="${sessionScope.appliedCouponCode}">
      
      <div class="form-body">
        <h2 class="form-section-title">1. Thông tin người nhận</h2>

        <div class="form-group">
          <label for="receiverName">Họ và tên người nhận <span class="required">*</span></label>
          <input type="text" id="receiverName" name="receiverName" required maxlength="100" 
                 value="<c:out value='${not empty customer.fullName ? customer.fullName : ""}'/>" 
                 placeholder="Ví dụ: Nguyễn Văn A">
        </div>

        <div class="form-group">
          <label for="receiverPhone">Số điện thoại liên hệ <span class="required">*</span></label>
          <input type="tel" id="receiverPhone" name="receiverPhone" required maxlength="20" 
                 value="<c:out value='${not empty customer.phone ? customer.phone : ""}'/>" 
                 placeholder="Ví dụ: 0912345678">
        </div>

        <div class="form-group">
          <label for="shippingAddress">Địa chỉ giao hàng <span class="required">*</span></label>
          <textarea id="shippingAddress" name="shippingAddress" required maxlength="255" rows="3" 
                    placeholder="Nhập địa chỉ nhận hàng chi tiết (Số nhà, tên đường, phường/xã, quận/huyện...)"><c:out value='${not empty customer.address ? customer.address : ""}'/></textarea>
        </div>

        <h2 class="form-section-title" style="margin-top: 16px;">2. Phương thức thanh toán</h2>

        <div class="payment-methods-grid">
          <!-- COD -->
          <label class="payment-method-card selected" id="card-cod" onclick="selectPaymentMethod('COD')">
            <input type="radio" name="paymentMethod" value="COD" checked>
            <div class="payment-icon-box">💵</div>
            <div class="payment-info">
              <strong>Thanh toán khi nhận hàng (COD)</strong>
              <span>Kiểm tra hàng hóa và thanh toán trực tiếp cho nhân viên giao hàng</span>
            </div>
          </label>

          <!-- VNPAY -->
          <label class="payment-method-card" id="card-vnpay" onclick="selectPaymentMethod('VNPAY-QR')">
            <input type="radio" name="paymentMethod" value="VNPAY-QR">
            <div class="payment-icon-box" style="background:#EBF5FF; color:#1D4ED8; font-weight:800; font-size:14px;">VNP</div>
            <div class="payment-info">
              <strong>Cổng thanh toán trực tuyến VNPAY</strong>
              <span>Hỗ trợ quét mã VNPAY-QR, Thẻ ATM nội địa (NCB, Vietcombank...), Thẻ Visa/Master</span>
            </div>
          </label>

          <!-- VietQR Napas 247 -->
          <label class="payment-method-card" id="card-vietqr" onclick="selectPaymentMethod('VIETQR')">
            <input type="radio" name="paymentMethod" value="VIETQR">
            <div class="payment-icon-box" style="background:#FEF3C7; color:#D97706; font-size:18px;">📱</div>
            <div class="payment-info">
              <strong>Chuyển khoản trực tuyến Napas VietQR</strong>
              <span>Tạo mã QR tự động kèm đúng số tiền và nội dung đơn hàng, xác nhận tức thì</span>
            </div>
          </label>
        </div>
      </div>

      <div class="checkout-actions">
        <button type="submit" id="submitOrderBtn" class="btn btn-primary">
          Xác nhận đặt hàng (COD)
        </button>
      </div>
    </form>

    <!-- BÊN PHẢI: Tóm tắt sản phẩm & Mã khuyến mãi -->
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

      <!-- KHUNG MÃ KHUYẾN MÃI -->
      <div class="voucher-box">
        <div class="voucher-box-title">
          🎟️ Mã khuyến mãi KeebHub
        </div>
        <div class="voucher-input-group">
          <input type="text" id="couponInput" placeholder="Nhập mã voucher..." maxlength="30">
          <button type="button" id="btnApplyCoupon" class="btn-apply-coupon" onclick="applyCoupon()">
            Áp dụng
          </button>
        </div>

        <div id="couponAlert" class="coupon-alert"></div>

        <!-- Danh sách voucher gợi ý -->
        <c:if test="${not empty availableCoupons}">
          <div style="font-size:12px;color:#64748B;margin-top:10px;">Gợi ý mã hot cho bạn:</div>
          <div class="coupon-tags-wrap">
            <c:forEach items="${availableCoupons}" var="cp">
              <span class="coupon-tag" onclick="selectCouponCode('${cp.code}')" title="${cp.description}">
                🏷️ ${cp.code} (${cp.formattedDiscount})
              </span>
            </c:forEach>
          </div>
        </c:if>
      </div>

      <div class="summary-totals">
        <div class="row">
          <span>Tạm tính</span>
          <span id="subtotalVal"><fmt:formatNumber value="${total}" pattern="#,###"/>₫</span>
        </div>
        <c:choose>
          <c:when test="${not empty sessionScope.appliedCouponCode && not empty sessionScope.appliedDiscountAmount}">
            <div class="row discount-row show" id="discountRow">
              <span>
                Giảm giá voucher (<span id="appliedCodeText">${sessionScope.appliedCouponCode}</span>)
                <span class="btn-remove-coupon" onclick="removeCoupon()">[Bỏ]</span>
              </span>
              <span id="discountVal">-<fmt:formatNumber value="${sessionScope.appliedDiscountAmount}" pattern="#,###"/>₫</span>
            </div>
          </c:when>
          <c:otherwise>
            <div class="row discount-row" id="discountRow">
              <span>
                Giảm giá voucher (<span id="appliedCodeText"></span>)
                <span class="btn-remove-coupon" onclick="removeCoupon()">[Bỏ]</span>
              </span>
              <span id="discountVal">-0₫</span>
            </div>
          </c:otherwise>
        </c:choose>
        <div class="row">
          <span>Phí vận chuyển</span>
          <span class="free-shipping">Thỏa thuận</span>
        </div>
        <div class="row grand">
          <span>Tổng thanh toán</span>
          <c:set var="finalPayTotal" value="${total}"/>
          <c:if test="${not empty sessionScope.appliedDiscountAmount}">
            <c:set var="finalPayTotal" value="${total - sessionScope.appliedDiscountAmount}"/>
            <c:if test="${finalPayTotal < 0}">
              <c:set var="finalPayTotal" value="${0}"/>
            </c:if>
          </c:if>
          <span class="grand-total" id="grandTotalVal"><fmt:formatNumber value="${finalPayTotal}" pattern="#,###"/>₫</span>
        </div>
      </div>

      <a class="summary-back" href="${pageContext.request.contextPath}/cart">
        &larr; Quay lại giỏ hàng
      </a>
    </aside>

  </div>
</main>

<jsp:include page="includes/footer.jsp"/>

<script>
var baseSubtotal = ${total};

function selectPaymentMethod(method) {
  document.getElementById('card-cod').classList.remove('selected');
  document.getElementById('card-vnpay').classList.remove('selected');
  document.getElementById('card-vietqr').classList.remove('selected');

  var btn = document.getElementById('submitOrderBtn');
  var radio = document.querySelector('input[name="paymentMethod"][value="' + method + '"]');
  if (radio) radio.checked = true;

  if (method === 'COD') {
    document.getElementById('card-cod').classList.add('selected');
    btn.innerText = "Xác nhận đặt hàng (COD)";
    btn.style.background = "#2563EB";
  } else if (method === 'VNPAY-QR') {
    document.getElementById('card-vnpay').classList.add('selected');
    btn.innerText = "Tiến hành thanh toán VNPAY";
    btn.style.background = "#1D4ED8";
  } else if (method === 'VIETQR') {
    document.getElementById('card-vietqr').classList.add('selected');
    btn.innerText = "Mở mã QR thanh toán Napas VietQR";
    btn.style.background = "#D97706";
  }
}

function selectCouponCode(code) {
  document.getElementById('couponInput').value = code;
  applyCoupon();
}

function applyCoupon() {
  var code = document.getElementById('couponInput').value.trim();
  var alertBox = document.getElementById('couponAlert');
  if (!code) {
    alertBox.className = "coupon-alert error";
    alertBox.innerText = "Vui lòng nhập mã khuyến mãi.";
    return;
  }

  fetch('${pageContext.request.contextPath}/apply-coupon', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    },
    body: 'code=' + encodeURIComponent(code) + '&subtotal=' + baseSubtotal
  })
  .then(function(res) { return res.json(); })
  .then(function(data) {
    if (data.success) {
      alertBox.className = "coupon-alert success";
      alertBox.innerText = data.message;
      document.getElementById('hiddenCouponCode').value = data.code;
      document.getElementById('appliedCodeText').innerText = data.code;
      document.getElementById('discountVal').innerText = "-" + data.formattedDiscount;
      document.getElementById('discountRow').classList.add('show');
      document.getElementById('grandTotalVal').innerText = data.formattedFinalTotal;
    } else {
      alertBox.className = "coupon-alert error";
      alertBox.innerText = data.message;
      removeCouponUI();
    }
  })
  .catch(function(err) {
    alertBox.className = "coupon-alert error";
    alertBox.innerText = "Lỗi kết nối máy chủ. Vui lòng thử lại.";
  });
}

function removeCoupon() {
  fetch('${pageContext.request.contextPath}/apply-coupon', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    },
    body: 'remove=true'
  })
  .then(function(res) { return res.json(); })
  .then(function(data) {
    removeCouponUI();
    var alertBox = document.getElementById('couponAlert');
    alertBox.className = "coupon-alert success";
    alertBox.innerText = "Đã gỡ mã khuyến mãi.";
  });
}

function removeCouponUI() {
  document.getElementById('hiddenCouponCode').value = "";
  document.getElementById('couponInput').value = "";
  document.getElementById('discountRow').classList.remove('show');
  document.getElementById('discountVal').innerText = "-0₫";
  var formatted = new Intl.NumberFormat('vi-VN').format(baseSubtotal) + "₫";
  document.getElementById('grandTotalVal').innerText = formatted;
}
</script>

</body>
</html>