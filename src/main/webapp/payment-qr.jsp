<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thanh toán chuyển khoản VietQR - KeebHub</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/features.css">
    <style>
        .qr-pay-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 16px;
        }
        .qr-pay-card {
            background: #fff;
            border-radius: 20px;
            border: 1px solid #E2E8F0;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }
        .qr-pay-header {
            background: linear-gradient(135deg, #1E40AF 0%, #3B82F6 100%);
            color: #fff;
            padding: 24px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .qr-pay-header h1 {
            font-size: 22px;
            font-weight: 800;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .qr-grid {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 32px;
            padding: 32px;
            align-items: center;
        }
        @media (max-width: 768px) {
            .qr-grid {
                grid-template-columns: 1fr;
            }
        }
        .qr-image-box {
            background: #F8FAFC;
            border: 2px dashed #CBD5E1;
            border-radius: 16px;
            padding: 20px;
            text-align: center;
        }
        .qr-image-box img {
            width: 100%;
            max-width: 280px;
            height: auto;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        }
        .qr-timer {
            margin-top: 12px;
            font-size: 13px;
            color: #EA580C;
            font-weight: 700;
        }
        .qr-info-table {
            width: 100%;
            border-collapse: collapse;
        }
        .qr-info-table tr {
            border-bottom: 1px solid #F1F5F9;
        }
        .qr-info-table td {
            padding: 12px 0;
            font-size: 14px;
        }
        .qr-info-table td:first-child {
            color: #64748B;
            width: 40%;
        }
        .qr-info-table td:last-child {
            font-weight: 700;
            color: #0F172A;
            text-align: right;
        }
        .highlight-amount {
            color: #DC2626 !important;
            font-size: 20px !important;
            font-weight: 800 !important;
        }
        .copy-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            color: #2563EB;
            cursor: pointer;
            margin-left: 6px;
            background: #EFF6FF;
            padding: 2px 8px;
            border-radius: 6px;
        }
        .qr-actions {
            margin-top: 24px;
            display: flex;
            gap: 12px;
        }
        .qr-actions .btn {
            flex: 1;
            padding: 14px;
            border-radius: 10px;
            font-weight: 700;
            text-align: center;
            text-decoration: none;
            cursor: pointer;
            border: none;
            font-size: 15px;
        }
    </style>
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="qr-pay-container">
    <div class="qr-pay-card">
        <div class="qr-pay-header">
            <div>
                <h1>📱 Thanh toán trực tuyến Napas VietQR</h1>
                <p style="margin: 4px 0 0 0; font-size: 13px; opacity: 0.9;">Mở ứng dụng ngân hàng bất kỳ để quét mã QR thanh toán nhanh</p>
            </div>
            <div style="background: rgba(255,255,255,0.2); padding: 6px 14px; border-radius: 20px; font-size: 13px; font-weight: 700;">
                Mã đơn: #${order.orderCode}
            </div>
        </div>

        <div class="qr-grid">
            <div class="qr-image-box">
                <!-- Mã QR tạo tự động theo chuẩn VietQR Napas 247 -->
                <img src="https://img.vietqr.io/image/MB-0987654321-compact2.png?amount=${order.totalAmount}&addInfo=${order.orderCode}&accountName=KEEBHUB%20MARKETPLACE" alt="Mã VietQR Thanh Toán">
                <div class="qr-timer">
                    ⏳ Thời gian giữ mã: <span id="countdown">14:59</span>
                </div>
                <div style="font-size: 12px; color: #64748B; margin-top: 6px;">Hệ thống xác thực giao dịch tức thì</div>
            </div>

            <div>
                <h3 style="font-size: 18px; margin: 0 0 16px 0; color: #0F172A;">Thông tin chuyển khoản chính xác</h3>
                
                <table class="qr-info-table">
                    <tr>
                        <td>Ngân hàng thụ hưởng</td>
                        <td>MBBank (Ngân hàng Quân Đội)</td>
                    </tr>
                    <tr>
                        <td>Số tài khoản</td>
                        <td>
                            <span>0987654321</span>
                            <span class="copy-pill" onclick="copyText('0987654321')">📋 Sao chép</span>
                        </td>
                    </tr>
                    <tr>
                        <td>Tên người thụ hưởng</td>
                        <td>KEEBHUB MARKETPLACE</td>
                    </tr>
                    <tr>
                        <td>Số tiền thanh toán</td>
                        <td class="highlight-amount">
                            <fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>₫
                            <span class="copy-pill" onclick="copyText('${order.totalAmount}')">📋</span>
                        </td>
                    </tr>
                    <tr>
                        <td>Nội dung chuyển khoản</td>
                        <td>
                            <strong style="color: #2563EB;">${order.orderCode}</strong>
                            <span class="copy-pill" onclick="copyText('${order.orderCode}')">📋 Sao chép</span>
                        </td>
                    </tr>
                </table>

                <div style="background: #FEF3C7; border: 1px solid #FDE68A; border-radius: 8px; padding: 12px 14px; margin-top: 16px; font-size: 13px; color: #92400E;">
                    ⚠️ Quý khách vui lòng giữ <strong>chính xác nội dung chuyển khoản</strong> để đơn hàng được cập nhật tự động nhanh nhất.
                </div>

                <form method="POST" action="payment-qr" class="qr-actions">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <a href="${pageContext.request.contextPath}/my-orders" class="btn" style="background:#F1F5F9; color:#475569;">Để thanh toán sau</a>
                    <button type="submit" class="btn" style="background:#10B981; color:#fff;">✓ Tôi đã hoàn tất chuyển khoản</button>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
function copyText(text) {
    navigator.clipboard.writeText(text).then(function() {
        alert("Đã sao chép: " + text);
    });
}

// Đồng hồ đếm ngược 15 phút
var seconds = 899;
var countdownEl = document.getElementById("countdown");
var timer = setInterval(function() {
    var m = Math.floor(seconds / 60);
    var s = seconds % 60;
    countdownEl.innerText = (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    if (seconds <= 0) {
        clearInterval(timer);
        countdownEl.innerText = "Hết hạn";
    }
    seconds--;
}, 1000);
</script>

</body>
</html>
