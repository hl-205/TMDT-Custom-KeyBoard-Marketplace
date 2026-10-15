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
    <meta name="description" content="Tự tay cấu hình bộ bàn phím cơ custom: chọn kit, switch, keycap và gói gia công. Kiểm tra tương thích linh kiện tức thì.">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/custom-builder.css">
</head>
<body class="cb-page">

<!-- ══════════════════════════════════════════════════════════════
     TOP NAVBAR: Logo, Stepper, Actions (Matching Figma Header)
     ══════════════════════════════════════════════════════════════ -->
<header class="cb-navbar">
    <div class="cb-nav-left">
        <a href="index.jsp" class="cb-logo-wrap">
            <span class="cb-logo-badge">K</span>
            <span class="cb-logo-text">KeebHub</span>
        </a>
        <span class="cb-nav-divider">|</span>
        <span class="cb-nav-module">Custom Builder</span>
    </div>

    <!-- Stepper 5 bước đúng chuẩn Figma -->
    <div class="cb-nav-stepper" id="cbStepper">
        <div class="cb-step-pill <%= selKit > 0 ? "done" : "" %> <%= currentStep == 1 ? "active" : "" %>" onclick="goToStep(1)">
            <span class="cb-step-badge"><%= selKit > 0 ? "✓" : "1" %></span>
            <span class="cb-step-label">Kit</span>
        </div>
        <div class="cb-step-pill <%= selSwitch > 0 ? "done" : "" %> <%= currentStep == 2 ? "active" : "" %>" onclick="goToStep(2)">
            <span class="cb-step-badge"><%= selSwitch > 0 && currentStep > 2 ? "✓" : "2" %></span>
            <span class="cb-step-label">Switch</span>
        </div>
        <div class="cb-step-pill <%= selKeycap > 0 ? "done" : "" %> <%= currentStep == 3 ? "active" : "" %>" onclick="goToStep(3)">
            <span class="cb-step-badge"><%= selKeycap > 0 && currentStep > 3 ? "✓" : "3" %></span>
            <span class="cb-step-label">Keycap</span>
        </div>
        <div class="cb-step-pill <%= (selStab > 0 || selService > 0) ? "done" : "" %> <%= currentStep == 4 ? "active" : "" %>" onclick="goToStep(4)">
            <span class="cb-step-badge"><%= (selStab > 0 || selService > 0) && currentStep > 4 ? "✓" : "4" %></span>
            <span class="cb-step-label">Gia công</span>
        </div>
        <div class="cb-step-pill <%= currentStep == 5 ? "active" : "" %>" onclick="goToStep(5)">
            <span class="cb-step-badge">5</span>
            <span class="cb-step-label">Xem lại</span>
        </div>
    </div>

    <div class="cb-nav-right">
        <button type="button" class="cb-btn-secondary" onclick="saveDraft()">Lưu nháp</button>
        <a href="index.jsp" class="cb-btn-secondary">Thoát</a>
    </div>
</header>

<!-- Flash alerts -->
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

<!-- ══════════════════════════════════════════════════════════════
     MAIN LAYOUT: Left Wizard Steps + Right Sticky Sidebar
     ══════════════════════════════════════════════════════════════ -->
