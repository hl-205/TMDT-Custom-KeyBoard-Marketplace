<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User,model.Order,model.OrderItem,model.Product,java.util.Map,java.util.List,java.text.NumberFormat,java.util.Locale,java.text.SimpleDateFormat" %>
<%!
    private String esc(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
    private String statusLabel(String status) {
        if (status == null) return "Không rõ";
        switch (status) {
            case "PENDING": return "Chờ xác nhận";
            case "CONFIRMED": return "Đã xác nhận";
            case "PROCESSING": return "Đang xử lý";
            case "SHIPPING": return "Đang giao";
            case "SHIPPED": return "Đã giao hàng";
            case "COMPLETED": return "Hoàn thành";
            case "CANCELLED": return "Đã hủy";
            default: return status;
        }
    }
    private String displayDate(java.util.Date date) {
        return date == null ? "—" : new SimpleDateFormat("dd/MM/yyyy · HH:mm").format(date);
    }
    private String paymentLabel(String payment) {
        if (payment == null || payment.trim().isEmpty()) return "Chưa xác định";
        if ("COD".equalsIgnoreCase(payment)) return "Thanh toán khi nhận hàng (COD)";
        if ("VIETQR".equalsIgnoreCase(payment)) return "Chuyển khoản VietQR";
        if ("VNPAY".equalsIgnoreCase(payment) || "VNPAY-QR".equalsIgnoreCase(payment)) return "VNPay";
        return payment;
    }
%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Order> orders = (List<Order>) request.getAttribute("historyOrders");
    Order detail = (Order) request.getAttribute("detail");
    Map<Integer, Product> historyProducts = (Map<Integer, Product>) request.getAttribute("historyProducts");
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "ALL";
    String ctx = request.getContextPath();
    String pageUrl = ctx + "/order-history";
    NumberFormat money = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    String[][] tabs = {
            {"ALL", "Tất cả"}, {"PENDING", "Chờ xác nhận"},
            {"CONFIRMED", "Đã xác nhận"}, {"PROCESSING", "Đang xử lý"},
            {"SHIPPING", "Đang giao"}, {"SHIPPED", "Đã giao hàng"},
            {"COMPLETED", "Hoàn thành"}, {"CANCELLED", "Đã hủy"}
    };
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Lịch sử mua hàng - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/order-history.css">
</head>
<body>
<!-- Biểu tượng SVG nội bộ: không cần cài thư viện icon -->
<svg class="oh-icon-sprite" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
    <symbol id="oh-i-orders" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="17" rx="2"/><path d="M8 2v4m8-4v4M3 10h18m-13 4h3m-3 4h7"/></symbol>
    <symbol id="oh-i-list" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></symbol>
    <symbol id="oh-i-clock" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></symbol>
    <symbol id="oh-i-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12 4 4L19 6"/></symbol>
    <symbol id="oh-i-check-circle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/></symbol>
    <symbol id="oh-i-package" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m12 2 9 5-9 5-9-5 9-5Zm-9 5v10l9 5 9-5V7M12 12v10"/></symbol>
    <symbol id="oh-i-box" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 7 12 2l9 5v10l-9 5-9-5V7Zm0 0 9 5 9-5M12 12v10"/></symbol>
    <symbol id="oh-i-credit-card" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20m-15 5h3"/></symbol>
    <symbol id="oh-i-user" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3-7 8-7s8 3 8 7"/></symbol>
    <symbol id="oh-i-pin" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/></symbol>
    <symbol id="oh-i-wallet" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="6" width="18" height="15" rx="2"/><path d="M3 10h18M6 6V3h12v3m-2 9h2"/></symbol>
    <symbol id="oh-i-truck" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h12v11H3zM15 10h4l3 4v3h-7"/><circle cx="7" cy="18" r="2"/><circle cx="18" cy="18" r="2"/></symbol>
    <symbol id="oh-i-x" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m9 9 6 6m0-6-6 6"/></symbol>
    <symbol id="oh-i-eye" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="3"/></symbol>
    <symbol id="oh-i-arrow-left" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7M5 12h14"/></symbol>
    <symbol id="oh-i-keyboard" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M6 9h.01M10 9h.01M14 9h.01M18 9h.01M6 13h.01M10 13h.01M14 13h.01M18 13h.01M7 16h10"/></symbol>
    <symbol id="oh-i-filter" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 5h18l-7 8v6l-4 2v-8L3 5Z"/></symbol>
</svg>
<jsp:include page="includes/header.jsp" />
<main class="oh-wrap">
    <header class="oh-page-head">
        <div>
            <h1><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-orders"></use></svg> Lịch sử mua hàng</h1>
        </div>
        <div class="oh-head-symbol" aria-hidden="true"><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-keyboard"></use></svg></div>
    </header>

    <% if (detail != null) { %>
    <section class="oh-card oh-detail-card" aria-label="Chi tiết đơn hàng">
        <div class="oh-detail-head">
            <div>
                <span class="oh-overline">THÔNG TIN ĐƠN HÀNG</span>
                <h2>Đơn hàng <span>#<%=esc(detail.getOrderCode())%></span></h2>
                <p>Đặt lúc <%=displayDate(detail.getCreatedAt())%></p>
            </div>
            <a class="oh-back" href="<%=pageUrl%>"><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-arrow-left"></use></svg> Quay lại danh sách</a>
        </div>

        <div class="oh-detail-layout">
            <div class="oh-detail-info">
                <div class="oh-detail-box oh-status-box">
                    <span><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-check-circle"></use></svg> Trạng thái hiện tại</span>
                    <div><span class="oh-status oh-<%=esc(detail.getOrderStatus())%>"><%=esc(statusLabel(detail.getOrderStatus()))%></span></div>
                </div>
                <div class="oh-detail-box">
                    <span><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-user"></use></svg> Người nhận</span>
                    <strong><%=esc(detail.getReceiverName())%></strong>
                    <small><%=esc(detail.getReceiverPhone())%></small>
                </div>
                <div class="oh-detail-box">
                    <span><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-credit-card"></use></svg> Thanh toán</span>
                    <strong><%=esc(paymentLabel(detail.getPaymentMethod()))%></strong>
                </div>
                <div class="oh-detail-box oh-address-box">
                    <span><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-pin"></use></svg> Địa chỉ giao hàng</span>
                    <strong><%=esc(detail.getShippingAddress())%></strong>
                </div>
            </div>

            <div class="oh-detail-right">
                <div class="oh-section-head">
                    <h3><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-package"></use></svg> Sản phẩm đã đặt</h3>
                    <span><%=detail.getItems() == null ? 0 : detail.getItems().size()%> sản phẩm</span>
                </div>
                <div class="oh-product-list">
                    <% if (detail.getItems() != null && !detail.getItems().isEmpty()) {
                        for (OrderItem item : detail.getItems()) {
                            Product product = historyProducts == null ? null : historyProducts.get(item.getProductId());
                            String imageUrl = product == null ? null : product.getImageUrl();
                            boolean linked = product != null;
                            String productHref = ctx + "/product-detail?id=" + item.getProductId();
                    %>
                    <article class="oh-product">
                        <% if (linked) { %>
                        <a class="oh-photo" href="<%=productHref%>"
                           aria-label="Xem sản phẩm <%=esc(item.getProductName())%>">
                            <% if (imageUrl != null && !imageUrl.trim().isEmpty()) { %>
                            <img src="<%=esc(imageUrl)%>"
                                 alt="<%=esc(item.getProductName())%>"
                                 loading="lazy"
                                 onerror="this.style.display='none';this.nextElementSibling.style.display='grid';">
                            <span class="oh-photo-empty" style="display:none" aria-hidden="true">⌨</span>
                            <% } else { %>
                            <span class="oh-photo-empty" aria-hidden="true">⌨</span>
                            <% } %>
                        </a>
                        <% } else { %>
                        <div class="oh-photo">
                            <span class="oh-photo-empty" aria-hidden="true">⌨</span>
                        </div>
                        <% } %>

                        <div class="oh-product-body">
                            <% if (linked) { %>
                            <a class="oh-product-title" href="<%=productHref%>"><%=esc(item.getProductName())%></a>
                            <% } else { %>
                            <strong class="oh-product-title"><%=esc(item.getProductName())%></strong>
                            <% } %>
                            <div class="oh-product-facts">
                                <span>Số lượng: <b><%=item.getQuantity()%></b></span>
                                <span>Đơn giá: <%=money.format(
                                        item.getQuantity() > 0 && item.getLineTotal() != null
                                                ? item.getLineTotal().divide(
                                                java.math.BigDecimal.valueOf(item.getQuantity()),
                                                0,
                                                java.math.RoundingMode.HALF_UP
                                        )
                                                : item.getUnitPrice()
                                )%>đ</span>
                            </div>
                        </div>
                        <div class="oh-product-total">
                            <small>Thành tiền</small>
                            <strong><%=money.format(item.getLineTotal())%>đ</strong>
                        </div>
                    </article>
                    <% } } else { %>
                    <p class="oh-empty">Đơn hàng này chưa có thông tin chi tiết sản phẩm.</p>
                    <% } %>
                </div>

                <div class="oh-summary">
                    <div><span>Tạm tính</span><strong><%=money.format(detail.getSubtotal())%>đ</strong></div>
                    <div><span>Phí vận chuyển</span><strong><%=money.format(detail.getShippingFee())%>đ</strong></div>
                    <div><span>Giảm giá</span><strong>−<%=money.format(detail.getDiscountAmount())%>đ</strong></div>
                    <div class="oh-summary-final"><span>Tổng thanh toán</span><strong><%=money.format(detail.getTotalAmount())%>đ</strong></div>
                </div>
            </div> <!-- oh-detail-right -->
        </div> <!-- oh-detail-layout -->
    </section>
    <% } %>

    <section class="oh-card oh-list-card" aria-label="Danh sách đơn hàng">
        <div class="oh-list-heading"><div><h2><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-list"></use></svg> Danh sách đơn hàng</h2><p>Chọn trạng thái để tìm đơn hàng nhanh hơn.</p></div><span class="oh-order-count"><%=orders == null ? 0 : orders.size()%> đơn</span></div>
        <nav class="oh-tabs" aria-label="Lọc đơn hàng theo trạng thái">
            <% for (String[] tab : tabs) {
                boolean selected = tab[0].equals(activeTab);
                String tabIcon;
                switch (tab[0]) {
                    case "PENDING": tabIcon = "clock"; break;
                    case "CONFIRMED": tabIcon = "check"; break;
                    case "PROCESSING": tabIcon = "box"; break;
                    case "SHIPPING": tabIcon = "truck"; break;
                    case "SHIPPED": tabIcon = "package"; break;
                    case "COMPLETED": tabIcon = "check-circle"; break;
                    case "CANCELLED": tabIcon = "x"; break;
                    default: tabIcon = "list";
                }
            %>
            <a class="oh-tab <%=selected ? "active" : ""%>"
               href="<%=pageUrl%>?status=<%=tab[0]%>"
                    <%=selected ? "aria-current=\"page\"" : ""%>>
                <svg class="oh-icon" aria-hidden="true"><use href="#oh-i-<%=tabIcon%>"></use></svg>
                <%=tab[1]%>
            </a>
            <% } %>
        </nav>
        <div class="oh-table-scroll">
            <table class="oh-table">
                <thead><tr><th>Mã đơn hàng</th><th>Ngày đặt</th><th>Người nhận</th><th>Trạng thái</th><th>Tổng cộng</th><th>Thao tác</th></tr></thead>
                <tbody>
                <% if (orders != null && !orders.isEmpty()) { for (Order order : orders) { %>
                <tr>
                    <td><a class="oh-code" href="<%=pageUrl%>?id=<%=order.getId()%>">#<%=esc(order.getOrderCode())%></a></td>
                    <td class="oh-date"><%=displayDate(order.getCreatedAt())%></td>
                    <td class="oh-recipient"><%=esc(order.getReceiverName())%></td>
                    <td><span class="oh-status oh-<%=esc(order.getOrderStatus())%>"><%=esc(statusLabel(order.getOrderStatus()))%></span></td>
                    <td class="oh-amount"><%=money.format(order.getTotalAmount())%>đ</td>
                    <td><a class="oh-view-btn" href="<%=pageUrl%>?id=<%=order.getId()%>"><svg class="oh-icon" aria-hidden="true"><use href="#oh-i-eye"></use></svg> Xem chi tiết</a></td>
                </tr>
                <% } } else { %>
                <tr><td colspan="6"><div class="oh-empty-state"><span aria-hidden="true">⌑</span><strong>Chưa có đơn hàng nào</strong><p>Không tìm thấy đơn hàng trong trạng thái đã chọn.</p></div></td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<jsp:include page="includes/footer.jsp" />
</body>
</html>
