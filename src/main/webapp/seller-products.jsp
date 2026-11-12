<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Shop" %>
<%@ page import="dao.CustomOrderDAO.SellerProductItem" %>
<%@ page import="java.util.List" %>
<%
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null) {
    response.sendRedirect("login");
    return;
  }
  if (request.getAttribute("products") == null) {
    response.sendRedirect("seller-products");
    return;
  }
  Shop sellerShop = (Shop) request.getAttribute("sellerShop");
  String shopName = (sellerShop != null) ? sellerShop.getShopName() : "SwitchHouse";
  List<SellerProductItem> products = (List<SellerProductItem>) request.getAttribute("products");
  String selectedStatus = (String) request.getAttribute("selectedStatus");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quản lý & Đăng sản phẩm - <%= shopName %></title>
  <link rel="stylesheet" href="assets/css/seller.css">
</head>
<body>

<div class="seller-app-shell">
  <jsp:include page="includes/seller-sidebar.jsp">
    <jsp:param name="activeMenu" value="products" />
  </jsp:include>

  <main class="seller-main-area">
    <div class="seller-topbar">
      <div class="seller-page-title">
        <h1>Quản lý & Đăng sản phẩm — <%= shopName %></h1>
        <p>Sản phẩm mới đăng hoặc cập nhật sẽ được chuyển tới <strong>Admin kiểm duyệt</strong> trước khi hiển thị lên sàn</p>
      </div>
      <div class="seller-top-right">
        <div class="seller-user-pill">
          <div class="sh-square" style="width:26px;height:26px;border-radius:50%;font-size:11px;"><%= currentUser.getAvatarText() %></div>
          <span><%= currentUser.getFullName() %> · Chủ shop (<%= shopName %>)</span>
        </div>
        <button type="button" class="btn-seller-primary" onclick="openNewProductModal()">+ Đăng sản phẩm / Bàn phím mới</button>
      </div>
    </div>

    <% String msg = request.getParameter("msg");
      if ("submitted_for_moderation".equals(msg)) { %>
    <div style="background:#EFF6FF;border:1px solid #BFDBFE;color:#1D4ED8;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
      🕒 Đã lưu và gửi sản phẩm sang hàng đợi <strong>Kiểm duyệt của Admin (Trạng thái: PENDING)</strong>! Sau khi Admin duyệt, sản phẩm sẽ tự động hiển thị trên sàn.
    </div>
    <% } else if (msg != null) { %>
    <div style="background:#DCFCE7;border:1px solid #BBF7D0;color:#15803D;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px;font-weight:600;">
      ✓ Đã cập nhật trạng thái sản phẩm thành công!
    </div>
    <% } %>

    <div class="seller-kpi-grid4">
      <div class="s-kpi-card">
        <div class="s-kpi-head">✅ Đang mở bán (ACTIVE)</div>
        <strong>${activeProductsCount}</strong>
        <span class="s-kpi-sub up">Đã được Admin duyệt</span>
      </div>
      <div class="s-kpi-card">
        <div class="s-kpi-head">🕒 Chờ Admin duyệt (PENDING)</div>
        <strong>${pendingModCount}</strong>
        <span class="s-kpi-sub" style="color:#D97706;">Đang trong hàng đợi kiểm duyệt</span>
      </div>
      <div class="s-kpi-card">
        <div class="s-kpi-head">⚠️ Cần sửa / Từ chối</div>
        <strong>${needsEditCount}</strong>
        <span class="s-kpi-sub down">Cần bổ sung thông số & gửi lại</span>
      </div>
      <div class="s-kpi-card">
        <div class="s-kpi-head">📦 Tổng sản phẩm của Shop</div>
        <strong>${allProductsCount}</strong>
        <span class="s-kpi-sub" style="color:#64748B;">Đang tạm ẩn: ${inactiveProductsCount}</span>
      </div>
    </div>

    <div class="sla-warning-banner" style="background:#F8FAFC;border-color:#CBD5E1;color:#334155;">
      🛡️ <strong>4 Tiêu chí Kiểm duyệt tự động của sàn KeebHub:</strong> (1) Đủ mã SKU, Thương hiệu và Giá bán &gt; 0 · (2) Mô tả chi tiết tối thiểu <strong>100 ký tự</strong> · (3) Có từ <strong>3 dòng Thông số kỹ thuật</strong> trở lên · (4) Có ít nhất <strong>1 dòng Dữ liệu tương thích</strong>.
    </div>

    <section class="white-panel-card">
      <div style="display:flex;gap:18px;border-bottom:1px solid #E2E8F0;padding-bottom:12px;margin-bottom:16px;">
        <a href="seller-products?status=ALL" style="font-weight:700;color:<%= "ALL".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Tất cả (${allProductsCount})</a>
        <a href="seller-products?status=ACTIVE" style="font-weight:700;color:<%= "ACTIVE".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Đang bán (${activeProductsCount})</a>
        <a href="seller-products?status=PENDING" style="font-weight:700;color:<%= "PENDING".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Chờ Admin duyệt (${pendingModCount})</a>
        <a href="seller-products?status=NEEDS_EDIT" style="font-weight:700;color:<%= "NEEDS_EDIT".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Cần chỉnh sửa</a>
        <a href="seller-products?status=REJECTED" style="font-weight:700;color:<%= "REJECTED".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Bị từ chối</a>
        <a href="seller-products?status=INACTIVE" style="font-weight:700;color:<%= "INACTIVE".equals(selectedStatus) ? "#1B64F2" : "#64748B" %>;">Tạm ẩn (${inactiveProductsCount})</a>
      </div>

      <% if (products.isEmpty()) { %>
      <div style="text-align:center;padding:42px;color:#64748B;">
        Chưa có sản phẩm nào ở trạng thái này. Hãy bấm <strong>"+ Đăng sản phẩm / Bàn phím mới"</strong> để đăng lên sàn.
      </div>
      <% } else { %>
      <table class="orders-table">
        <thead>
        <tr>
          <th>Mã SP / SKU</th>
          <th>Tên sản phẩm & Danh mục</th>
          <th>Giá bán</th>
          <th>Kho</th>
          <th>Tiêu chí kiểm duyệt</th>
          <th>Trạng thái</th>
          <th>Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <% for (SellerProductItem p : products) { %>
        <tr>
          <td>
            <strong>#<%= p.getId() %></strong><br>
            <span style="font-size:11px;color:#64748B;"><%= p.getSku() %></span>
          </td>
          <td>
            <strong><%= p.getName() %></strong><br>
            <span style="font-size:11px;color:#64748B;">
                                    <%= p.getCategoryName() %> · Thương hiệu: <strong><%= p.getBrand() %></strong>
                                    <% if (!p.getLayout().isEmpty()) { %> · Layout: <%= p.getLayout() %><% } %>
                                </span>
          </td>
          <td><strong><%= p.getFormattedPrice() %></strong></td>
          <td><strong><%= p.getStock() %></strong></td>
          <td style="font-size:11px;">
                                <span style="color:<%= p.getDescription().length() >= 100 ? "#16A34A" : "#DC2626" %>;">
                                    <%= p.getDescription().length() >= 100 ? "✓" : "✕" %> Mô tả (<%= p.getDescription().length() %> ký tự)
                                </span><br>
            <span style="color:<%= p.getSpecCount() >= 3 ? "#16A34A" : "#DC2626" %>;">
                                    <%= p.getSpecCount() >= 3 ? "✓" : "✕" %> Thông số (<%= p.getSpecCount() %> dòng)
                                </span> ·
            <span style="color:<%= p.getCompatCount() >= 1 ? "#16A34A" : "#DC2626" %>;">
                                    <%= p.getCompatCount() >= 1 ? "✓" : "✕" %> Tương thích (<%= p.getCompatCount() %>)
                                </span>
          </td>
          <td>
            <% if ("ACTIVE".equals(p.getStatus())) { %>
            <span class="st-badge completed">✓ Đang bán</span>
            <% } else if ("PENDING".equals(p.getStatus())) { %>
            <span class="st-badge processing">🕒 Chờ Admin duyệt</span>
            <% } else if ("NEEDS_EDIT".equals(p.getStatus())) { %>
            <span class="st-badge pending">⚠️ Admin yêu cầu sửa</span>
            <% } else if ("REJECTED".equals(p.getStatus())) { %>
            <span class="st-badge cancelled">✕ Bị từ chối</span>
            <% } else { %>
            <span class="st-badge cancelled">Tạm ẩn</span>
            <% } %>
          </td>
          <td>
            <div style="display:flex;gap:6px;flex-wrap:wrap;">
              <button type="button" class="btn-seller-outline" style="height:30px;font-size:12px;"
                      data-id="<%= p.getId() %>"
                      data-cat="<%= p.getCategoryId() %>"
                      data-sku="<%= p.getSku().replace("\"", "&quot;") %>"
                      data-name="<%= p.getName().replace("\"", "&quot;") %>"
                      data-brand="<%= p.getBrand().replace("\"", "&quot;") %>"
                      data-price="<%= p.getPrice() %>"
                      data-oldprice="<%= p.getOldPrice() %>"
                      data-stock="<%= p.getStock() %>"
                      data-custom="<%= p.isSupportCustom() ? "1" : "0" %>"
                      data-layout="<%= p.getLayout().replace("\"", "&quot;") %>"
                      data-mount="<%= p.getMountType().replace("\"", "&quot;") %>"
                      data-pin="<%= p.getPinType().replace("\"", "&quot;") %>"
                      data-swtype="<%= p.getSwitchType().replace("\"", "&quot;") %>"
                      data-force="<%= p.getActuationForce().replace("\"", "&quot;") %>"
                      data-short="<%= p.getShortDesc().replace("\"", "&quot;") %>"
                      data-desc="<%= p.getDescription().replace("\"", "&quot;") %>"
                      data-specs="<%= p.getSpecsText().replace("\"", "&quot;") %>"
                      data-compat="<%= p.getCompatText().replace("\"", "&quot;") %>"
                      onclick="openEditProductModal(this)">
                <%= ("NEEDS_EDIT".equals(p.getStatus()) || "REJECTED".equals(p.getStatus())) ? "Sửa & Gửi duyệt lại" : "Chỉnh sửa" %>
              </button>

              <% if ("ACTIVE".equals(p.getStatus()) || "INACTIVE".equals(p.getStatus())) { %>
              <a href="seller-products?action=toggle&id=<%= p.getId() %>" class="btn-seller-outline" style="height:30px;font-size:12px;">
                <%= "ACTIVE".equals(p.getStatus()) ? "Tạm ẩn" : "Mở bán lại" %>
              </a>
              <% } %>

              <a href="seller-products?action=delete&id=<%= p.getId() %>"
                 class="btn-seller-outline" style="height:30px;font-size:12px;color:#DC2626;border-color:#FECACA;"
                 onclick="return confirm('Xóa / ngừng bán sản phẩm này?')">Xoá</a>
            </div>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
      <% } %>
    </section>
  </main>
