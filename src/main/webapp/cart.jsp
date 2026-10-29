<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,model.CartItem,model.Product" %>
<%!
    private String esc(String s){ if(s==null)return ""; return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;"); }
%>
<!doctype html><html lang="vi"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Giỏ hàng | KeebHub</title>
<link rel="stylesheet" href="assets/css/features.css">
<link rel="stylesheet" href="assets/css/style.css">
<link rel="stylesheet" href="assets/css/cart.css">
<link rel="stylesheet" href="assets/css/product-detail.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<style>
    /* Bố cục theo hình tham chiếu */
    .cart-shop-head .chat-shop{display:inline-flex;align-items:center;gap:5px;color:#155dfb;text-decoration:none;font-weight:600}
    .cart-shop-head .chat-shop i{font-size:14px}
    .cart-remove,#deleteSelected{display:inline-flex;align-items:center;gap:5px;cursor:pointer}
    .cart-remove i,#deleteSelected i{font-size:13px}
    .cart-item .cart-info{min-width:0;flex:1}
    .cart-item .cart-bottom{display:flex;justify-content:space-between;align-items:center;gap:14px;flex-wrap:wrap}
    .cart-item .cart-bottom .cart-price{color:#ff4d00;font-weight:800}
    .cart-item .cart-bottom .qty{margin-left:auto}
    .cart-sidebar .summary-line{display:flex;justify-content:space-between;align-items:center;gap:12px}
    .cart-sidebar .summary-line>b{margin-left:auto;text-align:right;white-space:nowrap}
    .cart-sidebar .summary-total{display:flex;justify-content:space-between;align-items:flex-start;gap:12px}
    .cart-sidebar .summary-total .total-right{display:flex;flex-direction:column;align-items:flex-end;gap:5px;text-align:right}
    .cart-sidebar .summary-total #grandTotal{color:#ff4d00;font-size:24px;font-weight:800;white-space:nowrap}
    .cart-sidebar .summary-total .vat-note{color:#94a3b8;font-size:12px;font-weight:400}
    .cart-sidebar .checkout-btn{background:#ff5722!important;color:white!important;border-color:#ff5722!important;font-weight:700}
    .cart-sidebar .checkout-btn:hover{background:#e64a19!important;border-color:#e64a19!important}

    /* Hiển thị bàn phím CSS trong phần sản phẩm gợi ý */
    .recommend-image {
        height: 156px;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        background: #f0f4f8;
        position: relative;
    }
    .recommend-keyboard-scale {
        width: 420px;
        height: 300px;
        flex: 0 0 420px;
        display: flex;
        align-items: center;
        justify-content: center;
        transform: scale(0.40);
        transform-origin: center center;
        pointer-events: none;
    }
</style>
</head><body>
<jsp:include page="includes/header.jsp"/>
<main class="container cart-page">
    <div class="breadcrumb"><a href="${pageContext.request.contextPath}/">Trang chủ</a> › <b>Giỏ hàng</b></div>
    <%
        String ctx=request.getContextPath();
        String err=(String)session.getAttribute("flashError");
        String success=(String)session.getAttribute("flashSuccess");
        if(err!=null){%><div class="cart-flash error"><%=esc(err)%></div><%session.removeAttribute("flashError");}
    if(success!=null){session.removeAttribute("flashSuccess");}
    Collection<CartItem> items=(Collection<CartItem>)request.getAttribute("cartItems");
    if(items==null)items=Collections.emptyList();
%>
    <div class="cart-heading"><h1>Giỏ hàng <span>(<%=items.size()%> sản phẩm)</span></h1><a href="<%=ctx%>/shop">‹ Tiếp tục mua sắm</a></div>
    <% if(items.isEmpty()){ %>
    <div class="empty-cart"><div class="empty-icon">🛒</div><h2>Giỏ hàng đang trống</h2><p>Hãy chọn những món đồ bàn phím bạn yêu thích nhé.</p><a class="checkout-btn" href="<%=ctx%>/shop">Khám phá sản phẩm</a></div>
    <% } else {
        Map<Integer,List<CartItem>> byShop=new LinkedHashMap<>(); long subtotal=0;
        for(CartItem i:items){byShop.computeIfAbsent(i.getProduct().getShopId(),k->new ArrayList<>()).add(i);}
        for(CartItem i:items) subtotal+=i.getLineTotal().longValue();
    %>
    <div class="cart-layout">
        <div class="cart-left">
            <form id="cartForm" method="get" action="<%=ctx%>/checkout">
                <div class="select-all-row"><label><input type="checkbox" id="checkAll" checked> Chọn tất cả (<%=items.size()%>)</label><button type="button" id="deleteSelected"><i class="fa-regular fa-trash-can" aria-hidden="true"></i> Xóa đã chọn</button></div>
                <% for(Map.Entry<Integer,List<CartItem>> entry:byShop.entrySet()){List<CartItem> group=entry.getValue();Product first=group.get(0).getProduct();String shop=first.getShopName()==null||first.getShopName().isEmpty()?"KeebHub Store":first.getShopName(); %>
                <section class="cart-shop">
                    <div class="cart-shop-head"><input type="checkbox" class="cb-shop" checked><span class="shop-avatar"><%=esc(shop.length()>0?shop.substring(0,1).toUpperCase():"K")%></span><a href="<%=ctx%>/shop?id=<%=entry.getKey()%>" class="shop-title"><%=esc(shop)%></a><span class="verified">Đã xác minh</span><a class="chat-shop" href="<%=ctx%>/shop?id=<%=entry.getKey()%>"><i class="fa-regular fa-comments" aria-hidden="true"></i> Chat với shop</a></div>
                    <%for(CartItem i:group){Product p=i.getProduct();int max=Math.max(1,Math.min(99,p.getStock()));String key=i.getKey();String detail=ctx+"/product-detail?id="+p.getId();%>
                    <div class="cart-item" data-key="<%=esc(key)%>" data-pid="<%=p.getId()%>" data-price="<%=i.getUnitPrice()%>" data-max="<%=max%>">
                        <input type="checkbox" class="cb-item" name="sel" value="<%=esc(key)%>" checked>
                        <a class="cart-thumb" href="<%=detail%>">
                            <% if(p.getImageUrl()!=null && !p.getImageUrl().isBlank()){ %><img class="cart-real-image" src="<%=esc(p.getImageUrl())%>" alt="<%=esc(p.getName())%>" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'"/><% } %><div class="cart-keyboard-scale" <%=p.getImageUrl()!=null && !p.getImageUrl().isBlank()?"style='display:none'":""%>>
                            <div class="tofu-board-graphic">
                                <div class="tofu-inner-case">

                                    <div class="tofu-row">
                                        <span class="t-key blue"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key blue"></span>
                                    </div>

                                    <div class="tofu-row">
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key blue"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                    </div>

                                    <div class="tofu-row">
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key blue"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                    </div>

                                    <div class="tofu-row">
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key w2 blue"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                        <span class="t-key"></span>
                                    </div>

                                </div>
                            </div>
                        </div>
                        </a>
                        <div class="cart-info">
                            <a class="cart-name" href="<%=detail%>"><%=esc(p.getName())%></a>
                            <%if(!i.getVariantLabel().isEmpty()){%><div class="cart-variant">Phân loại: <%=esc(i.getVariantLabel())%></div><%}%>
                            <div class="stock-label">● Còn <%=p.getStock()%></div>
                            <div class="cart-bottom"><div><b class="cart-price"><%=Product.formatVND(i.getUnitPrice())%></b><%if(p.getOldPrice()>p.getPrice()){ %><del><%=Product.formatVND(p.getOldPrice() + i.getExtraPrice())%></del><%}%></div>
                                <div class="qty"><button type="button" class="qty-btn qty-minus">−</button><input class="qty-input" value="<%=i.getQuantity()%>" readonly><button type="button" class="qty-btn qty-plus">+</button></div></div>
                            <div class="cart-line"><span>Tạm tính: <b class="line-total"><%=Product.formatVND(i.getLineTotal().longValue())%></b></span><button type="button" class="cart-remove"><i class="fa-regular fa-trash-can" aria-hidden="true"></i> Xóa</button></div>
                        </div></div>
                    <%}%></section><%}%>
            </form>
            <% List<Product> recs=(List<Product>)request.getAttribute("recommendedProducts"); if(recs!=null&&!recs.isEmpty()){ %>
            <section class="recommend-box"><h3>Có thể bạn cần thêm</h3><div class="recommend-grid"><%for(Product p:recs){%><a class="recommend-card" href="<%=ctx%>/product-detail?id=<%=p.getId()%>"><div class="recommend-image">
                <div class="recommend-keyboard-scale">
                    <div class="tofu-board-graphic">
                        <div class="tofu-inner-case">
                            <div class="tofu-row">
                                <span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                            <div class="tofu-row">
                                <span class="t-key"></span><span class="t-key"></span><span class="t-key w2 blue"></span><span class="t-key"></span><span class="t-key"></span><span class="t-key"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
                <div class="recommend-info"><small>● <%=esc(p.getBrand()==null?"KeebHub":p.getBrand())%></small><b><%=esc(p.getName())%></b><strong><%=Product.formatVND(p.getPrice())%></strong></div>
            </a><%}%>
            </div></section>
            <%}%>
        </div>
        <aside class="cart-sidebar">
            <section class="side-card order-summary"><h3>Tóm tắt đơn hàng</h3><div class="summary-line"><span>Tạm tính (<span id="selectedCount"><%=items.size()%></span> sản phẩm)</span><b id="subtotal"><%=Product.formatVND(subtotal)%></b></div><div class="summary-line"><span>Phí gia công</span><b>0₫</b></div><div class="summary-line"><span>Giảm giá sản phẩm</span><b class="green">0₫</b></div><div class="summary-line"><span>Phí vận chuyển</span><b class="green">Miễn phí</b></div><div class="summary-total"><span>Tổng cộng</span><div class="total-right"><strong id="grandTotal"><%=Product.formatVND(subtotal)%></strong><small class="vat-note">Đã bao gồm VAT</small></div></div><button type="submit" form="cartForm" id="buyBtn" class="checkout-btn">Tiến hành thanh toán</button><p class="secure-note">🔒 Sản phẩm được bảo vệ khi thanh toán</p></section>
            <div class="gift-card"><b>🎁 Mua thêm 540.000₫ để nhận quà</b><p>Tặng bộ keycap quà tặng khi đơn hàng đạt điều kiện.</p></div>
        </aside></div>
    <%}%>
</main>
<jsp:include page="includes/footer.jsp"/>

<script>
    (function () {
        var form = document.getElementById('cartForm');
        if (!form) return;

        var ctx = '<%=request.getContextPath()%>';
        var items = Array.from(document.querySelectorAll('.cart-item'));
        var all = document.getElementById('checkAll');
        var shopBoxes = Array.from(document.querySelectorAll('.cb-shop'));

        function fmt(n) {
            return Math.max(0, n).toLocaleString('vi-VN') + '₫';
        }

        function checked(item) {
            return item.querySelector('.cb-item').checked;
        }

        function qty(item) {
            return parseInt(item.querySelector('.qty-input').value, 10) || 1;
        }

        function selectedSubtotal() {
            return items.reduce(function (sum, item) {
                return sum + (checked(item)
                    ? Number(item.dataset.price) * qty(item)
                    : 0);
            }, 0);
        }

        function refresh() {
            var count = items.filter(checked).length;
            var sum = selectedSubtotal();

            document.getElementById('subtotal').textContent = fmt(sum);
            document.getElementById('selectedCount').textContent = count;

            document.getElementById('grandTotal').textContent = fmt(sum);

            all.checked = items.length > 0 && count === items.length;
            all.indeterminate = count > 0 && count < items.length;

            shopBoxes.forEach(function (box) {
                var checkboxes = Array.from(
                    box.closest('.cart-shop').querySelectorAll('.cb-item')
                );

                box.checked = checkboxes.length > 0 &&
                    checkboxes.every(function (cb) {
                        return cb.checked;
                    });
            });

            document.getElementById('buyBtn').disabled = count === 0;
        }

        var cartMutationQueue = Promise.resolve();
        function send(item, action, extra) {
            var body = new URLSearchParams({
                action: action,
                productId: item.dataset.pid,
                key: item.dataset.key
            });

            Object.keys(extra || {}).forEach(function (key) {
                body.set(key, extra[key]);
            });

            // Serialize writes because the server persists the full cart on every mutation.
            var request = cartMutationQueue.catch(function () {}).then(function () {
                return fetch(ctx + '/cart', {
                    method: 'POST',
                    headers: { 'X-Requested-With': 'XMLHttpRequest' },
                    body: body,
                    credentials: 'same-origin'
                }).then(ensureCartResponse);
            });
            cartMutationQueue = request;
            return request;

        }

        all.addEventListener('change', function () {
            items.forEach(function (item) {
                item.querySelector('.cb-item').checked = all.checked;
            });
            refresh();
        });

        shopBoxes.forEach(function (box) {
            box.addEventListener('change', function () {
                box.closest('.cart-shop')
                    .querySelectorAll('.cb-item')
                    .forEach(function (cb) {
                        cb.checked = box.checked;
                    });
                refresh();
            });
        });

        function ensureCartResponse(response) {
            return response.json().then(function (data) {
                if (!response.ok || data.success === false) throw new Error(data.message || 'Cập nhật giỏ hàng thất bại.');
                return data;
            });
        }

        items.forEach(function (item) {
            item.querySelector('.cb-item').addEventListener('change', function () { refresh(); });

            var updateQueue = Promise.resolve();
            function changeQuantity(value) {
                var max = parseInt(item.dataset.max, 10) || 99;
                value = Math.max(1, Math.min(value, max));

                if (value === qty(item)) return;

                item.querySelector('.qty-input').value = value;
                item.querySelector('.line-total').textContent =
                    fmt(Number(item.dataset.price) * value);

                refresh();

                updateQueue = updateQueue.then(function () {
                    return send(item, 'update', { quantity: value });
                }).catch(function (error) {
                    alert(error.message || 'Không thể cập nhật số lượng.');
                    location.reload();
                });
            }

            item.querySelector('.qty-minus').addEventListener('click', function () {
                changeQuantity(qty(item) - 1);
            });

            item.querySelector('.qty-plus').addEventListener('click', function () {
                changeQuantity(qty(item) + 1);
            });

            item.querySelector('.cart-remove').addEventListener('click', function () {
                if (!confirm('Xóa sản phẩm này khỏi giỏ hàng?')) return;

                updateQueue.then(function () {
                    return send(item, 'remove');
                }).then(function () {
                    location.reload();
                }).catch(function (error) {
                    alert(error.message || 'Không thể xóa sản phẩm.');
                    location.reload();
                });
            });
        });

        document.getElementById('deleteSelected')
            .addEventListener('click', function () {
                var selected = items.filter(checked);

                if (!selected.length) {
                    alert('Bạn chưa chọn sản phẩm nào.');
                    return;
                }

                if (!confirm('Xóa ' + selected.length + ' sản phẩm đã chọn?')) {
                    return;
                }

                selected.reduce(function (promise, item) {
                    return promise.then(function () {
                        return send(item, 'remove');
                    });
                }, Promise.resolve()).then(function () {
                    location.reload();
                }).catch(function (error) {
                    alert(error.message || 'Không thể xóa tất cả sản phẩm đã chọn.');
                    location.reload();
                });
            });

        refresh();
    })();
</script>
</body>
</html>