<div class="cb-container cb-shell">

    <!-- ── LEFT MAIN: STEP CONTENT ── -->
    <main class="cb-main-wizard">

        <!-- ████████████ BƯỚC 1: CHỌN KIT BÀN PHÍM ████████████ -->
        <section class="cb-step-view <%= currentStep == 1 ? "active" : "" %>" id="stepView-1">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 1 · Chọn kit bàn phím</h2>
                    <p class="cb-step-sub">Khung xương bàn phím cơ — quyết định layout (60%/65%/75%), cấu trúc mount và khả năng hotswap 5-pin</p>
                </div>
            </div>

            <!-- Filter tabs -->
            <div class="cb-filter-row">
                <span class="cb-filter-pill active" onclick="filterGrid('kitGrid', 'ALL', this)">Tất cả</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', '60%', this)">60% (Gọn gàng)</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', '75%', this)">75% (Có núm/F-row)</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', 'Gasket mount', this)">Gasket mount</span>
                <span class="cb-filter-pill" onclick="filterGrid('kitGrid', 'Nhôm', this)">Vỏ nhôm CNC</span>
            </div>

            <!-- Kit Cards Grid -->
            <div class="cb-cards-grid" id="kitGrid">
                <% if (kits != null) { for (BuilderProduct p : kits) { %>
                <div class="cb-product-card <%= p.getId() == selKit ? "selected" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-type="<%= p.getLayout() != null ? p.getLayout() : "" %> <%= p.getMountType() != null ? p.getMountType() : "" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-specs="<%= p.getOptionSpecs() != null && !p.getOptionSpecs().isEmpty() ? p.getOptionSpecs() : (p.getBrand() + " · " + (p.getLayout()!=null?p.getLayout():"") + " · " + (p.getMountType()!=null?p.getMountType():"")) %>">
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
                        <button type="button" class="cb-btn-select <%= p.getId() == selKit ? "is-selected" : "" %>" onclick="selectPart('kit', this)">
                            <%= p.getId() == selKit ? "✓ Đã chọn" : "Chọn kit này" %>
                        </button>
                    </div>
                </div>
                <% } } %>
            </div>

            <!-- Bottom Navigation -->
            <div class="cb-step-footer">
                <div class="cb-step-footer-left"></div>
                <div class="cb-step-footer-center">Đã chọn kit bàn phím</div>
                <div class="cb-step-footer-right">
                    <button type="button" class="cb-btn-primary" onclick="goToStep(2)">Tiếp tục chọn switch &gt;</button>
                </div>
            </div>
        </section>


        <!-- ████████████ BƯỚC 2: CHỌN SWITCH (Exact Figma Screen 06) ████████████ -->
        <section class="cb-step-view <%= currentStep == 2 ? "active" : "" %>" id="stepView-2">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 2 · Chọn switch</h2>
                    <p class="cb-step-sub" id="switchKitSubtitle">
                        Đang lọc theo kit đã chọn: <strong>Tofu60 2.0 Aluminium</strong> · hotswap 5-pin · south-facing LED
                    </p>
                </div>
                <label class="cb-toggle-compat">
                    <input type="checkbox" id="onlyCompatToggle" checked onchange="toggleOnlyCompat(this)">
                    <span>Chỉ hiện linh kiện tương thích</span>
                </label>
            </div>

            <!-- Quick Filter Row -->
            <div class="cb-filter-row">
                <span class="cb-filter-label">Lọc nhanh:</span>
                <span class="cb-filter-pill active" onclick="filterSwitch('ALL', this)">Tất cả</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Linear', this)">Linear</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Tactile', this)">Tactile</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Clicky', this)">Clicky</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Lube', this)">Đã lube sẵn</span>
                <span class="cb-filter-pill" onclick="filterSwitch('Under1M', this)">Dưới 1 triệu</span>
                <span class="cb-filter-count-note">Cần 70 switch cho layout 60%</span>
            </div>

            <!-- ⚠️ Amber Compatibility Alert Box (Exact Figma 06) -->
            <div class="cb-warning-banner" id="switchWarningBanner">
                <div class="cb-warning-icon">⚠️</div>
                <div class="cb-warning-content">
                    <div class="cb-warning-title">1 linh kiện trong danh sách không lắp vừa kit của bạn</div>
                    <div class="cb-warning-desc">
                        <strong>Kailh Box Jade</strong> dùng chân 3 pin đời cũ, không tương thích socket hotswap của Tofu60 2.0. Hệ thống đã khoá lựa chọn này để tránh hỏng PCB.
                    </div>
                    <div class="cb-warning-actions">
                        <button type="button" class="cb-btn-warn-action" onclick="filterSwitch('Clicky', null)">Xem switch clicky thay thế</button>
                        <button type="button" class="cb-btn-warn-dismiss" onclick="dismissWarning()">Ẩn cảnh báo</button>
                    </div>
                </div>
            </div>

            <!-- Switch Cards Grid (3 Columns) -->
            <div class="cb-cards-grid grid-3col" id="switchGrid">
                <% if (switches != null) { for (BuilderProduct p : switches) {
                   boolean isCompat = p.isCompatible();
                   String colorClass = p.getSwitchColor() != null ? p.getSwitchColor() : "black";
                %>
                <div class="cb-product-card <%= p.getId() == selSwitch ? "selected" : "" %> <%= !isCompat ? "incompatible-card" : "" %>"
                     data-id="<%= p.getId() %>"
                     data-compat="<%= isCompat ? "1" : "0" %>"
                     data-type="<%= p.getSwitchType() != null ? p.getSwitchType() : "Linear" %> <%= p.getName().contains("lube") ? "Lube" : "" %> <%= p.getPrice() < 1000000 ? "Under1M" : "" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-color="<%= colorClass %>"
                     data-specs="<%= p.getOptionSpecs() != null && !p.getOptionSpecs().isEmpty() ? p.getOptionSpecs() : (p.getSwitchType() + " · " + p.getPinType()) %>">

                    <!-- Badge Row -->
                    <div class="cb-card-badge-row">
                        <% if (isCompat) { %>
                        <span class="cb-badge-compat">Tương thích</span>
                        <% } else { %>
                        <span class="cb-badge-incompat">Không lắp vừa</span>
                        <% } %>
                        <span class="cb-badge-stock"><%= p.getShopName() %> · <%= p.getStockText() %></span>
                    </div>

                    <!-- Switch Illustration -->
                    <div class="cb-card-thumb">
                        <div class="cb-illus-switch <%= colorClass %>">
                            <div class="cb-sw-top">
                                <div class="cb-sw-stem"></div>
                            </div>
                            <div class="cb-sw-bottom"></div>
                        </div>
                    </div>

                    <!-- Card Info -->
                    <div class="cb-card-info">
                        <h3 class="cb-card-title"><%= p.getName() %></h3>
                        <div class="cb-card-specs"><%= p.getOptionSpecs() %></div>
                        <div class="cb-card-price-row">
                            <span class="cb-card-price"><%= p.getFormattedPrice() %></span>
                        </div>
                    </div>

                    <!-- Button & Incompat Note -->
                    <div class="cb-card-action">
                        <% if (isCompat) { %>
                        <button type="button" class="cb-btn-select <%= p.getId() == selSwitch ? "is-selected" : "" %>"
                                onclick="selectPart('sw', this)">
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

            <!-- Bottom Navigation -->
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


        <!-- ████████████ BƯỚC 3: CHỌN KEYCAP ████████████ -->
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
                <!-- Option card: Tự mua riêng -->
                <div class="cb-product-card none-card <%= selKeycap == 0 ? "selected" : "" %>"
                     data-id="0" data-compat="1" data-name="Không chọn (Tự mua riêng)" data-shortname="Tự mua riêng" data-price="0"
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
                     data-compat="<%= isCompat ? "1" : "0" %>"
                     data-type="<%= p.getName() %> <%= p.getLayout() != null ? p.getLayout() : "" %>"
                     data-name="<%= p.getName().replace("\"","&quot;") %>"
                     data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                     data-price="<%= p.getPrice() %>"
                     data-specs="<%= p.getOptionSpecs() != null ? p.getOptionSpecs() : p.getBrand() %>">

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
                        <button type="button" class="cb-btn-select <%= p.getId() == selKeycap ? "is-selected" : "" %>" onclick="selectPart('keycap', this)">
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

            <!-- Bottom Navigation -->
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


        <!-- ████████████ BƯỚC 4: CHỌN STABILIZER & GÓI GIA CÔNG ████████████ -->
        <section class="cb-step-view <%= currentStep == 4 ? "active" : "" %>" id="stepView-4">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 4 · Stabilizer & Gói gia công</h2>
                    <p class="cb-step-sub">Cân chỉnh thanh cân bằng và lựa chọn xưởng gia công chuyên nghiệp</p>
                </div>
            </div>

            <!-- Section 4A: Stabilizer -->
            <div class="cb-sub-section">
                <div class="cb-sub-header">
                    <h3>1. Chọn Stabilizer (cho các phím dài Space, Shift, Enter)</h3>
                    <span class="cb-sub-tag">PCB screw-in tương thích kit</span>
                </div>

                <div class="cb-cards-grid grid-3col" id="stabGrid">
                    <!-- Tự mua stab riêng -->
                    <div class="cb-product-card none-card <%= selStab == 0 ? "selected" : "" %>"
                         data-id="0" data-compat="1" data-name="Không chọn (Tự mua stab)" data-shortname="Tự mua riêng" data-price="0"
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
                         data-compat="<%= isCompat ? "1" : "0" %>"
                         data-name="<%= p.getName().replace("\"","&quot;") %>"
                         data-shortname="<%= p.getShortName().replace("\"","&quot;") %>"
                         data-price="<%= p.getPrice() %>"
                         data-specs="<%= p.getOptionSpecs() %>">
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
                            <button type="button" class="cb-btn-select <%= p.getId() == selStab ? "is-selected" : "" %>" onclick="selectPart('stab', this)">
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
                    <span class="cb-sub-tag">Bảo hành 6-12 tháng tại xưởng</span>
                </div>

                <!-- Workshop Tabs -->
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

                <!-- Workshop Packages Grid -->
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
                             data-ws="<%= ws.getShopName() %>"
                             data-duration="<%= svc.getDurationText() %>"
                             onclick="selectServiceCard(<%= svc.getId() %>, '<%= svc.getServiceName().replace("'","\\'") %>', <%= svc.getPrice() %>, '<%= ws.getShopName() %>', '<%= svc.getDurationText() %>', this)">

                            <% if (svc.isPopular()) { %>
                            <div class="cb-popular-tag">Phổ biến nhất</div>
                            <% } %>

                            <h4 class="cb-svc-title"><%= svc.getServiceName() %></h4>
                            <div class="cb-svc-price"><%= svc.getFormattedPrice() %></div>
                            <div class="cb-svc-duration">⏱ Dự kiến <%= svc.getDurationText() %></div>

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

            <!-- Bottom Navigation -->
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


        <!-- ████████████ BƯỚC 5: XEM LẠI & ĐẶT HÀNG (Exact Figma BUILD SHEET) ████████████ -->
        <section class="cb-step-view <%= currentStep == 5 ? "active" : "" %>" id="stepView-5">
            <div class="cb-step-header">
                <div class="cb-step-title-wrap">
                    <h2>Bước 5 · Xem lại cấu hình &amp; Đặt hàng</h2>
                    <p class="cb-step-sub">Đối chiếu thông số kỹ thuật Build Sheet, xác nhận tương thích và tạo đơn gia công</p>
                </div>
            </div>

            <!-- BUILD SHEET CARD (Exact Figma 07-gio-hang) -->
            <div class="cb-build-sheet-card">
                <div class="cb-bs-head">
                    <div class="cb-bs-shop">
                        <span class="cb-bs-shop-badge">SH</span>
                        <strong id="bsShopName">SwitchHouse</strong>
                        <span class="cb-badge-custom-order">Đơn custom - có gia công</span>
                    </div>
                    <div class="cb-bs-price" id="bsTotalPrice">5.320.000đ</div>
                </div>

                <div class="cb-bs-body">
                    <div class="cb-bs-title-row">
                        <h3 class="cb-bs-title">Bàn phím custom theo cấu hình của bạn — Build #B-7742</h3>
                        <p class="cb-bs-pkg-info" id="bsPkgDuration">Gói gia công: Full lube + tune · dự kiến 5-7 ngày</p>
                    </div>

                    <div class="cb-bs-spec-box">
                        <div class="cb-bs-box-title">📋 BUILD SHEET CHI TIẾT</div>
                        <div class="cb-bs-table">
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Kit</span>
                                <span class="cb-bs-td" id="bsKitVal">Tofu60 2.0 · Silver · Brass plate</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Switch</span>
                                <span class="cb-bs-td" id="bsSwVal">Gateron Oil King ×70 · Linear 55g</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Keycap</span>
                                <span class="cb-bs-td" id="bsKeycapVal">GMK Olivia++ Cherry · base 137</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Stabilizer</span>
                                <span class="cb-bs-td" id="bsStabVal">Durock V2 screw-in · đã lube</span>
                            </div>
                            <div class="cb-bs-row">
                                <span class="cb-bs-th">Gia công</span>
                                <span class="cb-bs-td" id="bsSvcVal">Rã hàn · lube · cân stab · lắp ráp · test</span>
                            </div>
                        </div>
                        <div class="cb-bs-links">
                            <a href="javascript:void(0)" onclick="goToStep(1)">✏️ Sửa cấu hình</a>
                            <a href="javascript:void(0)" onclick="openBuildSheetModal()">📄 Xem Build Sheet đầy đủ</a>
                        </div>
                    </div>

                    <!-- Workshop notice (Exact Figma) -->
                    <div class="cb-bs-workshop-notice">
                        <span class="cb-bs-notice-icon">⚠️</span>
                        <div>Đơn gia công chỉ nhận <strong>1 sản phẩm/lần đặt</strong> do giới hạn công suất xưởng, và <strong>không áp dụng COD</strong>. Shop sẽ xác nhận đơn trong 24 giờ trước khi bắt đầu gia công.</div>
                    </div>
                </div>
            </div>

            <!-- COMPATIBILITY VERIFICATION PANEL -->
            <div class="cb-compat-check-panel">
                <div class="cb-compat-panel-head">
                    <span class="cb-compat-panel-title">🛡️ Xác nhận kiểm tra tương thích hệ thống (UC27)</span>
                    <span class="cb-badge-compat">✓ 100% Tương thích hoàn hảo</span>
                </div>
                <div class="cb-compat-checklist">
                    <div class="cb-c-item">
                        <span class="cb-c-icon ok">✓</span>
                        <div class="cb-c-text">
                            <strong>Kit ↔ Switch: Socket Hotswap 5-pin</strong>
                            <span>PCB nhận cả switch 3-pin và 5-pin, chân switch chuẩn MX khít chắc socket không cong vênh.</span>
                        </div>
                    </div>
                    <div class="cb-c-item">
                        <span class="cb-c-icon ok">✓</span>
                        <div class="cb-c-text">
                            <strong>Kit ↔ Keycap: Layout 60% ANSI</strong>
                            <span>Bộ keycap bao phủ toàn bộ 61 nút tiêu chuẩn, đầy đủ phím Space 6.25u và hàng dưới 1.25u.</span>
                        </div>
                    </div>
                    <div class="cb-c-item">
                        <span class="cb-c-icon ok">✓</span>
                        <div class="cb-c-text">
                            <strong>Kit ↔ Stabilizer: PCB Screw-in</strong>
                            <span>Cấu trúc Gasket mount và PCB khoét lỗ screw-in cố định stab chắc chắn, không bị lọc xọc.</span>
                        </div>
                    </div>
                    <div class="cb-c-item">
                        <span class="cb-c-icon ok">✓</span>
                        <div class="cb-c-text">
                            <strong>Đèn LED ↔ Keycap: South-facing</strong>
                            <span>Bóng LED hướng nam hoàn toàn không cấn cạnh với profile Cherry của keycap GMK.</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- CHECKOUT FORM -->
            <div class="cb-checkout-card">
                <div class="cb-checkout-head">
                    <h3>📦 Thông tin nhận hàng &amp; Thanh toán</h3>
                    <p>Xưởng sẽ liên hệ xác nhận thông số âm thanh &amp; bàn giao video test</p>
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
                        <input type="text" name="shippingAddress" required
                               placeholder="Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành">
                    </div>

                    <div class="cb-form-group">
                        <label>Ghi chú cho kỹ thuật viên xưởng mod</label>
                        <textarea name="customNote" rows="2"
                                  placeholder="VD: Cân stab phím Space thật êm, ưu tiên âm trầm thocky, tape mod 2 lớp..."></textarea>
                    </div>

                    <div class="cb-form-group">
                        <label>Phương thức thanh toán an toàn qua Sàn</label>
                        <div class="cb-pay-options">
                            <label class="cb-pay-option active">
                                <input type="radio" name="paymentMethod" value="VNPAY" checked>
                                <span>🏦 VNPAY-QR (Giảm 20k)</span>
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
                            🛒 Đặt đơn Custom ngay — <span id="btnSubmitTotal">4.200.000đ</span>
                        </button>
                    </div>
                </form>
            </div>

            <!-- Bottom Navigation -->
            <div class="cb-step-footer">
                <div class="cb-step-footer-left">
                    <button type="button" class="cb-btn-secondary" onclick="goToStep(4)">&lt; Quay lại chỉnh gia công</button>
                </div>
            </div>
        </section>

    </main>


    <!-- ── RIGHT SIDEBAR: PERSISTENT SUMMARY & PREVIEW (Exact Figma) ── -->
    <aside class="cb-sidebar-col">

        <!-- 1. LIVE VISUAL KEYBOARD PREVIEW -->
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

        <!-- 2. CẤU HÌNH CỦA BẠN (Matching Figma 06) -->
        <div class="cb-side-card">
            <div class="cb-side-card-head">
                <h4>Cấu hình của bạn</h4>
            </div>

            <!-- Items List with 'Sửa' links -->
            <div class="cb-side-items-list">
                <!-- Kit -->
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

                <!-- Switch -->
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

                <!-- Keycap -->
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

                <!-- Stabilizer -->
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

                <!-- Custom Service -->
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

            <!-- Price Breakdown (Figma) -->
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

            <!-- Realtime Compatibility Notice (Figma) -->
            <div class="cb-side-compat-badge-box">
                <div class="cb-side-compat-status" id="sideCompatStatus">
                    ✓ Tất cả linh kiện đã chọn đều tương thích (UC27)
                </div>
                <div class="cb-side-duration-hint" id="sideDurationHint">
                    🕒 Thời gian gia công dự kiến sẽ hiện ở bước 4
                </div>
            </div>

            <!-- Inventory Lock Timer Banner (Figma UC28) -->
            <div class="cb-inventory-lock-banner">
                <div class="cb-lock-top">
                    <span class="cb-lock-icon">🔒</span>
                    <span>Đã giữ chỗ tồn kho cho cấu hình này · còn <strong id="lockTimer">14:22</strong></span>
                </div>
                <div class="cb-lock-sub">Hết giờ, linh kiện sẽ mở lại cho người khác (UC28)</div>
            </div>

            <!-- CTA Actions (Figma) -->
            <div class="cb-side-cta-buttons">
                <button type="button" class="cb-btn-side-orange" id="sidePrimaryCta" onclick="handlePrimaryCta()">
                    Thêm vào giỏ &amp; đặt hàng
                </button>
                <button type="button" class="cb-btn-side-outline" onclick="saveDraft()">
                    💾 Lưu cấu hình này
                </button>
            </div>

            <!-- Footer links -->
            <div class="cb-side-footer-links">
                <a href="javascript:void(0)" onclick="shareBuild()">Chia sẻ build</a>
                <span>·</span>
                <a href="javascript:void(0)" onclick="openBuildSheetModal()">Xuất Build Sheet</a>
            </div>
        </div>

    </aside>