</div>

<!-- Modal Đăng sản phẩm mới / Chỉnh sửa gửi Admin duyệt -->
<div class="modal-backdrop" id="productModal">
  <div class="modal-card" style="width:680px;max-height:92vh;overflow-y:auto;">
    <h3 id="pModalTitle" style="font-size:18px;font-weight:800;margin-bottom:4px;">Đăng sản phẩm mới lên sàn</h3>
    <p style="font-size:12px;color:#64748B;margin-bottom:14px;">Sau khi lưu, sản phẩm sẽ chuyển sang trạng thái <strong>PENDING (Chờ Admin kiểm duyệt)</strong>.</p>

    <form action="seller-products" method="POST">
      <input type="hidden" name="productId" id="pIdInput" value="0">

      <div style="display:grid;grid-template-columns:2fr 1fr;gap:12px;margin-bottom:12px;">
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Tên sản phẩm / Bàn phím *</label>
          <input type="text" name="name" id="pNameInput" required
                 placeholder="VD: Kit Neo65 Nhôm CNC — Tri-mode Hotswap"
                 style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;">
        </div>
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Danh mục *</label>
          <select name="categoryId" id="pCatInput" style="width:100%;height:38px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;">
            <option value="1">1 · Kit bàn phím</option>
            <option value="2">2 · Switch</option>
            <option value="3">3 · Keycap</option>
            <option value="4">4 · Stabilizer</option>
            <option value="5">5 · Phụ kiện</option>
          </select>
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:10px;margin-bottom:12px;">
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Mã SKU *</label>
          <input type="text" name="sku" id="pSkuInput" required placeholder="KH-NEO65-V2"
                 style="width:100%;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;">
        </div>
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Thương hiệu *</label>
          <input type="text" name="brand" id="pBrandInput" required placeholder="Qwertykeys"
                 style="width:100%;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;">
        </div>
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Giá bán (VNĐ) *</label>
          <input type="number" name="price" id="pPriceInput" min="10000" step="10000" required
                 style="width:100%;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;">
        </div>
        <div>
          <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Tồn kho *</label>
          <input type="number" name="stock" id="pStockInput" min="1" required
                 style="width:100%;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;">
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:10px;margin-bottom:12px;">
        <div>
          <label style="font-size:11px;font-weight:700;display:block;margin-bottom:4px;">Layout (cho Kit/Keycap)</label>
          <input type="text" name="layout" id="pLayoutInput" placeholder="60%, 65%, 75%, TKL"
                 style="width:100%;height:34px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;font-size:12px;">
        </div>
        <div>
          <label style="font-size:11px;font-weight:700;display:block;margin-bottom:4px;">Kiểu Mount (Kit/Stab)</label>
          <input type="text" name="mountType" id="pMountInput" placeholder="Gasket mount / PCB-mount"
                 style="width:100%;height:34px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;font-size:12px;">
        </div>
        <div>
          <label style="font-size:11px;font-weight:700;display:block;margin-bottom:4px;">Chân Pin (Kit/Switch)</label>
          <input type="text" name="pinType" id="pPinInput" placeholder="5-pin"
                 style="width:100%;height:34px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;font-size:12px;">
        </div>
        <div>
          <label style="font-size:11px;font-weight:700;display:block;margin-bottom:4px;">Loại Switch & Lực</label>
          <input type="text" name="switchType" id="pSwTypeInput" placeholder="Linear / Tactile"
                 style="width:100%;height:34px;border:1px solid #CBD5E1;border-radius:8px;padding:0 10px;font-size:12px;">
          <input type="hidden" name="actuationForce" id="pForceInput" value="45-55g">
          <input type="hidden" name="oldPrice" id="pOldPriceInput" value="0">
        </div>
      </div>

      <div style="margin-bottom:10px;">
        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">Mô tả ngắn</label>
        <input type="text" name="shortDesc" id="pShortDescInput"
               placeholder="Tóm tắt điểm nổi bật của sản phẩm..."
               style="width:100%;height:36px;border:1px solid #CBD5E1;border-radius:8px;padding:0 12px;font-size:13px;">
      </div>

      <div style="margin-bottom:10px;">
        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">
          Mô tả chi tiết * <span style="font-weight:400;color:#1B64F2;">(Tối thiểu 100 ký tự để đạt tiêu chí kiểm duyệt tự động của Admin)</span>
        </label>
        <textarea name="description" id="pDescInput" rows="3" required
                  style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:8px 12px;font-size:13px;"></textarea>
      </div>

      <div style="margin-bottom:10px;">
        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">
          Thông số kỹ thuật * <span style="font-weight:400;color:#64748B;">(Từ 3 dòng trở lên, ngăn cách bằng dấu chấm phẩy `;` theo mẫu `Tên: Giá trị`)</span>
        </label>
        <textarea name="specsText" id="pSpecsInput" rows="2" required
                  style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:8px 12px;font-size:12px;"></textarea>
      </div>

      <div style="margin-bottom:12px;">
        <label style="font-size:12px;font-weight:700;display:block;margin-bottom:4px;">
          Quy tắc tương thích * <span style="font-weight:400;color:#64748B;">(Ít nhất 1 dòng theo mẫu `Tiêu đề: Mô tả tương thích`)</span>
        </label>
        <textarea name="compatText" id="pCompatInput" rows="2" required
                  style="width:100%;border:1px solid #CBD5E1;border-radius:8px;padding:8px 12px;font-size:12px;"></textarea>
      </div>

      <label style="display:flex;align-items:center;gap:8px;margin-bottom:16px;font-size:13px;cursor:pointer;">
        <input type="checkbox" name="supportCustom" id="pCustomCheck" checked style="width:16px;height:16px;accent-color:#1B64F2;">
        <span>Cho phép sử dụng sản phẩm này trong <strong>Custom Builder</strong> và nhận gia công</span>
      </label>

      <div style="display:flex;justify-content:flex-end;gap:10px;">
        <button type="button" class="btn-seller-outline" onclick="closeProductModal()">Huỷ</button>
        <button type="submit" class="btn-seller-primary">Lưu & Gửi Admin Kiểm Duyệt</button>
      </div>
    </form>
  </div>
