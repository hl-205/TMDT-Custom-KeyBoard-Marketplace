<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kết quả thanh toán - KeebHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
    <style>
        .result-container {
            max-width: 680px;
            margin: 50px auto;
            padding: 0 16px;
        }
        .result-card {
            background: #fff;
            border-radius: 20px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 12px 36px rgba(15, 23, 42, 0.08);
            padding: 40px 36px;
            text-align: center;
        }
        .status-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
        }
        .icon-success {
            background: #DCFCE7;
            color: #16A34A;
        }
        .icon-fail {
            background: #FEE2E2;
            color: #DC2626;
        }
        .result-title {
            font-size: 24px;
            font-weight: 800;
            color: #0F172A;
            margin: 0 0 10px 0;
        }
        .result-desc {
            font-size: 14px;
            color: #64748B;
            margin: 0 0 28px 0;
            line-height: 1.5;
        }
        .receipt-box {
            background: #F8FAFC;
            border: 1px dashed #CBD5E1;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 28px;
            text-align: left;
        }
        .receipt-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            border-bottom: 1px solid #F1F5F9;
            font-size: 14px;
        }
        .receipt-row:last-child {
            border-bottom: none;
            padding-top: 12px;
            margin-top: 4px;
            font-weight: 700;
            font-size: 16px;
            color: #0F172A;
        }
        .receipt-label {
            color: #64748B;
        }
        .receipt-value {
            font-weight: 600;
            color: #1E293B;
        }
        .receipt-value.price {
            color: #2563EB;
            font-weight: 800;
            font-size: 18px;
        }
        .result-actions {
            display: flex;
            gap: 14px;
            justify-content: center;
        }
        .result-actions .btn {
            padding: 13px 24px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 15px;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-blue {
            background: #2563EB;
            color: #fff;
        }
        .btn-blue:hover {
            background: #1D4ED8;
        }
        .btn-light {
            background: #F1F5F9;
            color: #475569;
        }
        .btn-light:hover {
            background: #E2E8F0;
        }
    </style>
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="result-container">
    <div class="result-card">
        <c:choose>
            <c:when test="${isSuccess}">
                <div class="status-icon icon-success">✓</div>
                <h1 class="result-title">Thanh toán trực tuyến thành công!</h1>
                <p class="result-desc">
                    <c:out value="${message}"/><br>
                    Cảm ơn bạn đã tin tưởng mua sắm tại <strong>KeebHub Marketplace</strong>.
                </p>

                <div class="receipt-box">
                    <div class="receipt-row">
                        <span class="receipt-label">Mã đơn hàng:</span>
                        <span class="receipt-value">#<c:out value="${orderCode}"/></span>
                    </div>
                    <c:if test="${not empty transactionNo}">
                        <div class="receipt-row">
                            <span class="receipt-label">Mã giao dịch đối tác:</span>
                            <span class="receipt-value"><c:out value="${transactionNo}"/></span>
                        </div>
                    </c:if>
                    <c:if test="${not empty bankCode}">
                        <div class="receipt-row">
                            <span class="receipt-label">Phương thức / Ngân hàng:</span>
                            <span class="receipt-value"><c:out value="${bankCode}"/></span>
                        </div>
                    </c:if>
                    <c:if test="${not empty payDate}">
                        <div class="receipt-row">
                            <span class="receipt-label">Thời gian thanh toán:</span>
                            <span class="receipt-value"><c:out value="${payDate}"/></span>
                        </div>
                    </c:if>
                    <div class="receipt-row">
                        <span class="receipt-label">Tổng tiền đã thanh toán:</span>
                        <span class="receipt-value price">
                            <fmt:formatNumber value="${amount}" pattern="#,###"/>₫
                        </span>
                    </div>
                </div>

                <div class="result-actions">
                    <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-blue">📦 Xem đơn hàng của tôi</a>
                    <a href="${pageContext.request.contextPath}/category" class="btn btn-light">Tiếp tục mua sắm</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="status-icon icon-fail">✕</div>
                <h1 class="result-title">Thanh toán không thành công</h1>
                <p class="result-desc">
                    <c:out value="${message}"/><br>
                    Đơn hàng của bạn vẫn được bảo lưu ở trạng thái chờ thanh toán.
                </p>

                <div class="receipt-box">
                    <div class="receipt-row">
                        <span class="receipt-label">Mã đơn hàng:</span>
                        <span class="receipt-value">#<c:out value="${orderCode}"/></span>
                    </div>
                    <div class="receipt-row">
                        <span class="receipt-label">Số tiền cần thanh toán:</span>
                        <span class="receipt-value price">
                            <fmt:formatNumber value="${amount}" pattern="#,###"/>₫
                        </span>
                    </div>
                </div>

                <div class="result-actions">
                    <c:choose>
                        <c:when test="${not empty order}">
                            <a href="${pageContext.request.contextPath}/vnpay-payment?orderId=${order.id}" class="btn btn-blue">Thử lại thanh toán</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-blue">Xem đơn hàng</a>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/my-orders" class="btn btn-light">Về danh sách đơn hàng</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

</body>
</html>
