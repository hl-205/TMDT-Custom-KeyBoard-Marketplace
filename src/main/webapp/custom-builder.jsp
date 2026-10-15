<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Shop.CustomServiceItem" %>
<%@ page import="dao.CustomBuilderDAO.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login?redirect=custom-builder");
        return;
    }
    List<BuilderProduct> kits       = (List<BuilderProduct>) request.getAttribute("kits");
    List<BuilderProduct> switches   = (List<BuilderProduct>) request.getAttribute("switches");
    List<BuilderProduct> keycaps    = (List<BuilderProduct>) request.getAttribute("keycaps");
    List<BuilderProduct> stabs      = (List<BuilderProduct>) request.getAttribute("stabs");
    List<Shop>           workshops  = (List<Shop>)          request.getAttribute("workshops");
    Map<Integer, List<CustomServiceItem>> servicesMap =
        (Map<Integer, List<CustomServiceItem>>) request.getAttribute("servicesMap");
    List<CompatResult> compatResults = (List<CompatResult>) request.getAttribute("compatResults");

    int preKitId  = (Integer) (request.getAttribute("preKitId")   != null ? request.getAttribute("preKitId")   : 0);
    int selKit    = (Integer) (request.getAttribute("selKit")      != null ? request.getAttribute("selKit")     : preKitId);
    int selSwitch = (Integer) (request.getAttribute("selSwitch")   != null ? request.getAttribute("selSwitch")  : 0);
    int selKeycap = (Integer) (request.getAttribute("selKeycap")   != null ? request.getAttribute("selKeycap")  : 0);
    int selStab   = (Integer) (request.getAttribute("selStab")     != null ? request.getAttribute("selStab")    : 0);
    int selSvc    = (Integer) (request.getParameter("selService")  != null
                               ? Integer.parseInt(request.getParameter("selService")) : 0);

    // Flash messages từ session
    String flashSuccess = (String) session.getAttribute("builderSuccess");
    String flashError   = (String) session.getAttribute("builderError");
    session.removeAttribute("builderSuccess");
    session.removeAttribute("builderError");

    // Tính compat score
    int okCount = 0, warnCount = 0, errCount = 0;
    if (compatResults != null) {
        for (CompatResult cr : compatResults) {
            if ("OK".equals(cr.getLevel())) okCount++;
            else if ("WARN".equals(cr.getLevel())) warnCount++;
            else errCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Custom Builder — Tự cấu hình bàn phím cơ | KeebHub</title>
    <meta name="description" content="Tự tay cấu hình bộ bàn phím cơ custom theo ý thích: chọn kit, switch, keycap và gói gia công phù hợp. Hệ thống tự động kiểm tra tương thích linh kiện.">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/custom-builder.css">
</head>
<body>

<jsp:include page="includes/header.jsp" />

<!-- ══ HEADER ══════════════════════════════════════════════════ -->
<div class="cb-header">
    <div class="cb-header-inner">
        <h1>⚙️ Custom Builder</h1>
        <p>Tự cấu hình bộ bàn phím cơ — chọn linh kiện, kiểm tra tương thích, đặt gia công</p>
    </div>
    <div class="cb-steps-bar">
        <div class="cb-step-tab <%= selKit    > 0 ? "done" : "active" %>" data-step="1">
            <span class="cb-step-num"><%= selKit > 0 ? "✓" : "1" %></span>Kit bàn phím
        </div>
        <div class="cb-step-tab <%= selSwitch  > 0 ? "done" : (selKit > 0 ? "active" : "") %>">
            <span class="cb-step-num"><%= selSwitch > 0 ? "✓" : "2" %></span>Switch
        </div>
        <div class="cb-step-tab <%= selKeycap  > 0 ? "done" : (selSwitch > 0 ? "active" : "") %>">
            <span class="cb-step-num"><%= selKeycap > 0 ? "✓" : "3" %></span>Keycap
        </div>
        <div class="cb-step-tab <%= selStab    > 0 ? "done" : (selKeycap > 0 ? "active" : "") %>">
            <span class="cb-step-num"><%= selStab > 0 ? "✓" : "4" %></span>Stabilizer
        </div>
        <div class="cb-step-tab <%= selSvc     > 0 ? "done" : "" %>">
            <span class="cb-step-num"><%= selSvc > 0 ? "✓" : "5" %></span>Gói gia công
        </div>
        <div class="cb-step-tab <%= compatResults != null ? "active" : "" %>">
            <span class="cb-step-num">6</span>Kiểm tra & Đặt đơn
        </div>
    </div>
</div>

<!-- ══ ALERT FLASH ═══════════════════════════════════════════════ -->
<% if (flashSuccess != null) { %>
<div style="max-width:1320px;margin:16px auto;padding:0 20px;">
    <div class="cb-alert success">✓ <%= flashSuccess %></div>
</div>
<% } %>
<% if (flashError != null) { %>
<div style="max-width:1320px;margin:16px auto;padding:0 20px;">
    <div class="cb-alert error">⚠ <%= flashError %></div>
</div>
<% } %>

<!-- ══ MAIN LAYOUT ════════════════════════════════════════════════ -->
<div class="cb-shell">

    <!-- ── LEFT: Danh sách linh kiện ── -->
    <div class="cb-main">

        <!-- ████ BƯỚC 1: Kit bàn phím ████ -->
        <div class="cb-card" id="step-kit">
            <div class="cb-card-header">
                <h2><span class="step-badge">1</span> Chọn Kit bàn phím</h2>
            </div>
            <div class="cb-card-body">
                <div class="cb-product-grid" id="kitGrid">
                <% if (kits != null) { for (BuilderProduct p : kits) { %>
                <div class="cb-prod-card <%= p.getId() == selKit ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-name="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-layout="<%= p.getLayout() != null ? p.getLayout() : "" %>"
                     data-pin="<%= p.getPinType() != null ? p.getPinType() : "" %>"
                     data-mount="<%= p.getMountType() != null ? p.getMountType() : "" %>"
                     onclick="selectPart('kit', this)">
                    <span class="cb-prod-check">✓</span>
                    <div class="cb-prod-thumb"><div class="illus-kit"></div></div>
                    <div class="cb-prod-name"><%= p.getName() %></div>
                    <div class="cb-prod-meta">
                        <span class="cb-prod-rating">★ <%= p.getRatingAvg() %></span>
                        <span><%= p.getLayout() != null ? p.getLayout() : "" %></span>
                    </div>
                    <div class="cb-prod-price"><%= p.getFormattedPrice() %></div>
                </div>
                <% } } %>
                </div>
            </div>
        </div>

        <!-- ████ BƯỚC 2: Switch ████ -->
        <div class="cb-card" id="step-switch">
            <div class="cb-card-header">
                <h2><span class="step-badge">2</span> Chọn Switch</h2>
            </div>
            <div class="cb-card-body">
                <!-- Lọc nhanh theo loại switch -->
                <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px;" id="switchFilterRow">
                    <span class="ws-tab active" onclick="filterSwitch('ALL', this)">Tất cả</span>
                    <span class="ws-tab" onclick="filterSwitch('Linear', this)">Linear</span>
                    <span class="ws-tab" onclick="filterSwitch('Tactile', this)">Tactile</span>
                    <span class="ws-tab" onclick="filterSwitch('Clicky', this)">Clicky</span>
                </div>
                <!-- Số lượng switch cần -->
                <div class="qty-inline" style="margin-bottom:14px;">
                    <span>Số lượng switch cần:</span>
                    <input type="number" id="switchQtyInput" name="switchQty" value="70" min="10" max="120" step="10">
                    <span>nút</span>
                </div>
                <div class="cb-product-grid" id="switchGrid">
                <% if (switches != null) { for (BuilderProduct p : switches) { %>
                <div class="cb-prod-card <%= p.getId() == selSwitch ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-name="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-type="<%= p.getSwitchType() != null ? p.getSwitchType() : "Other" %>"
                     data-pin="<%= p.getPinType() != null ? p.getPinType() : "" %>"
                     onclick="selectPart('sw', this)">
                    <span class="cb-prod-check">✓</span>
                    <div class="cb-prod-thumb">
                        <div class="illus-switch-sm <%= "Linear".equalsIgnoreCase(p.getSwitchType()) ? "" : "purple" %>"></div>
                    </div>
                    <div class="cb-prod-name"><%= p.getName() %></div>
                    <div class="cb-prod-meta">
                        <span class="cb-prod-rating">★ <%= p.getRatingAvg() %></span>
                        <span><%= p.getSwitchType() != null ? p.getSwitchType() : "" %></span>
                    </div>
                    <div class="cb-prod-price"><%= p.getFormattedPrice() %></div>
                </div>
                <% } } %>
                </div>
            </div>
        </div>

        <!-- ████ BƯỚC 3: Keycap ████ -->
        <div class="cb-card" id="step-keycap">
            <div class="cb-card-header">
                <h2><span class="step-badge">3</span> Chọn Keycap</h2>
                <span class="optional-tag">Tuỳ chọn</span>
            </div>
            <div class="cb-card-body">
                <div class="cb-product-grid" id="keycapGrid">
                <!-- Không chọn keycap -->
                <div class="cb-prod-card none-card <%= selKeycap == 0 ? "selected" : "" %>"
                     data-id="0" data-name="Không chọn" data-price="0"
                     onclick="selectPart('keycap', this)">
                    <span class="cb-prod-check">✓</span>
                    ➕ Tự mua keycap riêng
                </div>
                <% if (keycaps != null) { for (BuilderProduct p : keycaps) { %>
                <div class="cb-prod-card <%= p.getId() == selKeycap ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-name="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-layout="<%= p.getLayout() != null ? p.getLayout() : "All layout" %>"
                     onclick="selectPart('keycap', this)">
                    <span class="cb-prod-check">✓</span>
                    <div class="cb-prod-thumb"><div class="illus-keycap-sm"></div></div>
                    <div class="cb-prod-name"><%= p.getName() %></div>
                    <div class="cb-prod-meta">
                        <span class="cb-prod-rating">★ <%= p.getRatingAvg() %></span>
                        <span><%= p.getBrand() %></span>
                    </div>
                    <div class="cb-prod-price"><%= p.getFormattedPrice() %></div>
                </div>
                <% } } %>
                </div>
            </div>
        </div>

        <!-- ████ BƯỚC 4: Stabilizer ████ -->
        <div class="cb-card" id="step-stab">
            <div class="cb-card-header">
                <h2><span class="step-badge">4</span> Chọn Stabilizer</h2>
                <span class="optional-tag">Tuỳ chọn</span>
            </div>
            <div class="cb-card-body">
                <div class="cb-product-grid" id="stabGrid">
                <div class="cb-prod-card none-card <%= selStab == 0 ? "selected" : "" %>"
                     data-id="0" data-name="Không chọn" data-price="0"
                     onclick="selectPart('stab', this)">
                    <span class="cb-prod-check">✓</span>
                    ➕ Tự mua stab riêng
                </div>
                <% if (stabs != null) { for (BuilderProduct p : stabs) { %>
                <div class="cb-prod-card <%= p.getId() == selStab ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-name="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     onclick="selectPart('stab', this)">
                    <span class="cb-prod-check">✓</span>
                    <div class="cb-prod-thumb"><div class="illus-stab-sm"></div></div>
                    <div class="cb-prod-name"><%= p.getName() %></div>
                    <div class="cb-prod-meta">
                        <span class="cb-prod-rating">★ <%= p.getRatingAvg() %></span>
                        <span><%= p.getBrand() %></span>
                    </div>
                    <div class="cb-prod-price"><%= p.getFormattedPrice() %></div>
                </div>
                <% } } %>
                </div>
            </div>
        </div>

        <!-- ████ BƯỚC 5: Gói gia công ████ -->
        <div class="cb-card" id="step-service">
            <div class="cb-card-header">
                <h2><span class="step-badge">5</span> Chọn Xưởng & Gói gia công</h2>
                <span class="optional-tag">Tuỳ chọn</span>
            </div>
            <div class="cb-card-body">
                <!-- Tab chọn xưởng -->
                <div class="cb-workshop-tabs" id="workshopTabs">
                    <span class="ws-tab" data-ws="0" onclick="selectNoService(this)">
                        Không cần gia công
                    </span>
                <% if (workshops != null) {
                   boolean firstWs = true;
                   for (Shop ws : workshops) { %>
                    <span class="ws-tab <%= firstWs ? "active" : "" %>"
                          data-ws="<%= ws.getId() %>"
                          onclick="switchWorkshop(<%= ws.getId() %>, this)">
                        <span class="ws-avatar" style="background:<%= ws.getAvatarColor() != null ? ws.getAvatarColor() : "#1B64F2" %>;"><%= ws.getAvatarText() %></span>
                        <%= ws.getShopName() %>
                    </span>
                <%  firstWs = false;
                   } } %>
                </div>

                <!-- Các gói dịch vụ theo từng xưởng -->
                <% if (workshops != null) {
                   boolean firstWs2 = true;
                   for (Shop ws : workshops) {
                       List<CustomServiceItem> wsSvcs = servicesMap != null ? servicesMap.get(ws.getId()) : null;
                %>
                <div class="cb-service-grid ws-services <%= firstWs2 ? "active" : "" %>"
                     id="ws-<%= ws.getId() %>">
                    <!-- Không chọn gói trong xưởng này -->
                    <div class="cb-service-card none-card"
                         style="border-style:dashed;display:flex;align-items:center;justify-content:center;min-height:100px;color:#64748B;font-weight:600;cursor:pointer;"
                         data-id="0" data-name="Không gia công" data-price="0" data-ws="<%= ws.getId() %>"
                         onclick="selectService(0, 'Không gia công', 0, this)">
                        ➕ Chỉ mua linh kiện, tự lắp
                    </div>
                <% if (wsSvcs != null) { for (CustomServiceItem svc : wsSvcs) { %>
                    <div class="cb-service-card <%= svc.isPopular() ? "popular-card" : "" %> <%= svc.getId() == selSvc ? "selected" : "" %>"
                         data-id="<%= svc.getId() %>" data-name="<%= svc.getServiceName().replace("\"","&quot;") %>"
                         data-price="<%= svc.getPrice() %>" data-ws="<%= ws.getId() %>"
                         onclick="selectService(<%= svc.getId() %>, '<%= svc.getServiceName().replace("'","\\'") %>', <%= svc.getPrice() %>, this)">
                        <span class="cb-service-check">✓</span>
                        <% if (svc.isPopular()) { %><span class="popular-badge">Phổ biến</span><% } %>
                        <div class="cb-service-name"><%= svc.getServiceName() %></div>
                        <div class="cb-service-price"><%= svc.getFormattedPrice() %></div>
                        <div class="cb-service-duration">⏱ <%= svc.getDurationText() %></div>
                        <ul class="cb-service-features">
                        <% for (String line : svc.getDescription().split(";")) { %>
                            <li><%= line.trim() %></li>
                        <% } %>
                        </ul>
                    </div>
                <% } } %>
                </div>
                <%  firstWs2 = false;
                   } } %>
            </div>
        </div>

        <!-- ████ BƯỚC 6: Kết quả tương thích ████ -->
        <% if (compatResults != null && !compatResults.isEmpty()) { %>
        <div class="cb-compat-panel" id="step-compat">
            <div class="cb-compat-header">
                🔍 Kết quả kiểm tra tương thích linh kiện
                <span class="compat-score <%= errCount > 0 ? "has-err" : warnCount > 0 ? "has-warn" : "all-ok" %>">
                    <%= errCount > 0 ? "⚠ Không tương thích" : warnCount > 0 ? "⚡ Cần lưu ý" : "✓ Tương thích tốt" %>
                </span>
            </div>
            <div class="compat-items">
            <% for (CompatResult cr : compatResults) {
               String iconClass = "OK".equals(cr.getLevel()) ? "ok" : "WARN".equals(cr.getLevel()) ? "warn" : "error";
               String iconChar  = "OK".equals(cr.getLevel()) ? "✓" : "WARN".equals(cr.getLevel()) ? "!" : "✕";
            %>
            <div class="compat-item">
                <div class="compat-icon <%= iconClass %>"><%= iconChar %></div>
                <div class="compat-text">
                    <strong><%= cr.getTitle() %></strong>
                    <span><%= cr.getMessage() %></span>
                </div>
            </div>
            <% } %>
            </div>
        </div>
        <% } %>

    </div><!-- /cb-main -->

    <!-- ── RIGHT SIDEBAR: Summary + Form đặt đơn ── -->
    <div class="cb-sidebar">

        <!-- Tóm tắt build -->
        <div class="cb-summary-card">
            <div class="cb-summary-header">
                <h3>Cấu hình của bạn</h3>
                <p>Chọn linh kiện ở bên trái để xem tổng tiền</p>
            </div>

            <div class="cb-summary-items" id="summaryItems">
                <div class="cb-summary-row" id="row-kit">
                    <span class="label">⌨️ Kit</span>
                    <span class="val empty" id="val-kit">Chưa chọn</span>
                    <span class="price" id="price-kit" style="display:none;"></span>
                </div>
                <div class="cb-summary-row" id="row-sw">
                    <span class="label">⚙️ Switch</span>
                    <span class="val empty" id="val-sw">Chưa chọn</span>
                    <span class="price" id="price-sw" style="display:none;"></span>
                </div>
                <div class="cb-summary-row" id="row-keycap">
                    <span class="label">🎨 Keycap</span>
                    <span class="val empty" id="val-keycap">Tự mua riêng</span>
                    <span class="price" id="price-keycap" style="display:none;"></span>
                </div>
                <div class="cb-summary-row" id="row-stab">
                    <span class="label">⚖️ Stab</span>
                    <span class="val empty" id="val-stab">Tự mua riêng</span>
                    <span class="price" id="price-stab" style="display:none;"></span>
                </div>
                <div class="cb-summary-row" id="row-svc">
                    <span class="label">🛠️ Gia công</span>
                    <span class="val empty" id="val-svc">Không chọn</span>
                    <span class="price" id="price-svc" style="display:none;"></span>
                </div>
            </div>

            <div class="cb-price-breakdown" id="priceBreakdown">
                <div class="cb-price-row"><span>Tổng linh kiện</span><span id="subtotalParts">—</span></div>
                <div class="cb-price-row"><span>Phí gia công</span><span id="subtotalSvc">—</span></div>
                <div class="cb-price-row"><span>Phí vận chuyển</span><span>30.000₫</span></div>
                <div class="cb-price-row total">
                    <span>Tổng cộng</span>
                    <span id="grandTotal">—</span>
                </div>
            </div>

            <!-- Nút kiểm tra tương thích (form GET) -->
            <div class="cb-summary-actions">
                <form method="get" action="custom-builder" id="compatForm" style="margin-bottom:10px;">
                    <input type="hidden" name="action"    value="check-compat">
                    <input type="hidden" name="selKit"    id="f-kit"     value="<%= selKit %>">
                    <input type="hidden" name="selSwitch" id="f-switch"  value="<%= selSwitch %>">
                    <input type="hidden" name="selKeycap" id="f-keycap"  value="<%= selKeycap %>">
                    <input type="hidden" name="selStab"   id="f-stab"    value="<%= selStab %>">
                    <input type="hidden" name="selService" id="f-svc"    value="<%= selSvc %>">
                    <button type="submit" class="btn-compat-check">
                        🔍 Kiểm tra tương thích
                    </button>
                </form>
            </div>
        </div><!-- /cb-summary-card -->

        <!-- Form đặt đơn -->
        <div class="cb-summary-card">
            <div class="cb-summary-header">
                <h3>📦 Thông tin giao hàng</h3>
                <p>Điền đầy đủ để đặt đơn custom</p>
            </div>
            <form method="post" action="custom-builder" id="orderForm">
                <input type="hidden" name="action"      value="place-order">
                <input type="hidden" name="kitId"       id="of-kit"     value="<%= selKit %>">
                <input type="hidden" name="switchId"    id="of-switch"  value="<%= selSwitch %>">
                <input type="hidden" name="keycapId"    id="of-keycap"  value="<%= selKeycap %>">
                <input type="hidden" name="stabId"      id="of-stab"    value="<%= selStab %>">
                <input type="hidden" name="serviceId"   id="of-svc"     value="<%= selSvc %>">
                <input type="hidden" name="switchQty"   id="of-swqty"   value="70">

                <div class="cb-checkout-form">
                    <div class="cb-form-group">
                        <label>Họ và tên người nhận *</label>
                        <input type="text" name="receiverName"
                               value="<%= currentUser.getFullName() %>" required
                               placeholder="Nhập họ tên đầy đủ">
                    </div>
                    <div class="cb-form-group">
                        <label>Số điện thoại *</label>
                        <input type="tel" name="receiverPhone"
                               value="<%= currentUser.getPhone() != null ? currentUser.getPhone() : "" %>"
                               required placeholder="VD: 0987 654 321">
                    </div>
                    <div class="cb-form-group">
                        <label>Địa chỉ nhận hàng *</label>
                        <input type="text" name="shippingAddress" required
                               placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành">
                    </div>
                    <div class="cb-form-group">
                        <label>Ghi chú cho xưởng</label>
                        <textarea name="customNote" rows="3"
                                  placeholder="VD: Lube kỹ phím dài, ưu tiên âm trầm thocky, stab clip + band-aid..."></textarea>
                    </div>
                    <div class="cb-form-group">
                        <label>Phương thức thanh toán</label>
                        <select name="paymentMethod">
                            <option value="VNPAY">VNPAY-QR</option>
                            <option value="MoMo">Ví MoMo</option>
                            <option value="ZaloPay">ZaloPay</option>
                            <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-place-order" id="placeOrderBtn" disabled>
                        🛒 Đặt đơn Custom ngay
                    </button>
                    <p style="font-size:11px;color:#94A3B8;margin-top:8px;text-align:center;">
                        Đặt đơn xong, xưởng sẽ xác nhận trong 24h
                    </p>
                </div>
            </form>
        </div>

        <!-- Tips card -->
        <div class="cb-tips-card">
            <h4>💡 Mẹo build bàn phím</h4>
            <div class="cb-tip-item">🔵 PCB hotswap 5-pin tương thích cả switch 3-pin và 5-pin.</div>
            <div class="cb-tip-item">🟡 Switch Linear phù hợp gaming, Tactile phù hợp văn phòng.</div>
            <div class="cb-tip-item">🟢 Gasket mount giảm tiếng vang, tay gõ êm hơn tray mount.</div>
            <div class="cb-tip-item">🔴 Keycap Cherry profile không bị cộm với LED south-facing.</div>
        </div>

    </div><!-- /cb-sidebar -->

</div><!-- /cb-shell -->

<jsp:include page="includes/footer.jsp" />

<!-- ══ JAVASCRIPT ═════════════════════════════════════════════ -->
<script>
    // ── State ──────────────────────────────────────────────────
    const state = {
        kit:    { id: <%= selKit %>,    name: '', price: 0 },
        sw:     { id: <%= selSwitch %>, name: '', price: 0 },
        keycap: { id: <%= selKeycap %>, name: '', price: 0 },
        stab:   { id: <%= selStab %>,   name: '', price: 0 },
        svc:    { id: <%= selSvc %>,    name: '', price: 0 },
    };

    // Khởi tạo state từ server-side selected values
    function initStateFromDOM() {
        ['kit','sw','keycap','stab'].forEach(k => {
            const grid = document.getElementById(k === 'sw' ? 'switchGrid' : k + 'Grid');
            if (!grid) return;
            const sel = grid.querySelector('.cb-prod-card.selected:not(.none-card)');
            if (sel) {
                state[k].id    = parseInt(sel.dataset.id) || 0;
                state[k].name  = sel.dataset.name || '';
                state[k].price = parseInt(sel.dataset.price) || 0;
                updateSummaryRow(k, state[k].name, state[k].price);
            }
        });
        // Service
        const selSvcCard = document.querySelector('.cb-service-card.selected');
        if (selSvcCard) {
            state.svc.id    = parseInt(selSvcCard.dataset.id)    || 0;
            state.svc.name  = selSvcCard.dataset.name            || '';
            state.svc.price = parseInt(selSvcCard.dataset.price) || 0;
            updateSummaryRow('svc', state.svc.name, state.svc.price);
        }
        recalcTotal();
        syncHiddenInputs();
        toggleOrderButton();
    }

    // ── Chọn linh kiện ─────────────────────────────────────────
    function selectPart(type, card) {
        const grid = card.parentElement;
        grid.querySelectorAll('.cb-prod-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');

        const id    = parseInt(card.dataset.id)    || 0;
        const name  = card.dataset.name            || 'Không chọn';
        const price = parseInt(card.dataset.price) || 0;

        state[type].id    = id;
        state[type].name  = name;
        state[type].price = price;

        updateSummaryRow(type, name, price);
        recalcTotal();
        syncHiddenInputs();
        toggleOrderButton();
    }

    // ── Chọn gói dịch vụ ───────────────────────────────────────
    function selectService(id, name, price, card) {
        // Bỏ selected tất cả service card
        document.querySelectorAll('.cb-service-card').forEach(c => c.classList.remove('selected'));
        if (card) card.classList.add('selected');

        state.svc.id    = id;
        state.svc.name  = name;
        state.svc.price = price;

        updateSummaryRow('svc', id > 0 ? name : 'Không gia công', price);
        recalcTotal();
        syncHiddenInputs();
        toggleOrderButton();
    }

    function selectNoService(tab) {
        document.querySelectorAll('#workshopTabs .ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.ws-services').forEach(el => el.classList.remove('active'));
        // Bỏ hết selection service
        document.querySelectorAll('.cb-service-card').forEach(c => c.classList.remove('selected'));
        selectService(0, 'Không gia công', 0, null);
    }

    // ── Đổi xưởng ──────────────────────────────────────────────
    function switchWorkshop(wsId, tab) {
        document.querySelectorAll('#workshopTabs .ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.ws-services').forEach(el => el.classList.remove('active'));
        const target = document.getElementById('ws-' + wsId);
        if (target) target.classList.add('active');
    }

    // ── Lọc switch theo loại ────────────────────────────────────
    function filterSwitch(type, tab) {
        document.querySelectorAll('#switchFilterRow .ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('#switchGrid .cb-prod-card').forEach(card => {
            const cardType = card.dataset.type || 'Other';
            card.style.display = (type === 'ALL' || cardType === type) ? '' : 'none';
        });
    }

    // ── Cập nhật hàng trong Summary ────────────────────────────
    const LABELS = { kit:'⌨️ Kit', sw:'⚙️ Switch', keycap:'🎨 Keycap', stab:'⚖️ Stab', svc:'🛠️ Gia công' };
    function updateSummaryRow(type, name, price) {
        const valEl   = document.getElementById('val-'   + type);
        const priceEl = document.getElementById('price-' + type);
        if (!valEl) return;
        if (name && name !== 'Không chọn' && name !== 'Không gia công' && name !== 'Tự mua riêng' && price > 0) {
            valEl.textContent   = name.length > 28 ? name.substring(0,28)+'…' : name;
            valEl.className     = 'val';
            priceEl.textContent = formatVND(price);
            priceEl.style.display = '';
        } else if (name === 'Không gia công' || name === 'Tự mua riêng' || name === 'Không chọn' || price === 0) {
            valEl.textContent   = (type === 'svc') ? 'Không gia công' : (type === 'keycap' || type === 'stab') ? 'Tự mua riêng' : 'Chưa chọn';
            valEl.className     = 'val empty';
            priceEl.style.display = 'none';
        } else {
            valEl.textContent   = name.length > 28 ? name.substring(0,28)+'…' : name;
            valEl.className     = 'val';
            priceEl.textContent = formatVND(price);
            priceEl.style.display = '';
        }
    }

    // ── Tính tổng ──────────────────────────────────────────────
    function recalcTotal() {
        const parts = state.kit.price + state.sw.price + state.keycap.price + state.stab.price;
        const svc   = state.svc.price;
        const ship  = 30000;
        const total = parts + svc + ship;

        document.getElementById('subtotalParts').textContent = parts > 0 ? formatVND(parts) : '—';
        document.getElementById('subtotalSvc').textContent   = svc   > 0 ? formatVND(svc)   : '—';
        document.getElementById('grandTotal').textContent    = total > ship ? formatVND(total) : '—';
    }

    // ── Sync hidden inputs ──────────────────────────────────────
    function syncHiddenInputs() {
        document.getElementById('f-kit').value    = state.kit.id;
        document.getElementById('f-switch').value = state.sw.id;
        document.getElementById('f-keycap').value = state.keycap.id;
        document.getElementById('f-stab').value   = state.stab.id;
        document.getElementById('f-svc').value    = state.svc.id;

        document.getElementById('of-kit').value    = state.kit.id;
        document.getElementById('of-switch').value = state.sw.id;
        document.getElementById('of-keycap').value = state.keycap.id;
        document.getElementById('of-stab').value   = state.stab.id;
        document.getElementById('of-svc').value    = state.svc.id;
    }

    // ── Bật/tắt nút đặt đơn ────────────────────────────────────
    function toggleOrderButton() {
        const btn = document.getElementById('placeOrderBtn');
        if (btn) btn.disabled = (state.kit.id <= 0);
    }

    // ── Sync số lượng switch ────────────────────────────────────
    const swQtyInput = document.getElementById('switchQtyInput');
    if (swQtyInput) {
        swQtyInput.addEventListener('input', () => {
            document.getElementById('of-swqty').value = swQtyInput.value;
        });
    }

    // ── Format tiền VNĐ ────────────────────────────────────────
    function formatVND(n) {
        return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + '₫';
    }

    // ── Scroll đến kết quả tương thích ─────────────────────────
    <% if (compatResults != null && !compatResults.isEmpty()) { %>
    window.addEventListener('load', () => {
        const compatPanel = document.getElementById('step-compat');
        if (compatPanel) {
            setTimeout(() => compatPanel.scrollIntoView({ behavior: 'smooth', block: 'start' }), 400);
        }
    });
    <% } %>

    // ── Khởi tạo ───────────────────────────────────────────────
    initStateFromDOM();

    // Hiển thị tab xưởng đầu tiên mặc định
    const firstWsTab = document.querySelector('#workshopTabs .ws-tab[data-ws]:not([data-ws="0"])');
    if (firstWsTab) {
        const firstWsId = firstWsTab.dataset.ws;
        const firstServices = document.getElementById('ws-' + firstWsId);
        if (firstServices) firstServices.classList.add('active');
    }
</script>

</body>
</html>
