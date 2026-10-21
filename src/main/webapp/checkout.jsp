<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.CartItem,model.Product,model.User,dao.AddressDAO" %>
<%!
    private String esc(String s) {return s == null ? "" : s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");}
%>
<%
    String ctx = request.getContextPath();
    Collection<CartItem> items = (Collection<CartItem>) request.getAttribute("cartItems");
    if (items == null) items = Collections.emptyList();
    Number sub = (Number) request.getAttribute("checkoutSubtotal");
    Number disc = (Number) request.getAttribute("appliedCouponDiscount");
    long subtotal = sub == null ? 0 : sub.longValue();
    long discount = disc == null ? 0 : disc.longValue();
    String error = (String) request.getAttribute("error");
    String addressError = (String) request.getAttribute("addressError");
    List<AddressDAO.Address> addresses = (List<AddressDAO.Address>) request.getAttribute("savedAddresses");
    if (addresses == null) addresses = Collections.emptyList();
    Object active = request.getAttribute("activeAddressId");
    AddressDAO.Address first = addresses.isEmpty() ? null : addresses.get(0);
    if (active instanceof Integer) {
        for (AddressDAO.Address a : addresses) {
            if (a.getId() == (Integer)active) { first = a; break; }
        }
    }
    String addressSuccess = (String) request.getAttribute("addressSuccess");
    String addressUpdateError = (String) request.getAttribute("addressUpdateError");
    User checkoutUser = (User) request.getAttribute("checkoutUser");
    String defaultName = checkoutUser == null ? "" : checkoutUser.getFullName();
    String defaultPhone = checkoutUser == null ? "" : checkoutUser.getPhone();
    String defaultEmail = checkoutUser == null ? "" : checkoutUser.getEmail();
%>
<!doctype html>
<html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Thanh toán | KeebHub</title>
    <link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
    <link rel="stylesheet" href="assets/css/checkout.css">
</head><body>
<jsp:include page="includes/header.jsp"/>
<main class="co-page"><div class="co-container">
    <div class="co-steps"><span class="done">✓ Giỏ hàng</span><b>›</b><span class="active">2 · Thông tin &amp; thanh toán</span><b>›</b><span>3 · Hoàn tất</span></div>
    <% if (error != null) { %><div class="co-error"><%=esc(error)%></div><% } %>
    <% if (addressError != null) { %><div class="co-error"><%=esc(addressError)%></div><% } %>
    <% if (addressSuccess != null) { %><div class="co-address-ok"><%=esc(addressSuccess)%></div><% } %>
    <% if (addressUpdateError != null) { %><div class="co-error"><%=esc(addressUpdateError)%></div><% } %>
    <div class="co-layout"><div class="co-main">
        <form id="checkoutForm" method="post" action="<%=ctx%>/checkout">
            <section class="co-card">
                <div class="co-title"><span class="co-num">1</span><h2>Địa chỉ nhận hàng</h2><button class="co-link" type="button" id="changeAddress">Chọn địa chỉ khác</button></div>
                <% if (first != null) { %>
                <div class="co-address" id="addressPreview"><span class="co-pin">📍</span><div>
                    <strong id="previewName"><%=esc(first.getName())%></strong> &nbsp; <span id="previewPhone"><%=esc(first.getPhone())%></span>
                    <span id="previewDefault" class="co-default"><%=first.isDefaultAddress()?"Mặc định":"Đã lưu"%></span>
                    <p id="previewStreet"><%=esc(first.getAddress())%></p>
                </div><button type="button" id="editAddress">Thay đổi</button></div>
                <% } else { %><p class="co-muted">Chưa có địa chỉ giao hàng đã lưu hoặc từ đơn trước. Vui lòng nhập địa chỉ mới.</p><% } %>
                <div id="addressChooser" class="co-address-chooser" hidden>
                    <div class="co-chooser-heading"><b>Chọn địa chỉ giao hàng</b><button type="button" id="closeAddressChooser">Đóng ×</button></div>
                    <% for (AddressDAO.Address a : addresses) { %>
                    <label class="co-address-choice">
                        <input type="radio" name="addressId" value="<%=a.getId()%>" form="checkoutForm" <%=a.getId() == (first == null ? 0 : first.getId()) ? "checked" : ""%>
                               data-name="<%=esc(a.getName())%>" data-phone="<%=esc(a.getPhone())%>" data-street="<%=esc(a.getAddress())%>" data-default="<%=a.isDefaultAddress()%>">
                        <span><b><%=esc(a.getName())%></b> · <%=esc(a.getPhone())%><small><%=esc(a.getAddress())%></small></span>
                    </label>
                    <% } %>
                    <label class="co-address-choice"><input type="radio" name="addressId" value="new" <%=first == null ? "checked" : ""%>><span><b>+ Thêm địa chỉ mới</b><small>Nhập địa chỉ giao hàng khác</small></span></label>
                </div>
                <% if (first != null) { %>
                <div id="editAddressPanel" class="co-edit-panel" hidden>
                    <div class="co-chooser-heading"><b>Chỉnh sửa địa chỉ đang chọn</b><button type="button" id="cancelEditAddress">Đóng ×</button></div>
                    <div class="co-fields">
                        <label>Họ tên người nhận<input form="editAddressForm" id="editReceiverName" name="editReceiverName" maxlength="100" required></label>
                        <label>Số điện thoại<input form="editAddressForm" id="editReceiverPhone" name="editReceiverPhone" maxlength="20" required></label>
                        <label class="wide">Địa chỉ nhận hàng<textarea form="editAddressForm" id="editShippingAddress" name="editShippingAddress" maxlength="500" rows="2" required></textarea></label>
                    </div>
                    <button class="co-save-address" type="submit" form="editAddressForm">Lưu thay đổi</button>
                </div>
                <% } %>
                <div id="newAddressFields" <%=first == null ? "" : "hidden"%>>
                    <div class="co-fields">
                        <label>Họ tên người nhận<input type="text" name="receiverName" maxlength="100" value="<%=esc(defaultName)%>" placeholder="Họ và tên"></label>
                        <label>Số điện thoại<input type="tel" name="receiverPhone" maxlength="20" value="<%=esc(defaultPhone)%>" placeholder="Số điện thoại"></label>
                        <label class="wide">Địa chỉ nhận hàng<textarea name="shippingAddress" rows="2" maxlength="500" placeholder="Số nhà, đường, phường/xã, tỉnh/thành phố"></textarea></label>
                    </div>
                    <label class="co-check"><input type="checkbox" name="saveAddress" checked> Lưu địa chỉ này vào tài khoản</label>
                </div>
                <div class="co-fields co-extra-fields">
                    <label>Ghi chú cho đơn hàng<input name="orderNote" maxlength="500" placeholder="Ghi chú (không bắt buộc)"></label>
                    <label>Email nhận hóa đơn<input type="email" name="invoiceEmail" maxlength="150" value="<%=esc(defaultEmail)%>" placeholder="Email (không bắt buộc)"></label>
                </div>
                <label class="co-check"><input type="checkbox" name="requestVat"> Xuất hóa đơn VAT cho công ty</label>
            </section>
            <section class="co-card"><div class="co-title"><span class="co-num">2</span><h2>Phương thức vận chuyển</h2></div>
                <div class="co-shipping">
                    <label class="co-option"><input type="radio" name="shippingMethod" value="STANDARD" data-fee="30000" checked><b>Tiêu chuẩn</b><small>Giao 3–5 ngày làm việc</small><strong>30.000₫</strong></label>
                    <label class="co-option"><input type="radio" name="shippingMethod" value="EXPRESS" data-fee="55000"><b>Nhanh</b><small>Giao 1–2 ngày làm việc</small><strong>55.000₫</strong></label>
                    <label class="co-option"><input type="radio" name="shippingMethod" value="SAME_DAY" data-fee="90000"><b>Hỏa tốc</b><small>Tùy khu vực hỗ trợ</small><strong>90.000₫</strong></label>
                </div>
                <div class="co-notice">◷ Đơn hàng có sản phẩm gia công (nếu có) sẽ cần thêm thời gian hoàn thiện, thường khoảng 5–7 ngày, cộng với thời gian vận chuyển. <strong>Ngày nhận hàng dự kiến</strong> sẽ được shop xác nhận theo từng đơn hàng.</div>
            </section>
            <section class="co-card"><div class="co-title"><span class="co-num">3</span><h2>Phương thức thanh toán</h2></div>
                <div class="co-payments">
                    <label class="co-payment"><input type="radio" name="paymentMethod" value="VNPAY_QR" checked><span class="co-pay-icon">▦</span><span><b>Ví điện tử / QR Code</b><small>MoMo · ZaloPay · VNPAY-QR</small></span><span class="co-pay-logos"><span class="co-brand co-momo">MOMO</span><span class="co-brand co-zalo">ZALO</span><span class="co-brand co-vnpay">VNPAY</span></span></label>
                    <label class="co-payment"><input type="radio" name="paymentMethod" value="ATM"><span class="co-pay-icon">💳</span><span><b>Thẻ ATM nội địa / Thẻ quốc tế</b><small>Visa, Mastercard, JCB, ATM có Internet Banking</small></span><span class="co-pay-logos"><span class="co-brand co-visa">VISA</span><span class="co-brand co-mc">MC</span></span></label>
                    <label class="co-payment"><input type="radio" name="paymentMethod" value="BANK_TRANSFER"><span class="co-pay-icon">🏦</span><span><b>Chuyển khoản ngân hàng</b><small>Đơn được xử lý sau khi shop xác nhận</small></span></label>
                    <label class="co-payment"><input type="radio" name="paymentMethod" value="COD"><span class="co-pay-icon">📦</span><span><b>Thanh toán khi nhận hàng (COD)</b><small>Thanh toán khi nhận hàng (tùy điều kiện sản phẩm và cửa hàng)</small></span></label>
                </div>
                <div class="co-blue-note">🔒 Đơn hàng được ghi nhận sau khi bạn nhấn <strong>Đặt hàng &amp; thanh toán</strong>. Với ví điện tử, QR và thẻ ATM, hệ thống hiện <strong>chưa xử lý giao dịch trực tuyến</strong>; shop sẽ liên hệ hướng dẫn bước thanh toán tiếp theo.</div>
            </section>
        </form>
        <form id="editAddressForm" method="post" action="<%=ctx%>/checkout">
            <input type="hidden" name="action" value="updateAddress">
            <input type="hidden" id="editAddressId" name="editAddressId" value="<%=first == null ? "" : first.getId()%>">
        </form>
    </div>
        <aside class="co-side">
            <div class="co-card co-summary"><div class="co-summary-head"><h2>Đơn hàng</h2><a href="<%=ctx%>/cart">Sửa</a></div>
                <% for (CartItem item : items) { %>
                <div class="co-product">
                    <span class="co-product-icon">⌨️</span>
                    <span class="co-product-name"><b><%=esc(item.getProduct().getName())%></b><small><%=esc(item.getVariantLabel())%> · x<%=item.getQuantity()%></small></span>
                    <strong><%=Product.formatVND(item.getLineTotal().longValue())%></strong>
                </div><% } %>
                <hr><div class="co-sumline"><span>Tạm tính</span><b><%=Product.formatVND(subtotal)%></b></div>
                <div class="co-sumline"><span>Phí gia công</span><b>0₫</b></div>
                <div class="co-sumline"><span>Vận chuyển</span><b id="shippingFee">30.000₫</b></div>
                <div class="co-sumline"><span>Giảm giá</span><b class="co-green">−<%=Product.formatVND(discount)%></b></div>
                <div class="co-grand"><span>Tổng thanh toán</span><strong id="grandTotal"><%=Product.formatVND(subtotal-discount+30000)%></strong></div>
                <label class="co-terms"><input type="checkbox" id="agree" required form="checkoutForm" checked> Tôi đã đọc và đồng ý với điều khoản sử dụng và chính sách đổi trả.</label>
                <button class="co-submit" type="submit" form="checkoutForm" id="placeOrder">Đặt hàng &amp; thanh toán</button>
            </div>
            <div class="co-card co-perks"><p>🔒 Thông tin đặt hàng được bảo vệ</p><p>↩ Hỗ trợ hủy đơn trước khi shop xác nhận, theo chính sách</p><p>🛡 Bảo hành 12 tháng cho linh kiện đủ điều kiện</p></div>
        </aside></div>
</div></main>
<jsp:include page="includes/footer.jsp"/>
<script>
    (function(){
        const base = <%=subtotal-discount%>;
        const money = n => Number(n).toLocaleString('vi-VN')+'₫';
        const chooser = document.getElementById('addressChooser');
        const fields = document.getElementById('newAddressFields');
        function chooseAddress(){
            const checked = document.querySelector('input[name="addressId"]:checked');
            const isNew = !checked || checked.value === 'new';
            fields.hidden = !isNew;
            fields.querySelectorAll('input[name="receiverName"],input[name="receiverPhone"],textarea').forEach(x => x.required = isNew);
            if (!isNew && document.getElementById('addressPreview')) {
                document.getElementById('previewName').textContent = checked.dataset.name;
                document.getElementById('previewPhone').textContent = checked.dataset.phone;
                document.getElementById('previewStreet').textContent = checked.dataset.street;
                document.getElementById('previewDefault').textContent = checked.dataset.default === 'true' ? 'Mặc định' : 'Đã lưu';
            }
        }
        document.querySelectorAll('input[name="addressId"]').forEach(x=>x.addEventListener('change',chooseAddress));
        const editPanel = document.getElementById('editAddressPanel');
        const preview = document.getElementById('addressPreview');
        const editButton = document.getElementById('editAddress');
        const changeButton = document.getElementById('changeAddress');
        function openChooser(){ chooser.hidden = false; if(editPanel) editPanel.hidden = true; }
        if(changeButton) changeButton.addEventListener('click',openChooser);
        const closeChooser = document.getElementById('closeAddressChooser');
        if(closeChooser) closeChooser.addEventListener('click',()=>chooser.hidden=true);
        if(editButton) editButton.addEventListener('click',()=>{
            const checked = document.querySelector('input[name="addressId"]:checked');
            if(!checked || checked.value==='new') { openChooser(); return; }
            chooser.hidden=true;
            editPanel.hidden=false;
            document.getElementById('editAddressId').value=checked.value;
            document.getElementById('editReceiverName').value=checked.dataset.name;
            document.getElementById('editReceiverPhone').value=checked.dataset.phone;
            document.getElementById('editShippingAddress').value=checked.dataset.street;
        });
        const cancelEdit = document.getElementById('cancelEditAddress');
        if(cancelEdit) cancelEdit.addEventListener('click',()=>editPanel.hidden=true);
        document.querySelectorAll('input[name="addressId"]').forEach(x=>x.addEventListener('change',()=>{
            chooser.hidden=true;
            if(editPanel) editPanel.hidden=true;
        }));
        function refresh(){
            const selected=document.querySelector('input[name="shippingMethod"]:checked');
            const fee=selected?Number(selected.dataset.fee):0;
            document.getElementById('shippingFee').textContent=money(fee);
            document.getElementById('grandTotal').textContent=money(base+fee);
            document.querySelectorAll('.co-option').forEach(x=>x.classList.toggle('chosen',x.querySelector('input').checked));
            document.querySelectorAll('.co-payment').forEach(x=>x.classList.toggle('chosen',x.querySelector('input').checked));
        }
        document.querySelectorAll('input[name="shippingMethod"],input[name="paymentMethod"]').forEach(x=>x.addEventListener('change',refresh));
        document.getElementById('checkoutForm').addEventListener('submit',function(){document.getElementById('placeOrder').disabled=true;});
        chooseAddress();refresh();
    })();
</script>
</body>
</html>