</div>

<script>
  function openNewProductModal() {
    document.getElementById('pModalTitle').textContent = 'Đăng sản phẩm / Bàn phím mới lên sàn';
    document.getElementById('pIdInput').value = '0';
    document.getElementById('pCatInput').value = '1';
    document.getElementById('pSkuInput').value = 'KH-CUSTOM-' + Math.floor(100 + Math.random() * 899);
    document.getElementById('pNameInput').value = '';
    document.getElementById('pBrandInput').value = '<%= shopName %>';
    document.getElementById('pPriceInput').value = '2590000';
    document.getElementById('pStockInput').value = '25';
    document.getElementById('pLayoutInput').value = '75%';
    document.getElementById('pMountInput').value = 'Gasket mount';
    document.getElementById('pPinInput').value = '5-pin';
    document.getElementById('pSwTypeInput').value = '';
    document.getElementById('pShortDescInput').value = 'Khung nhôm CNC 6063 nguyên khối, mạch hotswap 5-pin hỗ trợ QMK/VIA, kèm sẵn đầy đủ foam tiêu âm.';
    document.getElementById('pDescInput').value = 'Sản phẩm được gia công từ nhôm CNC 6063 аноdized mịn màng, cấu trúc Gasket mount cho cảm giác gõ nhún đều, mạch PCB hotswap 5 chân đèn RGB south-facing không cấn keycap Cherry profile, đi kèm tạ đáy đồng thau và bảo hành chính hãng 12 tháng tại KeebHub.';
    document.getElementById('pSpecsInput').value = 'Layout: 75% - 82 phím ANSI; Chất liệu vỏ: Nhôm CNC 6063 Anodized; Kiểu mount: Gasket mount Poron; PCB: Hotswap 5-pin QMK/VIA RGB South-facing; Bảo hành: 12 tháng tại xưởng';
    document.getElementById('pCompatInput').value = 'Switch 3 chân & 5 chân: PCB hotswap 5-pin nhận mọi loại switch cơ chuẩn MX; Keycap Cherry / OEM / ASA: Layout ANSI chuẩn tương thích đầy đủ';
    document.getElementById('pCustomCheck').checked = true;
    document.getElementById('productModal').classList.add('show');
  }

  function openEditProductModal(btn) {
    document.getElementById('pModalTitle').textContent = 'Chỉnh sửa & Gửi duyệt lại sản phẩm #' + btn.dataset.id;
    document.getElementById('pIdInput').value = btn.dataset.id;
    document.getElementById('pCatInput').value = btn.dataset.cat || '1';
    document.getElementById('pSkuInput').value = btn.dataset.sku || '';
    document.getElementById('pNameInput').value = btn.dataset.name || '';
    document.getElementById('pBrandInput').value = btn.dataset.brand || '';
    document.getElementById('pPriceInput').value = btn.dataset.price || '0';
    document.getElementById('pOldPriceInput').value = btn.dataset.oldprice || '0';
    document.getElementById('pStockInput').value = btn.dataset.stock || '10';
    document.getElementById('pLayoutInput').value = btn.dataset.layout || '';
    document.getElementById('pMountInput').value = btn.dataset.mount || '';
    document.getElementById('pPinInput').value = btn.dataset.pin || '';
    document.getElementById('pSwTypeInput').value = btn.dataset.swtype || '';
    document.getElementById('pForceInput').value = btn.dataset.force || '';
    document.getElementById('pShortDescInput').value = btn.dataset.short || '';
    document.getElementById('pDescInput').value = btn.dataset.desc || '';
    document.getElementById('pSpecsInput').value = btn.dataset.specs || 'Layout: Tiêu chuẩn ANSI; Chất liệu: Cao cấp; Bảo hành: 12 tháng';
    document.getElementById('pCompatInput').value = btn.dataset.compat || 'Switch 3 chân & 5 chân: Tương thích chuẩn MX';
    document.getElementById('pCustomCheck').checked = (btn.dataset.custom === '1');
    document.getElementById('productModal').classList.add('show');
  }

  function closeProductModal() {
    document.getElementById('productModal').classList.remove('show');
  }
</script>
</body>
</html>