</div>

<!-- ══════════════════════════════════════════════════════════════
     MODAL: XUẤT BUILD SHEET ĐẦY ĐỦ (Printable modal)
     ══════════════════════════════════════════════════════════════ -->
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
                    <p>Mã đơn đề xuất: <strong>#B-7742</strong> · Ngày tạo: 15/10/2026</p>
                </div>
                <span class="cb-badge-custom-order">Custom Build</span>
            </div>
            <table class="modal-bs-table">
                <tbody>
                    <tr><th>Kit bàn phím</th><td id="mKitVal">Tofu60 2.0 Aluminium (60%, Gasket mount)</td><td id="mKitPrice">2.690.000₫</td></tr>
                    <tr><th>Switch</th><td id="mSwVal">Gateron Oil King Linear 55g (70 nút)</td><td id="mSwPrice">890.000₫</td></tr>
                    <tr><th>Keycap</th><td id="mKeycapVal">GMK Olivia++ Cherry profile (137 phím)</td><td id="mKeycapPrice">4.150.000₫</td></tr>
                    <tr><th>Stabilizer</th><td id="mStabVal">Durock V2 PCB-mount screw-in</td><td id="mStabPrice">420.000₫</td></tr>
                    <tr><th>Dịch vụ mod</th><td id="mSvcVal">Full lube + tune stab</td><td id="mSvcPrice">750.000₫</td></tr>
                    <tr class="modal-bs-total-row"><th>TỔNG CỘNG</th><td>Đã áp dụng ưu đãi combo build (-150k)</td><td id="mTotalPrice">8.750.000₫</td></tr>
                </tbody>
            </table>
            <div class="modal-bs-compat-note">
                🛡️ Chứng nhận độ tương thích: <strong>100% Linh kiện tương thích hoàn toàn (UC27)</strong>. Socket hotswap, profile keycap và cấu trúc stab đã được hệ thống KeebHub đối chiếu với DB kỹ thuật.
            </div>
        </div>
        <div class="cb-modal-footer">
            <button type="button" class="cb-btn-secondary" onclick="window.print()">🖨️ In Build Sheet</button>
            <button type="button" class="cb-btn-primary" onclick="closeBuildSheetModal()">Đóng</button>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />

