<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.util.Map" %>
<%
  User headerUser = (User) session.getAttribute("user");
  boolean isSellerRole = (headerUser != null && "SELLER".equalsIgnoreCase(headerUser.getRole()));
  boolean isAdminRole = (headerUser != null && "ADMIN".equalsIgnoreCase(headerUser.getRole()));

  int cartItemCount = 0;
  Object cartObj = session.getAttribute("cart");
  if (cartObj instanceof Map) {
    cartItemCount = ((Map<?, ?>) cartObj).size();
  }
%>
<div class="topbar">
  <div class="container topbar-content">
    <div class="topbar-left">
      <a href="seller-orders"><strong>Kênh người bán</strong></a> <span class="dot">·</span>
      <a href="shops">Hệ thống 30 Xưởng & Gian hàng</a> <span class="dot">·</span>
      <a href="https://www.facebook.com" target="_blank" rel="noopener">Kết nối cộng đồng</a>
    </div>
    <div class="topbar-right">
      <a href="<%= headerUser != null ? "my-orders" : "login" %>">Thông báo</a>
      <a href="custom-builder">Custom Builder</a>
      <% if (headerUser == null) { %>
      <a href="register"><strong>Đăng ký</strong></a>
      <a href="login"><strong>Đăng nhập</strong></a>
      <% } else { %>
      <% if (isAdminRole) { %>
      <a href="admin" style="color:#FBBF24;"><strong>🛡️ Quản trị Admin</strong></a>
      <% } %>
      <% if (isSellerRole) { %>
      <a href="seller-orders" style="color:#60A5FA;"><strong>🏪 Quản lý Xưởng</strong></a>
      <% } %>
      <a href="my-orders"><strong>Tài khoản</strong></a>
      <a href="logout"><strong>Đăng xuất</strong></a>
      <% } %>
    </div>
  </div>
</div>

<header class="header">
  <div class="container header-content">
    <a href="index.jsp" class="logo">
      <div class="logo-icon">K</div>
      <h1>Keeb<span>Hub</span></h1>
    </a>

    <form action="search" method="GET" class="search-wrapper">
      <span class="search-icon-left">🔍</span>
      <input type="text" name="keyword" class="search-input" placeholder="Tìm trong 100+ kit bàn phím, switch, keycap, xưởng gia công...">
      <button type="submit" class="search-btn">Tìm kiếm</button>
    </form>

    <div class="header-actions">
      <% if (isAdminRole) { %>
      <a href="admin" class="btn-header-register" style="background:#DC2626;font-size:12px;padding:7px 12px;">
        🛡️ Admin
      </a>
      <% } else if (isSellerRole) { %>
      <a href="seller-orders" class="btn-header-register" style="background:#EA580C;font-size:12px;padding:7px 12px;">
        🛠️ Kênh Seller
      </a>
      <% } %>

      <a href="<%= headerUser != null ? "my-reviews" : "login" %>" class="action-icon" title="Đánh giá của tôi">⭐</a>
      <a href="<%= headerUser != null ? "my-orders" : "login" %>" class="action-icon badge-wrap" title="Đơn hàng của tôi">
        📦
      </a>
      <a href="cart" class="action-icon badge-wrap" title="Giỏ hàng">
        🛒<span class="badge badge-orange"><%= cartItemCount %></span>
      </a>

      <% if (headerUser == null) { %>
      <div class="auth-header-btns">
        <a href="login" class="btn-header-login">Đăng nhập</a>
        <a href="register" class="btn-header-register">Đăng ký</a>
      </div>
      <% } else { %>
      <div class="user-dropdown-wrap">
        <div class="user-profile" id="userDropdownBtn">
          <div class="avatar"><%= headerUser.getAvatarText() %></div>
          <span class="user-name"><%= headerUser.getShortDisplayName() %> ▾</span>
        </div>
        <div class="user-dropdown-menu" id="userDropdownMenu">
          <div class="dropdown-user-info">
            <strong><%= headerUser.getFullName() %></strong>
            <span><%= headerUser.getEmail() %> (<%= headerUser.getRole() %>)</span>
          </div>
          <% if (isAdminRole) { %>
          <a href="admin" class="dropdown-item" style="color:#DC2626;font-weight:700;">🛡️ Bảng Quản Trị Hệ Thống</a>
          <div class="dropdown-divider"></div>
          <% } %>
          <% if (isSellerRole) { %>
          <a href="seller-orders" class="dropdown-item" style="color:#1B64F2;font-weight:700;">🏪 Quản lý đơn hàng Xưởng</a>
          <a href="seller-confirm-custom" class="dropdown-item" style="color:#1B64F2;font-weight:700;">⚙️ Xác nhận & Báo giá Custom</a>
          <a href="seller-progress" class="dropdown-item" style="color:#1B64F2;font-weight:700;">🛠️ Cập nhật tiến độ gia công</a>
          <a href="seller-services" class="dropdown-item" style="color:#1B64F2;font-weight:700;">🔧 Quản lý dịch vụ Custom</a>
          <div class="dropdown-divider"></div>
          <% } %>
          <a href="my-orders" class="dropdown-item">📦 Đơn hàng của tôi</a>
          <a href="my-reviews" class="dropdown-item">⭐ Đánh giá của tôi</a>
          <a href="cart" class="dropdown-item">🛒 Giỏ hàng (<%= cartItemCount %>)</a>
          <div class="dropdown-divider"></div>
          <a href="logout" class="dropdown-item logout-link">↪ Đăng xuất</a>
        </div>
      </div>
      <% } %>
    </div>
  </div>
</header>

<nav class="main-nav">
  <div class="container nav-content">
    <a href="category" class="nav-all-categories">
      ☰ Tất cả danh mục
    </a>
    <ul class="nav-links">
      <li><a href="category?cat=1">Kit bàn phím</a></li>
      <li><a href="category?cat=2">Switch</a></li>
      <li><a href="category?cat=3">Keycap</a></li>
      <li><a href="category?cat=4">Stabilizer</a></li>
      <li><a href="category?cat=5">Phụ kiện</a></li>
      <li><a href="category?cat=6">Dịch vụ gia công</a></li>
      <li><a href="shops">Hệ thống 30 Gian hàng</a></li>
    </ul>
    <a href="custom-builder" class="nav-group-buy">
      ⚙️ Mở Custom Builder
    </a>
  </div>
</nav>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    var btn = document.getElementById("userDropdownBtn");
    var menu = document.getElementById("userDropdownMenu");
    if (btn && menu) {
      btn.addEventListener("click", function(e) {
        e.stopPropagation();
        menu.classList.toggle("show");
      });
      document.addEventListener("click", function() {
        menu.classList.remove("show");
      });
    }
  });
</script>