<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Shop" %>
<%
  Shop sidebarShop = (Shop) request.getAttribute("sellerShop");
  String sShopName = (sidebarShop != null) ? sidebarShop.getShopName() : "SwitchHouse";
  String sShopAvatar = (sidebarShop != null) ? sidebarShop.getAvatarText() : "SH";
  int sShopId = (sidebarShop != null) ? sidebarShop.getId() : 2;
  String activeMenu = request.getParameter("activeMenu");
  if (activeMenu == null) activeMenu = "";
%>
<aside class="seller-sidebar">
  <a href="index.jsp" class="seller-brand-head">
    <div class="seller-brand-icon">K</div>
    <div>
      <strong>KeebHub Seller</strong>
      <span>Kênh người bán</span>
    </div>
  </a>

  <div class="seller-shop-badge-box">
    <div class="sh-square"><%= sShopAvatar %></div>
    <div>
      <strong><%= sShopName %></strong>
      <span>Đã xác minh · Xưởng gia công</span>
    </div>
  </div>

  <div class="s-nav-section">Đơn hàng</div>
  <a href="seller-orders" class="s-nav-item <%= "orders".equals(activeMenu) ? "active" : "" %>">
    <span>📦 Quản lý đơn hàng</span>
    <span class="s-pill-orange">${totalOrdersCount != null ? totalOrdersCount : 0}</span>
  </a>
  <a href="seller-confirm-custom" class="s-nav-item <%= "confirm".equals(activeMenu) ? "active" : "" %>">
    <span>⚙️ Đơn custom chờ xác nhận</span>
    <span class="s-pill-orange">${pendingCustomCount != null ? pendingCustomCount : 0}</span>
  </a>
  <a href="seller-progress" class="s-nav-item <%= "progress".equals(activeMenu) ? "active" : "" %>">
    <span>🛠️ Tiến độ gia công</span>
    <span class="s-pill-orange">${processingCustomCount != null ? processingCustomCount : 0}</span>
  </a>

  <div class="s-nav-section">Sản phẩm & Dịch vụ</div>
  <a href="shop?id=<%= sShopId %>" class="s-nav-item">
    <span>📋 Danh sách sản phẩm</span>
  </a>
  <a href="seller-services" class="s-nav-item <%= "services".equals(activeMenu) ? "active" : "" %>">
    <span>🔧 Dịch vụ gia công</span>
  </a>

  <div class="s-nav-section">Điều hướng</div>
  <a href="index.jsp" class="s-nav-item">
    <span>🏠 Về sàn KeebHub</span>
  </a>
</aside>