<!-- ══════════════════════════════════════════════════════════════
     JAVASCRIPT: State Management, Stepper Wizard, Live Calculations
     ══════════════════════════════════════════════════════════════ -->
<script>
    // ── Global Build State ─────────────────────────────────────────
    let currentStep = <%= currentStep %>;

    const buildState = {
        kit: {
            id: <%= selKit %>,
            name: 'Kit Tofu60 2.0 Aluminium — Hotswap, gasket mount',
            shortName: 'Tofu60 2.0 Aluminium',
            price: 2690000,
            specs: 'Silver · Brass plate'
        },
        sw: {
            id: <%= selSwitch %>,
            name: 'Gateron Oil King — Linear 55g, lube nhà máy',
            shortName: 'Gateron Oil King ×70',
            price: 890000,
            specs: 'Linear 55g · lube nhà máy',
            color: 'black'
        },
        keycap: {
            id: <%= selKeycap %>,
            name: '<%= selKeycap > 0 ? "GMK Olivia++ Cherry profile" : "" %>',
            shortName: '<%= selKeycap > 0 ? "GMK Olivia++ Cherry" : "" %>',
            price: <%= selKeycap > 0 ? 4150000 : 0 %>,
            specs: '<%= selKeycap > 0 ? "Cherry profile · 137 phím" : "" %>'
        },
        stab: {
            id: <%= selStab %>,
            name: 'Stabilizer Durock V2 PCB-mount — đã lube sẵn',
            shortName: 'Durock V2 screw-in',
            price: 420000,
            specs: 'PCB-mount · đã lube'
        },
        svc: {
            id: <%= selService %>,
            name: '',
            shortName: '',
            price: 0,
            shopName: 'SwitchHouse',
            duration: '5-7 ngày'
        }
    };

    // ── Stepper Navigation ─────────────────────────────────────────
    function goToStep(step) {
        currentStep = step;

        // Cập nhật view các bước
        document.querySelectorAll('.cb-step-view').forEach(v => v.classList.remove('active'));
        const targetView = document.getElementById('stepView-' + step);
        if (targetView) targetView.classList.add('active');

        // Cập nhật pills stepper trên navbar
        document.querySelectorAll('#cbStepper .cb-step-pill').forEach((pill, idx) => {
            const stepNum = idx + 1;
            pill.classList.remove('active');
            if (stepNum === step) pill.classList.add('active');
        });

        // Cập nhật text nút CTA sidebar
        const primaryCta = document.getElementById('sidePrimaryCta');
        if (primaryCta) {
            if (step < 5) {
                primaryCta.textContent = 'Tiếp tục bước tiếp theo >';
            } else {
                primaryCta.textContent = 'Thêm vào giỏ & đặt hàng';
            }
        }

        // Scroll mượt lên đầu
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function handlePrimaryCta() {
        if (currentStep < 5) {
            goToStep(currentStep + 1);
        } else {
            // Submit form đặt đơn ở bước 5
            const form = document.getElementById('finalOrderForm');
            if (form) form.submit();
        }
    }

    // ── Chọn linh kiện ─────────────────────────────────────────────
    function selectPart(type, card) {
        const grid = card.closest('.cb-cards-grid');
        if (!grid) return;

        // Bỏ chọn các card khác trong grid
        grid.querySelectorAll('.cb-product-card').forEach(c => {
            c.classList.remove('selected');
            const btn = c.querySelector('.cb-btn-select');
            if (btn) {
                btn.classList.remove('is-selected');
                btn.textContent = (c.classList.contains('none-card')) ? 'Bỏ qua' : 'Chọn';
            }
        });

        // Chọn card này
        card.classList.add('selected');
        const selBtn = card.querySelector('.cb-btn-select');
        if (selBtn) {
            selBtn.classList.add('is-selected');
            selBtn.textContent = '✓ Đã chọn';
        }

        // Cập nhật state
        const id = parseInt(card.dataset.id) || 0;
        const name = card.dataset.name || '';
        const shortName = card.dataset.shortname || name;
        const price = parseInt(card.dataset.price) || 0;
        const specs = card.dataset.specs || '';
        const color = card.dataset.color || 'black';

        buildState[type] = { id, name, shortName, price, specs, color };

        // Cập nhật UI Preview & Sidebar
        updateSidebarDisplay();
        updateKeyboardGraphic();
        syncFormInputs();
    }

    // ── Chọn gói dịch vụ ───────────────────────────────────────────
    function selectServiceCard(id, name, price, wsName, duration, card) {
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

        buildState.svc = { id, name, shortName: name, price, shopName: wsName, duration };
        updateSidebarDisplay();
        syncFormInputs();
    }

    function selectNoWorkshop(tab) {
        document.querySelectorAll('#workshopTabs .cb-ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.cb-services-container').forEach(c => c.classList.remove('active'));
        selectServiceCard(0, 'Tự lắp ráp (Không gia công)', 0, 'Tự lắp', '0 ngày', null);
    }

    function switchWorkshop(wsId, tab) {
        document.querySelectorAll('#workshopTabs .cb-ws-tab').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        document.querySelectorAll('.cb-services-container').forEach(c => c.classList.remove('active'));
        const target = document.getElementById('ws-services-' + wsId);
        if (target) target.classList.add('active');
    }

    // ── Cập nhật Sidebar & Tính tiền ──────────────────────────────
    function updateSidebarDisplay() {
        // Kit
        const kitEl = document.getElementById('sideKitName');
        const kitSub = document.getElementById('sideKitSub');
        const kitPr = document.getElementById('sideKitPrice');
        if (buildState.kit.id > 0) {
            kitEl.textContent = buildState.kit.shortName;
            kitEl.className = '';
            kitSub.textContent = buildState.kit.specs;
            kitPr.textContent = formatVND(buildState.kit.price);
        }

        // Switch
        const swEl = document.getElementById('sideSwName');
        const swSub = document.getElementById('sideSwSub');
        const swPr = document.getElementById('sideSwPrice');
        if (buildState.sw.id > 0) {
            swEl.textContent = buildState.sw.shortName;
            swEl.className = '';
            swSub.textContent = buildState.sw.specs;
            swPr.textContent = formatVND(buildState.sw.price);
        }

        // Keycap
        const kcEl = document.getElementById('sideKeycapName');
        const kcSub = document.getElementById('sideKeycapSub');
        const kcPr = document.getElementById('sideKeycapPrice');
        if (buildState.keycap.id > 0) {
            kcEl.textContent = buildState.keycap.shortName;
            kcEl.className = '';
            kcSub.textContent = buildState.keycap.specs;
            kcPr.textContent = formatVND(buildState.keycap.price);
        } else {
            kcEl.textContent = 'Chưa chọn keycap';
            kcEl.className = 'empty';
            kcSub.textContent = 'Bước 3';
            kcPr.textContent = '—';
        }

        // Stabilizer
        const stabEl = document.getElementById('sideStabName');
        const stabSub = document.getElementById('sideStabSub');
        const stabPr = document.getElementById('sideStabPrice');
        if (buildState.stab.id > 0) {
            stabEl.textContent = buildState.stab.shortName;
            stabEl.className = '';
            stabSub.textContent = buildState.stab.specs;
            stabPr.textContent = formatVND(buildState.stab.price);
        }

        // Service
        const svcEl = document.getElementById('sideSvcName');
        const svcSub = document.getElementById('sideSvcSub');
        const svcPr = document.getElementById('sideSvcPrice');
        if (buildState.svc.id > 0) {
            svcEl.textContent = buildState.svc.name;
            svcEl.className = '';
            svcSub.textContent = buildState.svc.shopName + ' · ' + buildState.svc.duration;
            svcPr.textContent = formatVND(buildState.svc.price);
        } else {
            svcEl.textContent = 'Chưa chọn gói gia công';
            svcEl.className = 'empty';
            svcSub.textContent = 'Bước 4';
            svcPr.textContent = '—';
        }

        // Tính tiền tổng
        const partsTotal = buildState.kit.price + buildState.sw.price + buildState.keycap.price + buildState.stab.price;
        const svcTotal = buildState.svc.price;
        const discount = (partsTotal > 0 && buildState.sw.id > 0) ? 150000 : 0;
        const grandTotal = Math.max(0, partsTotal + svcTotal - discount);

        document.getElementById('sidePartsSubtotal').textContent = formatVND(partsTotal);
        document.getElementById('sideSvcSubtotal').textContent = svcTotal > 0 ? formatVND(svcTotal) : 'Chưa chọn';
        document.getElementById('sideDiscount').textContent = discount > 0 ? '-150.000₫' : '0₫';
        document.getElementById('sideGrandTotal').textContent = formatVND(grandTotal);

        // Đồng bộ lên Build Sheet ở bước 5
        const bsPrice = document.getElementById('bsTotalPrice');
        if (bsPrice) bsPrice.textContent = formatVND(grandTotal);
        const btnTotal = document.getElementById('btnSubmitTotal');
        if (btnTotal) btnTotal.textContent = formatVND(grandTotal);

        const bsKit = document.getElementById('bsKitVal');
        if (bsKit) bsKit.textContent = buildState.kit.shortName + ' · ' + buildState.kit.specs;
        const bsSw = document.getElementById('bsSwVal');
        if (bsSw) bsSw.textContent = buildState.sw.shortName + ' · ' + buildState.sw.specs;
        const bsKc = document.getElementById('bsKeycapVal');
        if (bsKc) bsKc.textContent = buildState.keycap.id > 0 ? buildState.keycap.shortName : 'Tự mua riêng';
        const bsSt = document.getElementById('bsStabVal');
        if (bsSt) bsSt.textContent = buildState.stab.shortName + ' · ' + buildState.stab.specs;
        const bsSvc = document.getElementById('bsSvcVal');
        if (bsSvc) bsSvc.textContent = buildState.svc.id > 0 ? buildState.svc.name : 'Tự lắp ráp (Không gia công)';

        // Cập nhật Modal
        const mKit = document.getElementById('mKitVal');
        if (mKit) {
            mKit.textContent = buildState.kit.name;
            document.getElementById('mKitPrice').textContent = formatVND(buildState.kit.price);
            document.getElementById('mSwVal').textContent = buildState.sw.name;
            document.getElementById('mSwPrice').textContent = formatVND(buildState.sw.price);
            document.getElementById('mKeycapVal').textContent = buildState.keycap.id > 0 ? buildState.keycap.name : 'Tự mua riêng';
            document.getElementById('mKeycapPrice').textContent = formatVND(buildState.keycap.price);
            document.getElementById('mStabVal').textContent = buildState.stab.name;
            document.getElementById('mStabPrice').textContent = formatVND(buildState.stab.price);
            document.getElementById('mSvcVal').textContent = buildState.svc.id > 0 ? buildState.svc.name : 'Tự lắp';
            document.getElementById('mSvcPrice').textContent = formatVND(buildState.svc.price);
            document.getElementById('mTotalPrice').textContent = formatVND(grandTotal);
        }
    }

    // ── Đồng bộ Hidden Form Inputs ─────────────────────────────────
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

    // ── Cập nhật Graphic Keyboard ──────────────────────────────────
    function updateKeyboardGraphic() {
        const keebCase = document.getElementById('keebCaseGraphic');
        if (!keebCase) return;

        // Đổi màu case phím theo Kit
        if (buildState.kit.name.toLowerCase().contains('black')) {
            keebCase.style.borderColor = '#1E293B';
            keebCase.style.background = '#0F172A';
        } else {
            keebCase.style.borderColor = '#CBD5E1';
            keebCase.style.background = '#F8FAFC';
        }

        // Đổi màu keycap theo loại keycap đã chọn
        const keys = keebCase.querySelectorAll('.cb-k');
        if (buildState.keycap.id > 0) {
            if (buildState.keycap.name.contains('Olivia')) {
                keys.forEach(k => {
                    if (k.classList.contains('accent')) {
                        k.style.background = '#FBCFE8'; // Hồng Olivia
                        k.style.borderColor = '#F472B6';
                    } else {
                        k.style.background = '#1E293B'; // Dark alphas
                        k.style.borderColor = '#334155';
                    }
                });
            } else if (buildState.keycap.name.contains('Pink')) {
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

    // ── Filter Switch & Tương thích ────────────────────────────────
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

            if (typeMatch && compatMatch) {
                card.style.display = '';
            } else {
                card.style.display = 'none';
            }
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
            if (filterType === 'ALL' || cardType.includes(filterType)) {
                card.style.display = '';
            } else {
                card.style.display = 'none';
            }
        });
    }

    function dismissWarning() {
        const w = document.getElementById('switchWarningBanner');
        if (w) w.style.display = 'none';
    }

    // ── Lock Countdown Timer (14:22) ───────────────────────────────
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

    // ── Lưu nháp & Chia sẻ ─────────────────────────────────────────
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

    // ── Modal Build Sheet ──────────────────────────────────────────
    function openBuildSheetModal() {
        document.getElementById('buildSheetModal').classList.add('show');
    }

    function closeBuildSheetModal(e) {
        if (!e || e.target.id === 'buildSheetModal' || e.target.classList.contains('cb-modal-close') || e.target.closest('.cb-btn-primary')) {
            document.getElementById('buildSheetModal').classList.remove('show');
        }
    }

    // ── Khởi tạo trang ─────────────────────────────────────────────
    window.addEventListener('DOMContentLoaded', () => {
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
