<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="model.Shop.CustomServiceItem" %>
<%@ page import="dao.CustomBuilderDAO.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<BuilderProduct> kits = (List<BuilderProduct>) request.getAttribute("kits");
    if (kits == null) {
        response.sendRedirect("custom-builder");
        return;
    }

    User currentUser = (User) session.getAttribute("user");
    List<BuilderProduct> switches   = (List<BuilderProduct>) request.getAttribute("switches");
    List<BuilderProduct> keycaps    = (List<BuilderProduct>) request.getAttribute("keycaps");
    List<BuilderProduct> stabs      = (List<BuilderProduct>) request.getAttribute("stabs");
    List<Shop>           workshops  = (List<Shop>)          request.getAttribute("workshops");
    Map<Integer, List<CustomServiceItem>> servicesMap =
            (Map<Integer, List<CustomServiceItem>>) request.getAttribute("servicesMap");
    List<CompatResult> compatResults = (List<CompatResult>) request.getAttribute("compatResults");

    int selKit     = (Integer) (request.getAttribute("selKit")     != null ? request.getAttribute("selKit")     : 1);
    int selSwitch  = (Integer) (request.getAttribute("selSwitch")  != null ? request.getAttribute("selSwitch")  : 2);
    int selKeycap  = (Integer) (request.getAttribute("selKeycap")  != null ? request.getAttribute("selKeycap")  : 0);
    int selStab    = (Integer) (request.getAttribute("selStab")    != null ? request.getAttribute("selStab")    : 6);
    int selService = (Integer) (request.getAttribute("selService") != null ? request.getAttribute("selService") : 0);
    int currentStep = (Integer) (request.getAttribute("currentStep") != null ? request.getAttribute("currentStep") : 2);

    BuilderProduct selectedKit    = (BuilderProduct) request.getAttribute("selectedKit");
    BuilderProduct selectedSwitch = (BuilderProduct) request.getAttribute("selectedSwitch");
    BuilderProduct selectedKeycap = (BuilderProduct) request.getAttribute("selectedKeycap");
    BuilderProduct selectedStab   = (BuilderProduct) request.getAttribute("selectedStab");

    String flashSuccess = (String) session.getAttribute("builderSuccess");
    String flashError   = (String) session.getAttribute("builderError");
    session.removeAttribute("builderSuccess");
    session.removeAttribute("builderError");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Custom Builder — Tự cấu hình bàn phím cơ | KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/custom-builder.css">
</head>
<body class="cb-page">

<header class="cb-navbar">
    <div class="cb-nav-left">
        <a href="index.jsp" class="cb-logo-wrap">
            <span class="cb-logo-badge">K</span>
            <span class="cb-logo-text">KeebHub</span>
        </a>
        <span class="cb-nav-divider">|</span>
        <span class="cb-nav-module">Custom Builder</span>
    </div>

    <div class="cb-nav-stepper" id="cbStepper">
        <div class="cb-step-pill <%= currentStep == 1 ? "active" : (selKit > 0 ? "done" : "") %>" data-step="1" onclick="goToStep(1)">
            <span class="cb-step-badge"><%= currentStep == 1 ? "1" : (selKit > 0 ? "✓" : "1") %></span>
            <span class="cb-step-label">Kit</span>
        </div>
        <div class="cb-step-pill <%= currentStep == 2 ? "active" : (selSwitch > 0 && currentStep > 2 ? "done" : "") %>" data-step="2" onclick="goToStep(2)">
            <span class="cb-step-badge"><%= currentStep == 2 ? "2" : (selSwitch > 0 && currentStep > 2 ? "✓" : "2") %></span>
            <span class="cb-step-label">Switch</span>
        </div>
        <div class="cb-step-pill <%= currentStep == 3 ? "active" : (selKeycap > 0 && currentStep > 3 ? "done" : "") %>" data-step="3" onclick="goToStep(3)">
            <span class="cb-step-badge"><%= currentStep == 3 ? "3" : (selKeycap > 0 && currentStep > 3 ? "✓" : "3") %></span>
            <span class="cb-step-label">Keycap</span>
        </div>
        <div class="cb-step-pill <%= currentStep == 4 ? "active" : ((selStab > 0 || selService > 0) && currentStep > 4 ? "done" : "") %>" data-step="4" onclick="goToStep(4)">
            <span class="cb-step-badge"><%= currentStep == 4 ? "4" : ((selStab > 0 || selService > 0) && currentStep > 4 ? "✓" : "4") %></span>
            <span class="cb-step-label">Gia công</span>
        </div>
        <div class="cb-step-pill <%= currentStep == 5 ? "active" : "" %>" data-step="5" onclick="goToStep(5)">
            <span class="cb-step-badge">5</span>
            <span class="cb-step-label">Xem lại</span>
        </div>
    </div>

    <div class="cb-nav-right">
        <button type="button" class="cb-btn-secondary" onclick="saveDraft()">Lưu nháp</button>
        <a href="index.jsp" class="cb-btn-secondary">Thoát</a>
    </div>
</header>

<% if (flashSuccess != null) { %>
<div class="cb-container" style="margin-top:16px;">
    <div class="cb-alert success">✓ <%= flashSuccess %></div>
</div>
<% } %>
<% if (flashError != null) { %>
<div class="cb-container" style="margin-top:16px;">
    <div class="cb-alert error">⚠ <%= flashError %></div>
</div>
<% } %>

