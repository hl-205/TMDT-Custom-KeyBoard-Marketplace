<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Order,model.Product,java.util.List,java.time.format.DateTimeFormatter,java.time.LocalDate" %>
<%!
    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    Order o = (Order) request.getAttribute("order");
    if (o == null) {
        response.sendRedirect(request.getContextPath() + "/orders");
        return;
    }
    String ctx = request.getContextPath();
    LocalDate orderDate = o.getCreatedAt() == null ? LocalDate.now() : o.getCreatedAt().toLocalDateTime().toLocalDate();
    String deliveryRange = orderDate.plusDays(4).format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
            + " – " + orderDate.plusDays(7).format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    String payMethod = o.getPaymentMethod() == null ? "" : o.getPaymentMethod();
    String paymentName = "COD".equals(payMethod) ? "Thanh toán khi nhận hàng"
            : "VNPAY_QR".equals(payMethod) ? "VNPAY-QR"
            : "ATM".equals(payMethod) ? "Thẻ ATM"
            : "BANK_TRANSFER".equals(payMethod) ? "Chuyển khoản ngân hàng" : payMethod;
    @SuppressWarnings("unchecked")
    List<Product> recommendations = (List<Product>) request.getAttribute("recommendedProducts");
%>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đặt hàng thành công | KeebHub</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/order-success.css">

</head>
<body>
<jsp:include page="includes/header.jsp"/>
<main class="co-page">
    <div class="co-success-container">
        <nav class="co-steps center" aria-label="Tiến trình đặt hàng">
            <span class="done">✓ Giỏ hàng</span><b aria-hidden="true">›</b>
            <span class="done">✓ Thanh toán</span><b aria-hidden="true">›</b>
            <span class="active" aria-current="step">3 · Hoàn tất</span>
        </nav>
        <section class="co-success-card">
            <div class="co-success-top">
                <div class="co-checkmark" aria-hidden="true">✓</div>
                <h1>Đặt hàng thành công!</h1>
                <p>Cảm ơn bạn đã mua sắm tại KeebHub. Đơn hàng của bạn đã được ghi nhận.</p>
            </div>
            <div class="co-success-details">
                <div><span>Mã đơn hàng</span><b>#<%=escapeHtml(String.valueOf(o.getOrderCode()))%></b></div>
                <div><span>Thời gian đặt</span><b><%=o.getCreatedAt() == null ? "—" : o.getCreatedAt().toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy · HH:mm"))%></b></div>
                <div><span>Phương thức thanh toán</span><b><%=escapeHtml(paymentName)%><small class="co-payment-status is-paid"> · Đã thanh toán</small></b></div>
                <div><span>Tổng thanh toán</span><strong><%=o.getTotalAmount() == null ? "—" : Product.formatVND(o.getTotalAmount().longValue())%></strong></div>
                <div class="co-delivery-row"><span>Dự kiến nhận hàng</span><b><%=deliveryRange%></b></div>
            </div>
            <div class="co-success-actions">
                <a href="<%=ctx%>/orders">Theo dõi đơn hàng</a>
                <a href="<%=ctx%>/shop">Tiếp tục mua sắm</a>
            </div>
            <div class="co-timeline" aria-label="Các bước xử lý đơn hàng">

                <a href="seller-confirm-custom"
                   class="co-timeline-step">
                    <span class="co-timeline-icon">📋</span>
                    <strong>Shop xác nhận</strong>
                    <small>Trong 24 giờ</small>
                </a>

                <a href="seller-services"
                   class="co-timeline-step">
                    <span class="co-timeline-icon">🛠️</span>
                    <strong>Gia công</strong>
                    <small>5–7 ngày</small>
                </a>

                <a href="orders"
                   class="co-timeline-step">
                    <span class="co-timeline-icon">🚚</span>
                    <strong>Vận chuyển</strong>
                    <small>3–5 ngày</small>
                </a>

                <a href="my-reviews"
                   class="co-timeline-step">
                    <span class="co-timeline-icon">⭐</span>
                    <strong>Nhận & đánh giá</strong>
                    <small>Nhận quà 50k</small>
                </a>

            </div>
        </section>
        <% if (recommendations != null && !recommendations.isEmpty()) { %>
        <section class="co-recommend" aria-labelledby="co-recommend-title">
            <div class="co-recommend-head">
                <h2 id="co-recommend-title">Thêm gợi ý cho bạn</h2>
                <a href="shop">Xem tất cả →</a>
            </div>
            <div class="co-recommend-grid">
                <% for (Product p : recommendations) {
                    if (p == null) continue;
                    boolean hasOldPrice = p.getOldPrice() > p.getPrice() && p.getPrice() > 0;
                    long percent = hasOldPrice ? Math.round(100.0 * (p.getOldPrice() - p.getPrice()) / p.getOldPrice()) : 0;
                %>
                <a class="co-recommend-item" href="<%=ctx%>/product-detail?id=<%=p.getId()%>">
                    <div class="co-recommend-picture">
                        <% if (p.getImageUrl() != null && !p.getImageUrl().trim().isEmpty()) { %>
                        <img loading="lazy" src="<%=escapeHtml(p.getImageUrl())%>" alt="<%=escapeHtml(p.getName())%>">
                        <% } else { %><span class="co-recommend-placeholder" aria-hidden="true">⌨</span><% } %>
                        <% if (percent > 0) { %><span class="co-recommend-discount">−<%=percent%>%</span><% } %>
                    </div>
                    <div class="co-recommend-info">
                        <span class="co-recommend-brand"><%=escapeHtml(p.getBrand() == null ? "KeebHub" : p.getBrand())%></span>
                        <h3><%=escapeHtml(p.getName())%></h3>
                        <div class="co-recommend-prices">
                            <strong><%=Product.formatVND(p.getPrice())%></strong>
                            <% if (hasOldPrice) { %><del><%=Product.formatVND(p.getOldPrice())%></del><% } %>
                        </div>
                        <div class="co-recommend-meta"><small><%=p.getStock() > 0 ? "Còn hàng" : "Hết hàng"%></small></div>
                    </div>
                </a>
                <% } %>
            </div>
        </section>
        <% } %>
    </div>
</main>
<jsp:include page="includes/footer.jsp"/>
</body>
</html>
