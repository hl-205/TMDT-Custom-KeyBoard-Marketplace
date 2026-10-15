<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
  User headerUser = (User) session.getAttribute("user");
  java.util.Map<?, ?> headerCart = (java.util.Map<?, ?>) session.getAttribute("cart");
  int headerCartCount = (headerCart == null) ? 0 : headerCart.size();
  boolean isSellerRole = (headerUser != null && "SELLER".equalsIgnoreCase(headerUser.getRole()));
%>
<div class="topbar">
  <div class="container topbar-content">
    <div class="topbar-left">
      <a href="seller-orders"><strong>Kênh người bán</strong></a> <span class="dot">·</span>
      <a href="#">Tải ứng dụng</a> <span class="dot">·</span>
      <a href="#">Kết nối cộng đồng</a>
    </div>
    <div class="topbar-right">
      <a href="#">Thông báo</a>
      <a href="#">Trợ giúp</a>
      <% if (headerUser == null) { %>
      <a href="register"><strong>Đăng ký</strong></a>
      <a href="login"><strong>Đăng nhập</strong></a>
      <% } else { %>
      <% if (isSellerRole) { %>
      <a href="seller-services" style="color:#60A5FA;"><strong>🏪 Quản lý Xưởng</strong></a>
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
      <input type="text" name="keyword" class="search-input" placeholder="Tìm kit bàn phím, switch, keycap, xưởng gia công...">
      <button type="submit" class="search-btn">Tìm kiếm</button>
    </form>

    <div class="header-actions">
      <% if (isSellerRole) { %>
      <a href="seller-orders" class="btn-header-register" style="background:#EA580C;font-size:12px;padding:7px 12px;">
        🛠️ Kênh Seller
      </a>
      <% } %>

      <a href="<%= headerUser != null ? "my-orders" : "login" %>" class="action-icon" title="Yêu thích">♡</a>
      <a href="<%= headerUser != null ? "my-orders" : "login" %>" class="action-icon badge-wrap" title="Thông báo">
        🔔<span class="badge">0</span>
      </a>
      <a href="cart" class="action-icon badge-wrap" title="Giỏ hàng">
        🛒<span class="badge badge-orange"><%= headerCartCount %></span>
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
          <% if (isSellerRole) { %>
          <a href="seller-orders" class="dropdown-item" style="color:#1B64F2;font-weight:700;">🏪 Quản lý đơn hàng Xưởng</a>
          <a href="seller-services" class="dropdown-item" style="color:#1B64F2;font-weight:700;">🔧 Quản lý dịch vụ Custom</a>
          <div class="dropdown-divider"></div>
          <% } %>
          <a href="my-orders" class="dropdown-item">📦 Đơn hàng của tôi</a>
          <a href="my-reviews" class="dropdown-item">⭐ Đánh giá của tôi</a>
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
      <li><a href="category">Build sẵn</a></li>
      <li><a href="shops">🏪 Gian hàng</a></li>
    </ul>
    <a href="category" class="nav-group-buy">
      🔥 Group buy đang mở
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