<div class="cb-container cb-shell">
    <main class="cb-main-wizard">

        <!-- BƯỚC 1: CHỌN KIT BÀN PHÍM -->
        <section class="cb-step-view <%= currentStep == 1 ? "active" : "" %>" id="stepView-1">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 1 · Chọn kit bàn phím</h2>
                    <p class="cb-step-sub">Khung xương bàn phím cơ — quyết định layout (60%/65%/75%/TKL), cấu trúc mount và khả năng hotswap 5-pin</p>
                </div>
            </div>

            <div class="cb-filter-row">
                <span class="cb-filter-pill active" onclick="filterGrid('kitGrid', 'ALL', this)">Tất cả</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', '60%', this)">60% (Gọn gàng)</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', '65%', this)">65% (Có phím mũi tên)</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', '75%', this)">75% (Có núm/F-row)</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', 'TKL', this)">TKL 80%</span>
            </div>

            <div class="cb-cards-grid" id="kitGrid">
                <% if (kits != null) { for (BuilderProduct p : kits) { %>
                <div class="cb-product-card <%= p.getId() == selKit ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-shop="<%= p.getShopName().replace("\"","&quot;") %>"
                     data-type="<%= p.getLayout() != null ? p.getLayout() : "" %> <%= p.getMountType() != null ? p.getMountType() : "" %>"
                     data-layout="<%= p.getLayout() != null ? p.getLayout() : "60%" %>"
                     data-pin="<%= p.getPinType() != null ? p.getPinType() : "5-pin" %>"
                     data-mount="<%= p.getMountType() != null ? p.getMountType() : "Gasket mount" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-specs="<%= p.getOptionSpecs() != null && !p.getOptionSpecs().isEmpty() ? p.getOptionSpecs().replace("\"","&quot;") : (p.getBrand() + " · " + (p.getLayout()!=null?p.getLayout():"") + " · " + (p.getMountType()!=null?p.getMountType():"")) %>"
                     onclick="selectPart('kit', this)">
                    <div class="cb-card-badge-row">
                        <span class="cb-badge-compat">✓ Tương thích</span>
                        <span class="cb-badge-stock"><%= p.getStockText() %></span>
                    </div>
                    <div class="cb-card-thumb">
                        <div class="cb-illus-kit">
                            <div class="cb-kit-body">
                                <div class="cb-kit-plate"></div>
                            </div>
                        </div>
                    </div>
                    <div class="cb-card-info">
                        <div class="cb-card-shop"><%= p.getShopName() %> · ★ <%= p.getRatingAvg() %></div>
                        <h3 class="cb-card-title"><%= p.getName() %></h3>
                        <div class="cb-card-specs"><%= p.getBrand() %> · <%= p.getLayout() != null ? p.getLayout() : "" %> · <%= p.getMountType() != null ? p.getMountType() : "" %> · <%= p.getPinType() != null ? p.getPinType() : "" %></div>
                        <div class="cb-card-price-row">
                            <span class="cb-card-price"><%= p.getFormattedPrice() %></span>
                            <% if (p.getOldPrice() > 0) { %>
                            <span class="cb-card-oldprice"><%= p.getFormattedOldPrice() %></span>
                            <% } %>
                        </div>
                    </div>
                    <div class="cb-card-action">
                        <button type="button" class="cb-btn-select <%= p.getId() == selKit ? "is-selected" : "" %>">
                            <%= p.getId() == selKit ? "✓ Đã chọn" : "Chọn kit này" %>
                        </button>
                    </div>
                </div>
                <% } } %>
            </div>

            <div class="cb-step-footer">
                <div class="cb-step-footer-left"></div>
                <div class="cb-step-footer-center">Đã chọn kit bàn phím</div>
                <div class="cb-step-footer-right">
                    <button type="button" class="cb-btn-primary" onclick="goToStep(2)">Tiếp tục chọn switch &gt;</button>
                </div>
            </div>
        </section>

        <!-- BƯỚC 2: CHỌN SWITCH -->
        <section class="cb-step-view <%= currentStep == 2 ? "active" : "" %>" id="stepView-2">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 2 · Chọn switch</h2>
                    <p class="cb-step-sub" id="switchKitSubtitle">
                        Đang lọc theo kit đã chọn: <strong><%= selectedKit != null ? selectedKit.getName() : "Kit Tofu60 2.0 Aluminium" %></strong> · <%= selectedKit != null && selectedKit.getPinType() != null ? selectedKit.getPinType() : "hotswap 5-pin" %> · south-facing LED
                    </p>
                </div>
                <label class="cb-toggle-compat">
                    <input type="checkbox" id="onlyCompatToggle" checked onchange="toggleOnlyCompat(this)">
                    <span>Chỉ hiện linh kiện tương thích</span>
                </label>
            </div>

            <div class="cb-filter-row">
                <span class="cb-filter-label">Lọc nhanh:</span>
                <span class="cb-filter-pill active" onclick="filterSwitch('ALL', this)">Tất cả</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Linear', this)">Linear</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Tactile', this)">Tactile</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Clicky', this)">Clicky</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Lube', this)">Đã lube sẵn</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Under1M', this)">Dưới 1 triệu</span>
                <span class="cb-filter-count-note" id="switchCountNote">Cần 70 switch cho layout <%= selectedKit != null && selectedKit.getLayout() != null ? selectedKit.getLayout() : "60%" %></span>
            </div>

            <div class="cb-warning-banner" id="switchWarningBanner">
                <div class="cb-warning-icon">⚠️</div>
                <div class="cb-warning-content">
                    <div class="cb-warning-title">1 linh kiện trong danh sách không lắp vừa kit của bạn</div>
                    <div class="cb-warning-desc">
                        <strong>Kailh Box Jade (đời cũ)</strong> dùng chân switch dày hơn chuẩn MX, không tương thích socket hotswap của <%= selectedKit != null ? selectedKit.getShortName() : "kit" %>. Hệ thống đã khoá lựa chọn này để tránh hỏng PCB.
                    </div>
                    <div class="cb-warning-actions">
                        <button type="button" class="cb-btn-warn-action" onclick="filterSwitch('Clicky', null)">Xem switch clicky thay thế</button>
                        <button type="button" class="cb-btn-warn-dismiss" onclick="dismissWarning()">Ẩn cảnh báo</button>
                    </div>
                </div>
            </div>

            <div class="cb-cards-grid grid-3col" id="switchGrid">
                <% if (switches != null) { for (BuilderProduct p : switches) {
                    boolean isCompat = p.isCompatible();
                    String colorClass = p.getSwitchColor() != null ? p.getSwitchColor() : "black";
                %>
                <div class="cb-product-card <%= p.getId() == selSwitch ? "selected" : "" %> <%= !isCompat ? "incompatible-card" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-shop="<%= p.getShopName().replace("\"","&quot;") %>"
                     data-compat="<%= isCompat ? "1" : "0" %>"
                     data-pin="<%= p.getPinType() != null ? p.getPinType() : "5-pin" %>"
                     data-type="<%= p.getSwitchType() != null ? p.getSwitchType() : "Linear" %> <%= p.getName().toLowerCase().contains("lube") ? "Lube" : "" %> <%= p.getPrice() < 1000000 ? "Under1M" : "" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-color="<%= colorClass %>"
                     data-specs="<%= p.getOptionSpecs() != null && !p.getOptionSpecs().isEmpty() ? p.getOptionSpecs().replace("\"","&quot;") : (p.getSwitchType() + " · " + p.getPinType()) %>"
                     onclick="selectPart('sw', this)">

                    <div class="cb-card-badge-row">
                        <% if (isCompat) { %>
                        <span class="cb-badge-compat">Tương thích</span>
                        <% } else { %>
                        <span class="cb-badge-incompat">Không lắp vừa</span>
                        <% } %>
                        <span class="cb-badge-stock"><%= p.getShopName() %> · <%= p.getStockText() %></span>
                    </div>

                    <div class="cb-card-thumb">
                        <div class="cb-illus-switch <%= colorClass %>">
                            <div class="cb-sw-top">
                                <div class="cb-sw-stem"></div>
                            </div>
                            <div class="cb-sw-bottom"></div>
                        </div>
                    </div>

                    <div class="cb-card-info">
                        <h3 class="cb-card-title"><%= p.getName() %></h3>
                        <div class="cb-card-specs"><%= p.getOptionSpecs() %></div>
                        <div class="cb-card-price-row">
                            <span class="cb-card-price"><%= p.getFormattedPrice() %></span>
                        </div>
                    </div>

                    <div class="cb-card-action">
                        <% if (isCompat) { %>
                        <button type="button" class="cb-btn-select <%= p.getId() == selSwitch ? "is-selected" : "" %>">
                            <%= p.getId() == selSwitch ? "✔ Đã chọn" : "Chọn" %>
                        </button>
                        <% } else { %>
                        <button type="button" class="cb-btn-disabled" disabled>Không tương thích</button>
                        <div class="cb-card-error-text">
                            <%= p.getIncompatReason() %>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } } %>
            </div>

            <div class="cb-step-footer">
                <div class="cb-step-footer-left">
                    <button type="button" class="cb-btn-secondary" onclick="goToStep(1)">&lt; Quay lại chọn kit</button>
                </div>
                <div class="cb-step-footer-center" id="switchCountStatus">Đã chọn 70/70 switch</div>
                <div class="cb-step-footer-right">
                    <button type="button" class="cb-btn-primary" onclick="goToStep(3)">Tiếp tục chọn keycap &gt;</button>
                </div>
            </div>
        </section>

        <!-- BƯỚC 3: CHỌN KEYCAP -->
        <section class="cb-step-view <%= currentStep == 3 ? "active" : "" %>" id="stepView-3">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 3 · Chọn keycap</h2>
                    <p class="cb-step-sub">Bộ nút phím quyết định ngoại hình, cảm giác chạm và profile gõ</p>
                </div>
            </div>

            <div class="cb-filter-row">
                <span class="cb-filter-label">Lọc nhanh:</span>
                <span class="cb-filter-pill active" onclick="filterGrid('keycapGrid', 'ALL', this)">Tất cả</span>
                <span class="cb-filter-pill" onclick="filterGrid('keycapGrid', 'Cherry', this)">Cherry profile</span>
                <span class="cb-filter-pill" onclick="filterGrid('keycapGrid', 'ASA', this)">ASA profile</span>
                <span class="cb-filter-pill" onclick="filterGrid('keycapGrid', 'OEM', this)">OEM profile</span>
                <span class="cb-filter-pill" onclick="filterGrid('keycapGrid', 'PBT', this)">Nhựa PBT</span>
                <span class="cb-filter-pill" onclick="filterGrid('keycapGrid', 'ABS', this)">Nhựa ABS</span>
            </div>

            <div class="cb-cards-grid grid-3col" id="keycapGrid">
                <div class="cb-product-card none-card <%= selKeycap == 0 ? "selected" : "" %>"
                     data-id="0" data-shop="Tự trang bị" data-compat="1" data-name="Không chọn (Tự mua riêng)" data-shortname="Tự mua riêng" data-price="0"
                     data-specs="Tự sắm keycap ngoài" onclick="selectPart('keycap', this)">
                    <div class="cb-card-thumb" style="height:120px;display:flex;align-items:center;justify-content:center;">
                        <span style="font-size:32px;">🎨</span>
                    </div>
                    <div class="cb-card-info" style="text-align:center;">
                        <h3 class="cb-card-title">Tự mua keycap riêng</h3>
                        <p class="cb-card-specs">Bỏ qua bước này nếu bạn đã có sẵn keycap ở nhà</p>
                    </div>
                    <div class="cb-card-action">
                        <button type="button" class="cb-btn-select <%= selKeycap == 0 ? "is-selected" : "" %>">
                            <%= selKeycap == 0 ? "✓ Đang chọn" : "Chọn bỏ qua" %>
                        </button>
                    </div>
                </div>

                <% if (keycaps != null) { for (BuilderProduct p : keycaps) {
                    boolean isCompat = p.isCompatible();
                %>
                <div class="cb-product-card <%= p.getId() == selKeycap ? "selected" : "" %> <%= !isCompat ? "incompatible-card" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-shop="<%= p.getShopName().replace("\"","&quot;") %>"
                     data-compat="<%= isCompat ? "1" : "0" %>"
                     data-layout="<%= p.getLayout() != null ? p.getLayout() : "" %>"
                     data-type="<%= p.getName() %> <%= p.getLayout() != null ? p.getLayout() : "" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-specs="<%= p.getOptionSpecs() != null ? p.getOptionSpecs().replace("\"","&quot;") : p.getBrand() %>"
                     onclick="selectPart('keycap', this)">

                    <div class="cb-card-badge-row">
                        <% if (isCompat) { %>
                        <span class="cb-badge-compat">Tương thích</span>
                        <% } else { %>
                        <span class="cb-badge-incompat">Không lắp vừa</span>
                        <% } %>
                        <span class="cb-badge-stock"><%= p.getShopName() %> · <%= p.getStockText() %></span>
                    </div>

                    <div class="cb-card-thumb">
                        <div class="cb-illus-keycap <%= p.getName().contains("Olivia") ? "olivia" : (p.getName().contains("Pink") ? "pink" : "retro") %>">
                            <span class="cb-keycap-face">K</span>
                        </div>
                    </div>

                    <div class="cb-card-info">
                        <h3 class="cb-card-title"><%= p.getName() %></h3>
                        <div class="cb-card-specs"><%= p.getOptionSpecs() %></div>
                        <div class="cb-card-price-row">
                            <span class="cb-card-price"><%= p.getFormattedPrice() %></span>
                        </div>
                    </div>

                    <div class="cb-card-action">
                        <% if (isCompat) { %>
                        <button type="button" class="cb-btn-select <%= p.getId() == selKeycap ? "is-selected" : "" %>">
                            <%= p.getId() == selKeycap ? "✓ Đã chọn" : "Chọn" %>
                        </button>
                        <% } else { %>
                        <button type="button" class="cb-btn-disabled" disabled>Không tương thích</button>
                        <div class="cb-card-error-text"><%= p.getIncompatReason() %></div>
                        <% } %>
                    </div>
                </div>
                <% } } %>
            </div>

            <div class="cb-step-footer">
                <div class="cb-step-footer-left">
                    <button type="button" class="cb-btn-secondary" onclick="goToStep(2)">&lt; Quay lại chọn switch</button>
                </div>
                <div class="cb-step-footer-center">Đã chọn keycap</div>
                <div class="cb-step-footer-right">
                    <button type="button" class="cb-btn-primary" onclick="goToStep(4)">Tiếp tục chọn gia công &amp; stab &gt;</button>
                </div>
            </div>
        </section>

        <!-- BƯỚC 4: CHỌN STABILIZER & GÓI GIA CÔNG -->
        <section class="cb-step-view <%= currentStep == 4 ? "active" : "" %>" id="stepView-4">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 4 · Stabilizer & Gói gia công</h2>
                    <p class="cb-step-sub">Chọn thanh cân bằng và Xưởng chịu trách nhiệm tập kết linh kiện, lắp ráp &amp; kiểm định chất lượng</p>
                </div>
            </div>

            <div class="cb-sub-section">
                <div class="cb-sub-header">
                    <h3>1. Chọn Stabilizer (cho các phím dài Space, Shift, Enter)</h3>
                    <span class="cb-sub-tag">PCB screw-in tương thích kit</span>
                </div>

                <div class="cb-cards-grid grid-3col" id="stabGrid">
                    <div class="cb-product-card none-card <%= selStab == 0 ? "selected" : "" %>"
                         data-id="0" data-shop="Tự trang bị" data-compat="1" data-name="Không chọn (Tự mua stab)" data-shortname="Tự mua riêng" data-price="0"
                         data-specs="Tự trang bị stab" onclick="selectPart('stab', this)">
                        <div class="cb-card-thumb" style="height:90px;display:flex;align-items:center;justify-content:center;">
                            <span style="font-size:26px;">⚖️</span>
                        </div>
                        <div class="cb-card-info" style="text-align:center;">
                            <h3 class="cb-card-title">Tự mua stab riêng</h3>
                        </div>
                        <div class="cb-card-action">
                            <button type="button" class="cb-btn-select <%= selStab == 0 ? "is-selected" : "" %>">
                                <%= selStab == 0 ? "✓ Đang chọn" : "Bỏ qua" %>
                            </button>
                        </div>
                    </div>

                    <% if (stabs != null) { for (BuilderProduct p : stabs) {
                        boolean isCompat = p.isCompatible();
                    %>
                    <div class="cb-product-card <%= p.getId() == selStab ? "selected" : "" %> <%= !isCompat ? "incompatible-card" : "" %>"
                         data-id="<%= p.getId() %>"
                         data-shop="<%= p.getShopName().replace("\"","&quot;") %>"
                         data-compat="<%= isCompat ? "1" : "0" %>"
                         data-mount="<%= p.getMountType() != null ? p.getMountType() : "" %>"
                         data-name="<%= p.getName().replace("\"","&quot;") %>"
                         data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                         data-price="<%= p.getPrice() %>"
                         data-specs="<%= p.getOptionSpecs() != null ? p.getOptionSpecs().replace("\"","&quot;") : "" %>"
                         onclick="selectPart('stab', this)">
                        <div class="cb-card-badge-row">
                            <% if (isCompat) { %>
                            <span class="cb-badge-compat">Tương thích</span>
                            <% } else { %>
                            <span class="cb-badge-incompat">Không lắp vừa</span>
                            <% } %>
                            <span class="cb-badge-stock"><%= p.getShopName() %> · <%= p.getStockText() %></span>
                        </div>
                        <div class="cb-card-thumb" style="height:90px;display:flex;align-items:center;justify-content:center;">
                            <div class="cb-illus-stab">
                                <span class="cb-wire"></span>
                                <span class="cb-housing left"></span>
                                <span class="cb-housing right"></span>
                            </div>
                        </div>
                        <div class="cb-card-info">
                            <h3 class="cb-card-title"><%= p.getName() %></h3>
                            <div class="cb-card-specs"><%= p.getOptionSpecs() %></div>
                            <div class="cb-card-price-row">
                                <span class="cb-card-price"><%= p.getFormattedPrice() %></span>
                            </div>
                        </div>
                        <div class="cb-card-action">
                            <% if (isCompat) { %>
                            <button type="button" class="cb-btn-select <%= p.getId() == selStab ? "is-selected" : "" %>">
                                <%= p.getId() == selStab ? "✓ Đã chọn" : "Chọn" %>
                            </button>
                            <% } else { %>
                            <button type="button" class="cb-btn-disabled" disabled>Không tương thích</button>
                            <div class="cb-card-error-text"><%= p.getIncompatReason() %></div>
                            <% } %>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </div>

            <!-- Section 4B: Workshop & Custom Services -->
            <div class="cb-sub-section" style="margin-top:24px;">
                <div class="cb-sub-header">
                    <h3>2. Chọn Xưởng gia công &amp; Dịch vụ Modding</h3>
                    <span class="cb-sub-tag">Xưởng được chọn sẽ tiếp nhận toàn bộ linh kiện để lắp ráp trọn bộ</span>
                </div>

                <div class="cb-workshop-tabs" id="workshopTabs">
                    <button type="button" class="cb-ws-tab <%= selService == 0 ? "active" : "" %>" onclick="selectNoWorkshop(this)">
                        🛠️ Không cần gia công (Tự ráp)
                    </button>
                    <% if (workshops != null) {
                        for (Shop ws : workshops) { %>
                    <button type="button" class="cb-ws-tab <%= (selService > 0 && ws.getId() == 2) ? "active" : "" %>"
                            data-ws="<%= ws.getId() %>" onclick="switchWorkshop(<%= ws.getId() %>, this)">
                        <span class="cb-ws-avatar" style="background:<%= ws.getAvatarColor() != null ? ws.getAvatarColor() : "#1B64F2" %>"><%= ws.getAvatarText() %></span>
                        <span><%= ws.getShopName() %></span>
                        <span class="cb-ws-rate">★ <%= ws.getRatingAvg() %></span>
                    </button>
                    <% } } %>
                </div>

                <% if (workshops != null) {
                    for (Shop ws : workshops) {
                        List<CustomServiceItem> svcs = servicesMap != null ? servicesMap.get(ws.getId()) : null;
                %>
                <div class="cb-services-container <%= ws.getId() == 2 ? "active" : "" %>" id="ws-services-<%= ws.getId() %>">
                    <div class="cb-cards-grid grid-3col">
                        <% if (svcs != null) { for (CustomServiceItem svc : svcs) { %>
                        <div class="cb-service-card <%= svc.isPopular() ? "popular" : "" %> <%= svc.getId() == selService ? "selected" : "" %>"
                             data-id="<%= svc.getId() %>"
                             data-name="<%= svc.getServiceName().replace("\"","&quot;") %>"
                             data-price="<%= svc.getPrice() %>"
                             data-ws="<%= ws.getShopName().replace("\"","&quot;") %>"
                             data-wsavatar="<%= ws.getAvatarText() != null ? ws.getAvatarText() : "SH" %>"
                             data-duration="<%= svc.getDurationText() %>"
                             onclick="selectServiceCard(<%= svc.getId() %>, '<%= svc.getServiceName().replace("'","\\'") %>', <%= svc.getPrice() %>, '<%= ws.getShopName().replace("'","\\'") %>', '<%= ws.getAvatarText() != null ? ws.getAvatarText() : "SH" %>', '<%= svc.getDurationText() %>', this)">

                            <% if (svc.isPopular()) { %>
                            <div class="cb-popular-tag">Phổ biến nhất</div>
                            <% } %>

                            <h4 class="cb-svc-title"><%= svc.getServiceName() %></h4>
                            <div class="cb-svc-price"><%= svc.getFormattedPrice() %></div>
                            <div class="cb-svc-duration">⏱ Dự kiến <%= svc.getDurationText() %> · tại <strong><%= ws.getShopName() %></strong></div>

                            <ul class="cb-svc-features">
                                <% for (String f : svc.getDescription().split(";")) { %>
                                <li>✓ <%= f.trim() %></li>
                                <% } %>
                            </ul>

                            <button type="button" class="cb-btn-select <%= svc.getId() == selService ? "is-selected" : "" %>">
                                <%= svc.getId() == selService ? "✓ Đã chọn gói này" : "Chọn gói này" %>
                            </button>
                        </div>
                        <% } } %>
                    </div>
                </div>
                <% } } %>
            </div>

            <div class="cb-step-footer">
                <div class="cb-step-footer-left">
                    <button type="button" class="cb-btn-secondary" onclick="goToStep(3)">&lt; Quay lại chọn keycap</button>
                </div>
                <div class="cb-step-footer-center">Đã chọn dịch vụ &amp; stabilizer</div>
                <div class="cb-step-footer-right">
                    <button type="button" class="cb-btn-primary" onclick="goToStep(5)">Xem lại cấu hình &amp; Đặt hàng &gt;</button>
                </div>
            </div>
        </section>

        <!-- BƯỚC 5: XEM LẠI & ĐẶT HÀNG -->
        <section class="cb-step-view <%= currentStep == 5 ? "active" : "" %>" id="stepView-5">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 5 · Xem lại cấu hình &amp; Đặt hàng</h2>
                    <p class="cb-step-sub">Đối chiếu thông số kỹ thuật Build Sheet, nguồn cung linh kiện và xưởng chịu trách nhiệm lắp ráp</p>
                </div>
            </div>

            <!-- BUILD SHEET CARD (Động 100% theo Xưởng hoặc Shop bán Kit) -->
            <div class="cb-build-sheet-card">
                <div class="cb-bs-head">
                    <div class="cb-bs-shop">
                        <span class="cb-bs-shop-badge" id="bsShopBadge">SH</span>
                        <strong id="bsShopName">SwitchHouse</strong>
                        <span class="cb-badge-custom-order" id="bsOrderTypeBadge">Đơn custom - có gia công</span>
                    </div>
                    <div class="cb-bs-price" id="bsTotalPrice">5.320.000đ</div>
                </div>

                <div class="cb-bs-body">
                    <div class="cb-bs-title-row">
                        <h3 class="cb-bs-title">Bàn phím custom theo cấu hình của bạn</h3>
                        <p class="cb-bs-pkg-info" id="bsPkgDuration">Gói gia công: Full lube + tune · dự kiến 5-7 ngày</p>
                    </div>

                    <div class="cb-bs-spec-box">
                        <div class="cb-bs-box-title">📋 BUILD SHEET CHI TIẾT &amp; NGUỒN CUNG LINH KIỆN</div>
                        <div class="cb-bs-table">
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Kit chính</span>
                                <span class="cb-bs-td" id="bsKitVal">Tofu60 2.0</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Switch</span>
                                <span class="cb-bs-td" id="bsSwVal">Gateron Oil King ×70</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Keycap</span>
                                <span class="cb-bs-td" id="bsKeycapVal">GMK Olivia++ Cherry</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Stabilizer</span>
                                <span class="cb-bs-td" id="bsStabVal">Durock V2 screw-in</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Đơn vị xử lý</span>
                                <span class="cb-bs-td" id="bsSvcVal">Tự lắp ráp</span>
                            </div>
                        </div>
                        <div class="cb-bs-links">
                            <a href="javascript:void(0)" onclick="goToStep(1)">✏️ Sửa cấu hình</a>
                            <a href="javascript:void(0)" onclick="openBuildSheetModal()">📄 Xem Build Sheet đầy đủ</a>
                        </div>
                    </div>

                    <div class="cb-bs-workshop-notice" id="bsFulfillmentNotice">
                        <span class="cb-bs-notice-icon">🛠️</span>
                        <div id="bsFulfillmentText">
                            <strong>Cơ chế điều phối liên shop của KeebHub:</strong> Các linh kiện thuộc nhiều gian hàng khác nhau trong cấu hình này sẽ được hệ thống tập kết về <strong>Xưởng gia công bạn đã chọn</strong> để kỹ thuật viên kiểm tra tương thích, mod, lắp ráp hoàn chỉnh và gửi <strong>Phiếu báo giá chốt đơn</strong> cho bạn trong vòng 24 giờ.
                        </div>
                    </div>
                </div>
            </div>

            <!-- COMPATIBILITY VERIFICATION PANEL -->
            <div class="cb-compat-check-panel">
                <div class="cb-compat-panel-head">
                    <span class="cb-compat-panel-title">🛡️ Xác nhận kiểm tra tương thích hệ thống</span>
                    <%
                        boolean isAllOk = compatResults != null && compatResults.stream().allMatch(CompatResult::isCompatible);
                    %>
                    <span class="cb-badge-compat <%= isAllOk ? "" : "cb-badge-incompat" %>" id="step5CompatBadge">
                        <%= isAllOk ? "✓ 100% Tương thích hoàn hảo" : "⚠️ Cần lưu ý độ tương thích" %>
                    </span>
                </div>
                <div class="cb-compat-checklist" id="step5CompatChecklist">
                    <% if (compatResults != null) {
                        for (CompatResult cr : compatResults) {
                            String iconClass = "ok";
                            String iconChar = "✓";
                            if ("WARN".equalsIgnoreCase(cr.getLevel())) {
                                iconClass = "warn";
                                iconChar = "⚠️";
                            } else if ("ERROR".equalsIgnoreCase(cr.getLevel())) {
                                iconClass = "err";
                                iconChar = "✕";
                            }
                    %>
                    <div class="cb-c-item">
                        <span class="cb-c-icon <%= iconClass %>"><%= iconChar %></span>
                        <div class="cb-c-text">
                            <strong><%= cr.getTitle() %></strong>
                            <span><%= cr.getMessage() %></span>
                        </div>
                    </div>
                    <%  }
                    } %>
                </div>
            </div>

            <!-- CHECKOUT FORM -->
            <div class="cb-checkout-card">
                <div class="cb-checkout-head">
                    <h3>📦 Thông tin nhận hàng &amp; Phương thức thanh toán</h3>
                    <p>Đơn hàng sẽ được chuyển tới Xưởng/Shop để lập Phiếu báo giá xác nhận trước khi bàn giao</p>
                </div>

                <form method="post" action="custom-builder" id="finalOrderForm">
                    <input type="hidden" name="action" value="place-order">
                    <input type="hidden" name="kitId" id="finalKitId" value="<%= selKit %>">
                    <input type="hidden" name="switchId" id="finalSwId" value="<%= selSwitch %>">
                    <input type="hidden" name="keycapId" id="finalKeycapId" value="<%= selKeycap %>">
                    <input type="hidden" name="stabId" id="finalStabId" value="<%= selStab %>">
                    <input type="hidden" name="serviceId" id="finalSvcId" value="<%= selService %>">
                    <input type="hidden" name="switchQty" id="finalSwQty" value="70">

                    <div class="cb-form-grid">
                        <div class="cb-form-group">
                            <label>Họ và tên người nhận *</label>
                            <input type="text" name="receiverName"
                                   value="<%= currentUser != null ? currentUser.getFullName() : "" %>"
                                   required placeholder="VD: Nguyễn Văn Anh">
                        </div>
                        <div class="cb-form-group">
                            <label>Số điện thoại *</label>
                            <input type="tel" name="receiverPhone"
                                   value="<%= currentUser != null && currentUser.getPhone() != null ? currentUser.getPhone() : "" %>"
                                   required placeholder="VD: 0987654321">
                        </div>
                    </div>

                    <div class="cb-form-group">
                        <label>Địa chỉ nhận hàng chi tiết *</label>
                        <input type="text" name="shippingAddress"
                               value="<%= currentUser != null && currentUser.getAddress() != null ? currentUser.getAddress() : "" %>"
                               required placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành">
                    </div>

                    <div class="cb-form-group">
                        <label>Ghi chú yêu cầu riêng cho kỹ thuật viên xưởng mod</label>
                        <textarea name="customNote" rows="2"
                                  placeholder="VD: Cân stab phím Space thật êm, ưu tiên âm trầm thocky, tape mod 2 lớp..."></textarea>
                    </div>

                    <div class="cb-form-group">
                        <label>Phương thức thanh toán qua Sàn</label>
                        <div class="cb-pay-options">
                            <label class="cb-pay-option active">
                                <input type="radio" name="paymentMethod" value="VNPAY-QR" checked>
                                <span>🏦 VNPAY-QR</span>
                            </label>
                            <label class="cb-pay-option">
                                <input type="radio" name="paymentMethod" value="MoMo">
                                <span>📱 Ví MoMo</span>
                            </label>
                            <label class="cb-pay-option">
                                <input type="radio" name="paymentMethod" value="ZaloPay">
                                <span>⚡ ZaloPay</span>
                            </label>
                        </div>
                    </div>

                    <div class="cb-checkout-submit-row">
                        <button type="submit" class="cb-btn-checkout-submit">
                            🛒 Gửi yêu cầu đặt Build Custom — <span id="btnSubmitTotal">4.200.000đ</span>
                        </button>
                    </div>
                </form>
            </div>

            <div class="cb-step-footer">
                <div class="cb-step-footer-left">
                    <button type="button" class="cb-btn-secondary" onclick="goToStep(4)">&lt; Quay lại chỉnh gia công</button>
                </div>
            </div>
        </section>

    </main>

    <!-- RIGHT SIDEBAR -->
    <aside class="cb-sidebar-col">
        <div class="cb-side-card">
            <div class="cb-side-card-head">
                <h4>Xem trước cấu hình</h4>
                <span class="cb-preview-badge" id="previewLayoutBadge">60% ANSI</span>
            </div>
            <div class="cb-keeb-preview-container">
                <div class="cb-keeb-case" id="keebCaseGraphic">
                    <div class="cb-keeb-plate">
                        <div class="cb-preview-row">
                            <span class="cb-k esc accent"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k bsp accent"></span>
                        </div>
                        <div class="cb-preview-row">
                            <span class="cb-k tab accent"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k slash"></span>
                        </div>
                        <div class="cb-preview-row">
                            <span class="cb-k caps accent"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k enter accent"></span>
                        </div>
                        <div class="cb-preview-row">
                            <span class="cb-k shift-l accent"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k"></span><span class="cb-k shift-r accent"></span>
                        </div>
                        <div class="cb-preview-row">
                            <span class="cb-k mod accent"></span><span class="cb-k mod accent"></span><span class="cb-k mod accent"></span><span class="cb-k space accent"></span><span class="cb-k mod accent"></span><span class="cb-k mod accent"></span><span class="cb-k mod accent"></span><span class="cb-k mod accent"></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="cb-side-card">
            <div class="cb-side-card-head">
                <h4>Cấu hình của bạn</h4>
            </div>

            <div class="cb-side-items-list">
                <div class="cb-side-item" id="sideItem-kit">
                    <div class="cb-side-item-main">
                        <div class="cb-side-item-name-row">
                            <strong id="sideKitName">Tofu60 2.0 Aluminium</strong>
                            <a href="javascript:void(0)" class="cb-side-edit-link" onclick="goToStep(1)">Sửa</a>
                        </div>
                        <div class="cb-side-item-sub" id="sideKitSub">Silver · Brass plate</div>
                    </div>
                    <div class="cb-side-item-price" id="sideKitPrice">2.690.000đ</div>
                </div>

                <div class="cb-side-item" id="sideItem-sw">
                    <div class="cb-side-item-main">
                        <div class="cb-side-item-name-row">
                            <strong id="sideSwName">Gateron Oil King ×70</strong>
                            <a href="javascript:void(0)" class="cb-side-edit-link" onclick="goToStep(2)">Sửa</a>
                        </div>
                        <div class="cb-side-item-sub" id="sideSwSub">Linear 55g · lube nhà máy</div>
                    </div>
                    <div class="cb-side-item-price" id="sideSwPrice">890.000đ</div>
                </div>

                <div class="cb-side-item" id="sideItem-keycap">
                    <div class="cb-side-item-main">
                        <div class="cb-side-item-name-row">
                            <strong id="sideKeycapName" class="empty">Chưa chọn keycap</strong>
                            <a href="javascript:void(0)" class="cb-side-edit-link" onclick="goToStep(3)">Sửa</a>
                        </div>
                        <div class="cb-side-item-sub" id="sideKeycapSub">Bước 3</div>
                    </div>
                    <div class="cb-side-item-price" id="sideKeycapPrice">—</div>
                </div>

                <div class="cb-side-item" id="sideItem-stab">
                    <div class="cb-side-item-main">
                        <div class="cb-side-item-name-row">
                            <strong id="sideStabName">Durock V2 screw-in</strong>
                            <a href="javascript:void(0)" class="cb-side-edit-link" onclick="goToStep(4)">Sửa</a>
                        </div>
                        <div class="cb-side-item-sub" id="sideStabSub">PCB-mount · đã lube</div>
                    </div>
                    <div class="cb-side-item-price" id="sideStabPrice">420.000đ</div>
                </div>

                <div class="cb-side-item" id="sideItem-svc">
                    <div class="cb-side-item-main">
                        <div class="cb-side-item-name-row">
                            <strong id="sideSvcName" class="empty">Chưa chọn gói gia công</strong>
                            <a href="javascript:void(0)" class="cb-side-edit-link" onclick="goToStep(4)">Sửa</a>
                        </div>
                        <div class="cb-side-item-sub" id="sideSvcSub">Bước 4</div>
                    </div>
                    <div class="cb-side-item-price" id="sideSvcPrice">—</div>
                </div>
            </div>

            <div class="cb-side-price-box">
                <div class="cb-price-line">
                    <span>Tạm tính linh kiện</span>
                    <strong id="sidePartsSubtotal">3.580.000đ</strong>
                </div>
                <div class="cb-price-line">
                    <span>Phí gia công</span>
                    <strong id="sideSvcSubtotal">Chưa chọn</strong>
                </div>
                <div class="cb-price-line discount">
                    <span>Ưu đãi combo build</span>
                    <strong id="sideDiscount">-150.000đ</strong>
                </div>
                <div class="cb-price-divider"></div>
                <div class="cb-price-line grand-total">
                    <span>Tổng tạm tính</span>
                    <strong id="sideGrandTotal">4.200.000đ</strong>
                </div>
            </div>

            <div class="cb-side-compat-badge-box">
                <div class="cb-side-compat-status" id="sideCompatStatus">
                    ✓ Tất cả linh kiện đã chọn đều tương thích
                </div>
                <div class="cb-side-duration-hint" id="sideDurationHint">
                    🕒 Chọn gói gia công ở Bước 4 để chỉ định xưởng lắp ráp
                </div>
            </div>

            <div class="cb-inventory-lock-banner">
                <div class="cb-lock-top">
                    <span class="cb-lock-icon">🔒</span>
                    <span>Đã giữ chỗ tồn kho cho cấu hình này · còn <strong id="lockTimer">14:22</strong></span>
                </div>
                <div class="cb-lock-sub">Hết giờ, linh kiện sẽ mở lại cho người khác</div>
            </div>

            <div class="cb-side-cta-buttons">
                <button type="button" class="cb-btn-side-orange" id="sidePrimaryCta" onclick="handlePrimaryCta()">
                    Thêm vào giỏ &amp; đặt hàng
                </button>
                <button type="button" class="cb-btn-side-outline" onclick="saveDraft()">
                    💾 Lưu cấu hình này
                </button>
            </div>

            <div class="cb-side-footer-links">
                <a href="javascript:void(0)" onclick="shareBuild()">Chia sẻ build</a>
                <span>·</span>
                <a href="javascript:void(0)" onclick="openBuildSheetModal()">Xuất Build Sheet</a>
            </div>
        </div>
    </aside>
</div>

<!-- MODAL: XUẤT BUILD SHEET ĐẦY ĐỦ -->
<div class="cb-modal-overlay" id="buildSheetModal" onclick="closeBuildSheetModal(event)">
    <div class="cb-modal-dialog">
        <div class="cb-modal-head">
            <h3>📄 Build Sheet Bàn Phím Custom — KeebHub</h3>
            <button type="button" class="cb-modal-close" onclick="closeBuildSheetModal()">&times;</button>
        </div>
        <div class="cb-modal-body" id="printableBuildSheet">
            <div class="modal-bs-shop-header">
                <div>
                    <h4 id="mShopTitle">SwitchHouse Workshop</h4>
                    <p>Đơn vị chịu trách nhiệm tiếp nhận &amp; bàn giao cấu hình</p>
                </div>
                <span class="cb-badge-custom-order">Custom Build</span>
            </div>
            <table class="modal-bs-table">
                <tbody>
                <tr><th>Kit bàn phím</th><td id="mKitVal">Tofu60 2.0 Aluminium</td><td id="mKitPrice">2.690.000₫</td></tr>
                <tr><th>Switch</th><td id="mSwVal">Gateron Oil King Linear 55g</td><td id="mSwPrice">890.000₫</td></tr>
                <tr><th>Keycap</th><td id="mKeycapVal">GMK Olivia++ Cherry profile</td><td id="mKeycapPrice">4.150.000₫</td></tr>
                <tr><th>Stabilizer</th><td id="mStabVal">Durock V2 PCB-mount screw-in</td><td id="mStabPrice">420.000₫</td></tr>
                <tr><th>Dịch vụ mod</th><td id="mSvcVal">Full lube + tune stab</td><td id="mSvcPrice">750.000₫</td></tr>
                <tr class="modal-bs-total-row"><th>TỔNG CỘNG</th><td>Đã áp dụng ưu đãi combo build (-150k)</td><td id="mTotalPrice">8.750.000₫</td></tr>
                </tbody>
            </table>
            <div class="modal-bs-compat-note">
                🛡️ Chứng nhận độ tương thích: <strong>100% Linh kiện tương thích hoàn toàn</strong>. Socket hotswap, profile keycap và cấu trúc stab đã được hệ thống KeebHub đối chiếu với cơ sở dữ liệu kỹ thuật.
            </div>
        </div>
        <div class="cb-modal-footer">
            <button type="button" class="cb-btn-secondary" onclick="window.print()">🖨️ In Build Sheet</button>
            <button type="button" class="cb-btn-primary" onclick="closeBuildSheetModal()">Đóng</button>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<script>
    let currentStep = <%= currentStep %>;

    const buildState = {
        kit: {
            id: <%= selKit %>,
            name: '<%= selectedKit != null ? selectedKit.getName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shortName: '<%= selectedKit != null ? selectedKit.getShortName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shopName: '<%= selectedKit != null ? selectedKit.getShopName().replace("\\", "\\\\").replace("'", "\\'") : "KeebLab Store" %>',
            price: <%= selectedKit != null ? selectedKit.getPrice() : 0 %>,
            specs: '<%= selectedKit != null && selectedKit.getOptionSpecs() != null ? selectedKit.getOptionSpecs().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            layout: '<%= selectedKit != null && selectedKit.getLayout() != null ? selectedKit.getLayout().replace("'", "\\'") : "60%" %>',
            pinType: '<%= selectedKit != null && selectedKit.getPinType() != null ? selectedKit.getPinType().replace("'", "\\'") : "5-pin" %>',
            mountType: '<%= selectedKit != null && selectedKit.getMountType() != null ? selectedKit.getMountType().replace("'", "\\'") : "Gasket mount" %>'
        },
        sw: {
            id: <%= selSwitch %>,
            name: '<%= selectedSwitch != null ? selectedSwitch.getName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shortName: '<%= selectedSwitch != null ? selectedSwitch.getShortName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shopName: '<%= selectedSwitch != null ? selectedSwitch.getShopName().replace("\\", "\\\\").replace("'", "\\'") : "SwitchHouse" %>',
            price: <%= selectedSwitch != null ? selectedSwitch.getPrice() : 0 %>,
            specs: '<%= selectedSwitch != null && selectedSwitch.getOptionSpecs() != null ? selectedSwitch.getOptionSpecs().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            color: '<%= selectedSwitch != null && selectedSwitch.getSwitchColor() != null ? selectedSwitch.getSwitchColor() : "black" %>'
        },
        keycap: {
            id: <%= selKeycap %>,
            name: '<%= selectedKeycap != null ? selectedKeycap.getName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shortName: '<%= selectedKeycap != null ? selectedKeycap.getShortName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shopName: '<%= selectedKeycap != null ? selectedKeycap.getShopName().replace("\\", "\\\\").replace("'", "\\'") : "Tự trang bị" %>',
            price: <%= selectedKeycap != null ? selectedKeycap.getPrice() : 0 %>,
            specs: '<%= selectedKeycap != null && selectedKeycap.getOptionSpecs() != null ? selectedKeycap.getOptionSpecs().replace("\\", "\\\\").replace("'", "\\'") : "" %>'
        },
        stab: {
            id: <%= selStab %>,
            name: '<%= selectedStab != null ? selectedStab.getName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shortName: '<%= selectedStab != null ? selectedStab.getShortName().replace("\\", "\\\\").replace("'", "\\'") : "" %>',
            shopName: '<%= selectedStab != null ? selectedStab.getShopName().replace("\\", "\\\\").replace("'", "\\'") : "SwitchHouse" %>',
            price: <%= selectedStab != null ? selectedStab.getPrice() : 0 %>,
            specs: '<%= selectedStab != null && selectedStab.getOptionSpecs() != null ? selectedStab.getOptionSpecs().replace("\\", "\\\\").replace("'", "\\'") : "" %>'
        },
        svc: {
            id: <%= selService %>,
            name: '',
            shortName: '',
            price: 0,
            shopName: '',
            wsAvatar: 'SH',
            duration: '3-5 ngày'
        }
    };

    const completedSteps = new Set();
    if (<%= selKit > 0 %>) completedSteps.add(1);
    if (<%= selSwitch > 0 && currentStep > 2 %>) completedSteps.add(2);
    if (<%= selKeycap > 0 && currentStep > 3 %>) completedSteps.add(3);
    if (<%= (selStab > 0 || selService > 0) && currentStep > 4 %>) completedSteps.add(4);

    function updateStepperUI() {
        const pills = document.querySelectorAll('#cbStepper .cb-step-pill');
        pills.forEach((pill, idx) => {
            const stepNum = idx + 1;
            const badge = pill.querySelector('.cb-step-badge');
            pill.classList.remove('active', 'done');
            if (stepNum === currentStep) {
                pill.classList.add('active');
                if (badge) badge.textContent = stepNum;
            } else if (isStepEligibleDone(stepNum)) {
                pill.classList.add('done');
                if (badge) badge.textContent = '✓';
            } else {
                if (badge) badge.textContent = stepNum;
            }
        });
    }

    function isStepEligibleDone(stepNum) {
        if (stepNum === 1) return (buildState.kit && buildState.kit.id > 0) && (stepNum < currentStep || completedSteps.has(1));
        if (stepNum === 2) return (buildState.sw && buildState.sw.id > 0) && (stepNum < currentStep || completedSteps.has(2));
        if (stepNum === 3) return (buildState.keycap && (buildState.keycap.id > 0 || (buildState.keycap.shortName && buildState.keycap.shortName.length > 0))) && (stepNum < currentStep || completedSteps.has(3));
        if (stepNum === 4) return ((buildState.stab && buildState.stab.id > 0) || (buildState.svc && buildState.svc.id > 0) || completedSteps.has(4)) && (stepNum < currentStep || completedSteps.has(4));
        return false;
    }

    function goToStep(step) {
        if (step < 1 || step > 5) return;
        if (currentStep < step) {
            for (let i = 1; i < step; i++) completedSteps.add(i);
        }
        currentStep = step;
        document.querySelectorAll('.cb-step-view').forEach(v => v.classList.remove('active'));
        const targetView = document.getElementById('stepView-' + step);
        if (targetView) targetView.classList.add('active');
        updateStepperUI();

        const primaryCta = document.getElementById('sidePrimaryCta');
        if (primaryCta) {
            primaryCta.textContent = (step < 5) ? 'Tiếp tục bước tiếp theo >' : 'Gửi yêu cầu đặt Build Custom';
        }
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function handlePrimaryCta() {
        if (currentStep < 5) {
            goToStep(currentStep + 1);
        } else {
            const form = document.getElementById('finalOrderForm');
            if (form) form.submit();
        }
    }

    function selectPart(type, el) {
        if (!el) return;
        const card = el.classList.contains('cb-product-card') ? el : el.closest('.cb-product-card');
        if (!card) return;
        if (card.classList.contains('incompatible-card') && (el.classList.contains('cb-btn-disabled') || el.closest('.cb-btn-disabled'))) {
            return;
        }

        const grid = card.closest('.cb-cards-grid');
        if (grid) {
            grid.querySelectorAll('.cb-product-card').forEach(c => {
                c.classList.remove('selected');
                const btn = c.querySelector('.cb-btn-select');
                if (btn) {
                    btn.classList.remove('is-selected');
                    btn.textContent = (c.classList.contains('none-card')) ? 'Bỏ qua' : 'Chọn';
                }
            });
        }

        card.classList.add('selected');
        const selBtn = card.querySelector('.cb-btn-select');
        if (selBtn) {
            selBtn.classList.add('is-selected');
            selBtn.textContent = '✓ Đã chọn';
        }

        const id = parseInt(card.dataset.id) || 0;
        const name = card.dataset.name || '';
        const shortName = card.dataset.shortname || name;
        const shopName = card.dataset.shop || 'KeebLab Store';
        const price = parseInt(card.dataset.price) || 0;
        const specs = card.dataset.specs || '';
        const color = card.dataset.color || 'black';

        if (type === 'kit') {
            const layout = card.dataset.layout || '60%';
            const pinType = card.dataset.pin || '5-pin';
            const mountType = card.dataset.mount || 'Gasket mount';
            buildState.kit = { id, name, shortName, shopName, price, specs, layout, pinType, mountType };
            completedSteps.add(1);
            onKitChanged();
        } else if (type === 'sw') {
            buildState.sw = { id, name, shortName, shopName, price, specs, color };
            completedSteps.add(2);
        } else if (type === 'keycap') {
            buildState.keycap = { id, name, shortName, shopName, price, specs };
            completedSteps.add(3);
        } else if (type === 'stab') {
            buildState.stab = { id, name, shortName, shopName, price, specs };
            completedSteps.add(4);
        }

        updateSidebarDisplay();
        updateKeyboardGraphic();
        syncFormInputs();
        updateStepperUI();
        checkLiveCompatibility();
    }

    function onKitChanged() {
        const kit = buildState.kit;
        const sub = document.getElementById('switchKitSubtitle');
        if (sub) {
            sub.innerHTML = 'Đang lọc theo kit đã chọn: <strong>' + escapeHtml(kit.name) + '</strong> · ' + escapeHtml(kit.pinType) + ' · south-facing LED';
        }

        let reqSwitches = 70;
        if (kit.layout.includes('Full') || kit.layout.includes('100%') || kit.layout.includes('96%')) reqSwitches = 100;
        else if (kit.layout.includes('TKL') || kit.layout.includes('87')) reqSwitches = 87;
        else if (kit.layout.includes('75%')) reqSwitches = 84;
        else if (kit.layout.includes('65%')) reqSwitches = 68;

        const countNote = document.getElementById('switchCountNote');
        if (countNote) countNote.textContent = 'Cần ' + reqSwitches + ' switch cho layout ' + kit.layout;
        const countStatus = document.getElementById('switchCountStatus');
        if (countStatus) countStatus.textContent = 'Đã chọn ' + reqSwitches + '/' + reqSwitches + ' switch';
        const finalSwQty = document.getElementById('finalSwQty');
        if (finalSwQty) finalSwQty.value = reqSwitches;

        const prevBadge = document.getElementById('previewLayoutBadge');
        if (prevBadge) prevBadge.textContent = kit.layout + ' ANSI';
    }

    function checkLiveCompatibility() {
        const params = new URLSearchParams({
            action: 'check-compat',
            format: 'json',
            kitId: buildState.kit.id,
            switchId: buildState.sw.id,
            keycapId: buildState.keycap.id,
            stabId: buildState.stab.id,
            serviceId: buildState.svc.id,
            step: currentStep
        });

        fetch('custom-builder', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params.toString()
        })
            .then(res => res.json())
            .then(data => {
                if (!data || !data.success) return;
                const isAllOk = data.allCompatible;

                const sideStatus = document.getElementById('sideCompatStatus');
                if (sideStatus) {
                    if (isAllOk) {
                        sideStatus.className = 'cb-side-compat-status';
                        sideStatus.textContent = '✓ Tất cả linh kiện đã chọn đều tương thích';
                    } else {
                        sideStatus.className = 'cb-side-compat-status compat-warn';
                        sideStatus.textContent = '⚠️ Có linh kiện chưa tương thích hoàn hảo';
                    }
                }

                const step5Badge = document.getElementById('step5CompatBadge');
                if (step5Badge) {
                    if (isAllOk) {
                        step5Badge.className = 'cb-badge-compat';
                        step5Badge.textContent = '✓ 100% Tương thích hoàn hảo';
                    } else {
                        step5Badge.className = 'cb-badge-compat cb-badge-incompat';
                        step5Badge.textContent = '⚠️ Cần lưu ý độ tương thích';
                    }
                }

                const checklist = document.getElementById('step5CompatChecklist');
                if (checklist && data.results) {
                    let html = '';
                    data.results.forEach(cr => {
                        let iconClass = 'ok';
                        let iconChar = '✓';
                        if (cr.level === 'WARN') {
                            iconClass = 'warn';
                            iconChar = '⚠️';
                        } else if (cr.level === 'ERROR') {
                            iconClass = 'err';
                            iconChar = '✕';
                        }
                        html += '<div class="cb-c-item">' +
                            '<span class="cb-c-icon ' + iconClass + '">' + iconChar + '</span>' +
                            '<div class="cb-c-text">' +
                            '<strong>' + escapeHtml(cr.title) + '</strong>' +
                            '<span>' + escapeHtml(cr.message) + '</span>' +
                            '</div>' +
                            '</div>';
                    });
                    checklist.innerHTML = html;
                }
            })
            .catch(err => console.warn('Compatibility check error:', err));
    }

    function selectServiceCard(id, name, price, wsName, wsAvatar, duration, card) {
        document.querySelectorAll('.cb-service-card').forEach(c => {
            c.classList.remove('selected');
            const btn = c.querySelector('.cb-btn-select');
            if (btn) {
                btn.classList.remove('is-selected');
                btn.textContent = 'Chọn gói này';
            }
        });

        if (card) {
            card.classList.add('selected');
            const btn = card.querySelector('.cb-btn-select');
            if (btn) {
                btn.classList.add('is-selected');
                btn.textContent = '✓ Đã chọn gói này';
            }
        }

        buildState.svc = { id, name, shortName: name, price, shopName: wsName, wsAvatar: wsAvatar || 'SH', duration };
        completedSteps.add(4);
        updateSidebarDisplay();
        syncFormInputs();
        updateStepperUI();
    }

    function selectNoWorkshop(tab) {
        document.querySelectorAll('#workshopTabs .cb-ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.cb-services-container').forEach(c => c.classList.remove('active'));
        selectServiceCard(0, 'Tự lắp ráp (Không gia công)', 0, '', 'KB', 'Giao nguyên hộp', null);
    }

    function switchWorkshop(wsId, tab) {
        document.querySelectorAll('#workshopTabs .cb-ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.cb-services-container').forEach(c => c.classList.remove('active'));
        const target = document.getElementById('ws-services-' + wsId);
        if (target) target.classList.add('active');
    }

    function updateSidebarDisplay() {
        const kitEl = document.getElementById('sideKitName');
        const kitSub = document.getElementById('sideKitSub');
        const kitPr = document.getElementById('sideKitPrice');
        if (buildState.kit.id > 0) {
            kitEl.textContent = buildState.kit.shortName;
            kitEl.className = '';
            kitSub.textContent = buildState.kit.shopName + ' · ' + buildState.kit.specs;
            kitPr.textContent = formatVND(buildState.kit.price);
        }

        const swEl = document.getElementById('sideSwName');
        const swSub = document.getElementById('sideSwSub');
        const swPr = document.getElementById('sideSwPrice');
        if (buildState.sw.id > 0) {
            swEl.textContent = buildState.sw.shortName;
            swEl.className = '';
            swSub.textContent = buildState.sw.shopName + ' · ' + buildState.sw.specs;
            swPr.textContent = formatVND(buildState.sw.price);
        }

        const kcEl = document.getElementById('sideKeycapName');
        const kcSub = document.getElementById('sideKeycapSub');
        const kcPr = document.getElementById('sideKeycapPrice');
        if (buildState.keycap.id > 0) {
            kcEl.textContent = buildState.keycap.shortName;
            kcEl.className = '';
            kcSub.textContent = buildState.keycap.shopName + ' · ' + buildState.keycap.specs;
            kcPr.textContent = formatVND(buildState.keycap.price);
        } else {
            kcEl.textContent = 'Chưa chọn keycap (Tự mua)';
            kcEl.className = 'empty';
            kcSub.textContent = 'Bước 3';
            kcPr.textContent = '—';
        }

        const stabEl = document.getElementById('sideStabName');
        const stabSub = document.getElementById('sideStabSub');
        const stabPr = document.getElementById('sideStabPrice');
        if (buildState.stab.id > 0) {
            stabEl.textContent = buildState.stab.shortName;
            stabEl.className = '';
            stabSub.textContent = buildState.stab.shopName + ' · ' + buildState.stab.specs;
            stabPr.textContent = formatVND(buildState.stab.price);
        } else {
            stabEl.textContent = 'Tự mua stab riêng';
            stabEl.className = 'empty';
            stabSub.textContent = 'Bước 4';
            stabPr.textContent = '—';
        }

        const svcEl = document.getElementById('sideSvcName');
        const svcSub = document.getElementById('sideSvcSub');
        const svcPr = document.getElementById('sideSvcPrice');
        const durHint = document.getElementById('sideDurationHint');

        if (buildState.svc.id > 0) {
            svcEl.textContent = buildState.svc.name;
            svcEl.className = '';
            svcSub.textContent = 'Xưởng: ' + buildState.svc.shopName + ' · ' + buildState.svc.duration;
            svcPr.textContent = formatVND(buildState.svc.price);
            if (durHint) durHint.textContent = '🛠️ Xưởng ' + buildState.svc.shopName + ' tiếp nhận & lắp ráp (' + buildState.svc.duration + ')';
        } else {
            svcEl.textContent = 'Tự lắp ráp (Không gia công)';
            svcEl.className = 'empty';
            svcSub.textContent = 'Đơn gửi về Shop bán Kit (' + (buildState.kit.shopName || 'KeebLab Store') + ')';
            svcPr.textContent = '0₫';
            if (durHint) durHint.textContent = '📦 Đơn giao linh kiện nguyên hộp từ ' + (buildState.kit.shopName || 'KeebLab Store');
        }

        const partsTotal = buildState.kit.price + buildState.sw.price + buildState.keycap.price + buildState.stab.price;
        const svcTotal = buildState.svc.price;
        const discount = (partsTotal > 0 && buildState.sw.id > 0) ? 150000 : 0;
        const grandTotal = Math.max(0, partsTotal + svcTotal - discount);

        document.getElementById('sidePartsSubtotal').textContent = formatVND(partsTotal);
        document.getElementById('sideSvcSubtotal').textContent = svcTotal > 0 ? formatVND(svcTotal) : '0₫ (Tự ráp)';
        document.getElementById('sideDiscount').textContent = discount > 0 ? '-150.000₫' : '0₫';
        document.getElementById('sideGrandTotal').textContent = formatVND(grandTotal);

        // Đồng bộ tên Xưởng / Shop chịu trách nhiệm lên Build Sheet ở Bước 5
        const responsibleShop = (buildState.svc.id > 0 && buildState.svc.shopName)
            ? buildState.svc.shopName
            : (buildState.kit.shopName || 'KeebLab Store');
        const responsibleBadge = (buildState.svc.id > 0 && buildState.svc.wsAvatar)
            ? buildState.svc.wsAvatar
            : responsibleShop.substring(0, 2).toUpperCase();

        const bsShopNameEl = document.getElementById('bsShopName');
        if (bsShopNameEl) bsShopNameEl.textContent = responsibleShop;
        const bsShopBadgeEl = document.getElementById('bsShopBadge');
        if (bsShopBadgeEl) bsShopBadgeEl.textContent = responsibleBadge;
        const bsOrderTypeBadge = document.getElementById('bsOrderTypeBadge');
        if (bsOrderTypeBadge) {
            bsOrderTypeBadge.textContent = (buildState.svc.id > 0)
                ? 'Đơn custom - Xưởng lắp ráp trọn bộ'
                : 'Đơn combo linh kiện - Khách tự lắp ráp';
        }
        const bsPkgDuration = document.getElementById('bsPkgDuration');
        if (bsPkgDuration) {
            bsPkgDuration.textContent = (buildState.svc.id > 0)
                ? ('Xưởng tiếp nhận gia công: ' + responsibleShop + ' · Gói: ' + buildState.svc.name + ' (' + buildState.svc.duration + ')')
                : ('Đơn vị tiếp nhận & điều phối linh kiện: ' + responsibleShop + ' (Không kèm gói gia công)');
        }

        const bsPrice = document.getElementById('bsTotalPrice');
        if (bsPrice) bsPrice.textContent = formatVND(grandTotal);
        const btnTotal = document.getElementById('btnSubmitTotal');
        if (btnTotal) btnTotal.textContent = formatVND(grandTotal);

        const bsKit = document.getElementById('bsKitVal');
        if (bsKit) bsKit.textContent = buildState.kit.shortName + ' · [Shop: ' + buildState.kit.shopName + ']';
        const bsSw = document.getElementById('bsSwVal');
        if (bsSw) bsSw.textContent = buildState.sw.shortName + ' · [Shop: ' + buildState.sw.shopName + ']';
        const bsKc = document.getElementById('bsKeycapVal');
        if (bsKc) bsKc.textContent = buildState.keycap.id > 0 ? (buildState.keycap.shortName + ' · [Shop: ' + buildState.keycap.shopName + ']') : 'Tự mua riêng';
        const bsSt = document.getElementById('bsStabVal');
        if (bsSt) bsSt.textContent = buildState.stab.id > 0 ? (buildState.stab.shortName + ' · [Shop: ' + buildState.stab.shopName + ']') : 'Tự mua riêng';
        const bsSvc = document.getElementById('bsSvcVal');
        if (bsSvc) {
            bsSvc.textContent = buildState.svc.id > 0
                ? (buildState.svc.name + ' tại xưởng ' + responsibleShop)
                : ('Tự lắp ráp — Điều phối qua ' + responsibleShop);
        }

        const mShopTitle = document.getElementById('mShopTitle');
        if (mShopTitle) mShopTitle.textContent = responsibleShop;
        const mKit = document.getElementById('mKitVal');
        if (mKit) {
            mKit.textContent = buildState.kit.name + ' [' + buildState.kit.shopName + ']';
            document.getElementById('mKitPrice').textContent = formatVND(buildState.kit.price);
            document.getElementById('mSwVal').textContent = buildState.sw.name + ' [' + buildState.sw.shopName + ']';
            document.getElementById('mSwPrice').textContent = formatVND(buildState.sw.price);
            document.getElementById('mKeycapVal').textContent = buildState.keycap.id > 0 ? (buildState.keycap.name + ' [' + buildState.keycap.shopName + ']') : 'Tự mua riêng';
            document.getElementById('mKeycapPrice').textContent = formatVND(buildState.keycap.price);
            document.getElementById('mStabVal').textContent = buildState.stab.id > 0 ? (buildState.stab.name + ' [' + buildState.stab.shopName + ']') : 'Tự mua riêng';
            document.getElementById('mStabPrice').textContent = formatVND(buildState.stab.price);
            document.getElementById('mSvcVal').textContent = buildState.svc.id > 0 ? (buildState.svc.name + ' (' + responsibleShop + ')') : 'Tự lắp ráp';
            document.getElementById('mSvcPrice').textContent = formatVND(buildState.svc.price);
            document.getElementById('mTotalPrice').textContent = formatVND(grandTotal);
        }
    }

    function syncFormInputs() {
        const finalKit = document.getElementById('finalKitId');
        if (finalKit) {
            finalKit.value = buildState.kit.id;
            document.getElementById('finalSwId').value = buildState.sw.id;
            document.getElementById('finalKeycapId').value = buildState.keycap.id;
            document.getElementById('finalStabId').value = buildState.stab.id;
            document.getElementById('finalSvcId').value = buildState.svc.id;
        }
    }

    function updateKeyboardGraphic() {
        const keebCase = document.getElementById('keebCaseGraphic');
        if (!keebCase) return;
        if (buildState.kit.name && buildState.kit.name.toLowerCase().includes('black')) {
            keebCase.style.borderColor = '#1E293B';
            keebCase.style.background = '#0F172A';
        } else {
            keebCase.style.borderColor = '#CBD5E1';
            keebCase.style.background = '#F8FAFC';
        }

        const keys = keebCase.querySelectorAll('.cb-k');
        if (buildState.keycap.id > 0 && buildState.keycap.name) {
            if (buildState.keycap.name.includes('Olivia')) {
                keys.forEach(k => {
                    if (k.classList.contains('accent')) {
                        k.style.background = '#FBCFE8';
                        k.style.borderColor = '#F472B6';
                    } else {
                        k.style.background = '#1E293B';
                        k.style.borderColor = '#334155';
                    }
                });
            } else if (buildState.keycap.name.includes('Pink')) {
                keys.forEach(k => {
                    if (k.classList.contains('accent')) {
                        k.style.background = '#FB7185';
                        k.style.borderColor = '#E11D48';
                    } else {
                        k.style.background = '#0F172A';
                        k.style.borderColor = '#1E293B';
                    }
                });
            }
        }
    }

    function filterSwitch(type, pill) {
        if (pill) {
            pill.parentElement.querySelectorAll('.cb-filter-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
        }
        const onlyCompat = document.getElementById('onlyCompatToggle').checked;
        const cards = document.querySelectorAll('#switchGrid .cb-product-card');
        cards.forEach(card => {
            const cardType = card.dataset.type || '';
            const isCompat = card.dataset.compat === '1';
            let typeMatch = (type === 'ALL' || cardType.includes(type));
            let compatMatch = !onlyCompat || isCompat;
            card.style.display = (typeMatch && compatMatch) ? '' : 'none';
        });
    }

    function toggleOnlyCompat(checkbox) {
        const activePill = document.querySelector('#stepView-2 .cb-filter-pill.active');
        const filterType = activePill ? activePill.textContent.trim() : 'ALL';
        filterSwitch(filterType === 'Tất cả' ? 'ALL' : filterType, null);
    }

    function filterGrid(gridId, filterType, pill) {
        if (pill) {
            pill.parentElement.querySelectorAll('.cb-filter-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
        }
        const cards = document.querySelectorAll('#' + gridId + ' .cb-product-card');
        cards.forEach(card => {
            if (card.classList.contains('none-card')) {
                card.style.display = '';
                return;
            }
            const cardType = card.dataset.type || '';
            card.style.display = (filterType === 'ALL' || cardType.includes(filterType)) ? '' : 'none';
        });
    }

    function dismissWarning() {
        const w = document.getElementById('switchWarningBanner');
        if (w) w.style.display = 'none';
    }

    let remainingSeconds = 14 * 60 + 22;
    setInterval(() => {
        if (remainingSeconds > 0) {
            remainingSeconds--;
            const mins = Math.floor(remainingSeconds / 60);
            const secs = remainingSeconds % 60;
            const timerEl = document.getElementById('lockTimer');
            if (timerEl) {
                timerEl.textContent = (mins < 10 ? '0' : '') + mins + ':' + (secs < 10 ? '0' : '') + secs;
            }
        }
    }, 1000);

    function saveDraft() {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = 'custom-builder';
        form.innerHTML = `
            <input type="hidden" name="action" value="save-draft">
            <input type="hidden" name="kitId" value="${buildState.kit.id}">
            <input type="hidden" name="switchId" value="${buildState.sw.id}">
            <input type="hidden" name="keycapId" value="${buildState.keycap.id}">
            <input type="hidden" name="stabId" value="${buildState.stab.id}">
            <input type="hidden" name="serviceId" value="${buildState.svc.id}">
            <input type="hidden" name="step" value="${currentStep}">
        `;
        document.body.appendChild(form);
        form.submit();
    }

    function shareBuild() {
        const url = window.location.origin + window.location.pathname +
            `?selKit=${buildState.kit.id}&selSwitch=${buildState.sw.id}&selKeycap=${buildState.keycap.id}&selStab=${buildState.stab.id}&selService=${buildState.svc.id}`;
        navigator.clipboard.writeText(url).then(() => {
            alert('Đã sao chép liên kết chia sẻ cấu hình vào clipboard:\n' + url);
        }).catch(() => {
            prompt('Liên kết chia sẻ cấu hình của bạn:', url);
        });
    }

    function openBuildSheetModal() {
        document.getElementById('buildSheetModal').classList.add('show');
    }

    function closeBuildSheetModal(e) {
        if (!e || e.target.id === 'buildSheetModal' || e.target.classList.contains('cb-modal-close') || e.target.closest('.cb-btn-primary')) {
            document.getElementById('buildSheetModal').classList.remove('show');
        }
    }

    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    window.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.cb-pay-option').forEach(opt => {
            opt.addEventListener('click', () => {
                document.querySelectorAll('.cb-pay-option').forEach(o => o.classList.remove('active'));
                opt.classList.add('active');
            });
        });

        const activeSvc = document.querySelector('.cb-service-card.selected');
        if (activeSvc) {
            const sid = parseInt(activeSvc.dataset.id) || 0;
            const sname = activeSvc.dataset.name || '';
            const sprice = parseInt(activeSvc.dataset.price) || 0;
            const sws = activeSvc.dataset.ws || 'SwitchHouse';
            const swsAvatar = activeSvc.dataset.wsavatar || 'SH';
            const sdur = activeSvc.dataset.duration || '5-7 ngày';
            buildState.svc = { id: sid, name: sname, shortName: sname, price: sprice, shopName: sws, wsAvatar: swsAvatar, duration: sdur };
        }

        updateSidebarDisplay();
        updateKeyboardGraphic();
        syncFormInputs();
        goToStep(currentStep);
    });

    function formatVND(n) {
        return (n || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.') + '₫';
    }
</script>

</body>
</html>