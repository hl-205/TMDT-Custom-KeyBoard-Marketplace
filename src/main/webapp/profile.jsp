<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login");
        return;
    }
    User pUser = (User) request.getAttribute("profileUser");
    if (pUser == null) {
        pUser = currentUser;
    }

    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
    String pwdSuccessMsg = (String) request.getAttribute("pwdSuccessMsg");
    String pwdErrorMsg = (String) request.getAttribute("pwdErrorMsg");
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "info";

    String dobStr = "";
    if (pUser.getDob() != null) {
        dobStr = new SimpleDateFormat("yyyy-MM-dd").format(pUser.getDob());
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân - KeebHub</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/customer-pages.css">
    <style>
        .profile-card-box {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 28px 32px;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
            margin-bottom: 24px;
        }
        .profile-tabs {
            display: flex;
            gap: 12px;
            border-bottom: 2px solid #F1F5F9;
            margin-bottom: 24px;
        }
        .profile-tab-btn {
            background: none;
            border: none;
            font-size: 15px;
            font-weight: 700;
            color: #64748B;
            padding: 10px 18px;
            cursor: pointer;
            position: relative;
            bottom: -2px;
            border-bottom: 3px solid transparent;
            transition: all 0.2s ease;
        }
        .profile-tab-btn.active {
            color: #1B64F2;
            border-bottom-color: #1B64F2;
        }
        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        .form-row {
            margin-bottom: 18px;
        }
        .form-row label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            margin-bottom: 7px;
        }
        .form-row input, .form-row select, .form-row textarea {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid #CBD5E1;
            border-radius: 9px;
            font-size: 14px;
            color: #0F172A;
            background: #fff;
            box-sizing: border-box;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-row input:focus, .form-row select:focus, .form-row textarea:focus {
            outline: none;
            border-color: #1B64F2;
            box-shadow: 0 0 0 3px rgba(27, 100, 242, 0.12);
        }
        .form-row input[readonly] {
            background: #F8FAFC;
            color: #64748B;
            cursor: not-allowed;
            border-color: #E2E8F0;
        }
        .gender-options {
            display: flex;
            gap: 20px;
            align-items: center;
            padding: 8px 0;
        }
        .gender-label {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
        }
        .gender-label input[type="radio"] {
            width: auto;
            margin: 0;
        }
        .alert-box {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .alert-success {
            background: #ECFDF5;
            border: 1px solid #A7F3D0;
            color: #065F46;
        }
        .alert-danger {
            background: #FEF2F2;
            border: 1px solid #FECACA;
            color: #991B1B;
        }
        .user-stat-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            background: #EFF6FF;
            color: #1B64F2;
        }
    </style>
</head>
<body>

<jsp:include page="includes/header.jsp" />

<main class="container">
    <div class="pd-breadcrumb" style="padding: 16px 0;">
        <a href="index.jsp">Trang chủ</a> › <a href="profile">Tài khoản</a> › <strong>Hồ sơ cá nhân</strong>
    </div>

    <div class="account-layout-2col">
        <!-- SIDEBAR -->
        <aside class="account-sidebar-card">
            <div class="acc-user-box">
                <div class="acc-avatar-circle"><%= pUser.getAvatarText() %></div>
                <div>
                    <strong style="display:block;font-size:14px;"><%= pUser.getFullName() %></strong>
                    <span style="font-size:12px;color:#64748B;"><%= pUser.getRankName() %> · <%= pUser.getPoints() %> điểm</span>
                </div>
            </div>

            <div class="acc-nav-group-title">Tài khoản</div>
            <a href="profile" class="acc-nav-link active"><span>👤 Thông tin tài khoản</span></a>
            <a href="my-orders" class="acc-nav-link"><span>📦 Đơn hàng của tôi</span></a>
            <a href="my-reviews" class="acc-nav-link"><span>⭐ Đánh giá của tôi</span></a>
            <a href="cart" class="acc-nav-link"><span>🛒 Giỏ hàng</span></a>

            <div class="acc-nav-group-title">Hỗ trợ</div>
            <a href="logout" class="acc-nav-link" style="color:#EF4444;font-weight:700;"><span>↪ Đăng xuất</span></a>
        </aside>

        <!-- NỘI DUNG CHÍNH -->
        <section>
            <div class="profile-card-box">
                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
                    <div>
                        <h2 style="font-size:22px;font-weight:800;color:#0F172A;margin:0 0 4px 0;">Hồ Sơ Của Tôi</h2>
                        <p style="font-size:13px;color:#64748B;margin:0;">Quản lý thông tin hồ sơ và địa chỉ nhận hàng để thanh toán nhanh hơn</p>
                    </div>
                    <div class="user-stat-badge">
                        ✨ <%= pUser.getRankName() %> · <%= pUser.getPoints() %> KeebPoints
                    </div>
                </div>

                <div class="profile-tabs">
                    <button type="button" class="profile-tab-btn <%= "info".equals(activeTab) ? "active" : "" %>" onclick="switchTab('info')">
                        📋 Thông tin cá nhân & Địa chỉ
                    </button>
                    <button type="button" class="profile-tab-btn <%= "password".equals(activeTab) ? "active" : "" %>" onclick="switchTab('password')">
                        🔒 Đổi mật khẩu
                    </button>
                </div>

                <!-- TAB 1: THÔNG TIN CÁ NHÂN -->
                <div id="tab-info" style="display: <%= "info".equals(activeTab) ? "block" : "none" %>;">
                    <% if (successMsg != null) { %>
                    <div class="alert-box alert-success">
                        <span>✓</span> <div><%= successMsg %></div>
                    </div>
                    <% } %>
                    <% if (errorMsg != null) { %>
                    <div class="alert-box alert-danger">
                        <span>⚠</span> <div><%= errorMsg %></div>
                    </div>
                    <% } %>

                    <form method="POST" action="profile">
                        <input type="hidden" name="action" value="update_profile">

                        <div class="form-grid-2">
                            <div class="form-row">
                                <label for="firstName">Họ và tên đệm <span style="color:#EF4444;">*</span></label>
                                <input type="text" id="firstName" name="firstName" value="<%= pUser.getFirstName() != null ? pUser.getFirstName() : "" %>" required maxlength="50" placeholder="Ví dụ: Nguyễn Văn">
                            </div>
                            <div class="form-row">
                                <label for="lastName">Tên <span style="color:#EF4444;">*</span></label>
                                <input type="text" id="lastName" name="lastName" value="<%= pUser.getLastName() != null ? pUser.getLastName() : "" %>" required maxlength="50" placeholder="Ví dụ: Anh">
                            </div>
                        </div>

                        <div class="form-grid-2">
                            <div class="form-row">
                                <label>Địa chỉ Email (Định danh)</label>
                                <input type="text" value="<%= pUser.getEmail() %>" readonly title="Email không thể thay đổi">
                                <span style="font-size:12px;color:#10B981;margin-top:4px;display:inline-block;">✓ Đã xác thực bảo mật</span>
                            </div>
                            <div class="form-row">
                                <label for="phone">Số điện thoại liên hệ <span style="color:#EF4444;">*</span></label>
                                <input type="tel" id="phone" name="phone" value="<%= pUser.getPhone() != null ? pUser.getPhone() : "" %>" required maxlength="20" placeholder="Ví dụ: 0987654321">
                            </div>
                        </div>

                        <div class="form-grid-2">
                            <div class="form-row">
                                <label>Giới tính</label>
                                <div class="gender-options">
                                    <label class="gender-label">
                                        <input type="radio" name="gender" value="Nam" <%= "Nam".equalsIgnoreCase(pUser.getGender()) ? "checked" : "" %>> Nam
                                    </label>
                                    <label class="gender-label">
                                        <input type="radio" name="gender" value="Nữ" <%= "Nữ".equalsIgnoreCase(pUser.getGender()) ? "checked" : "" %>> Nữ
                                    </label>
                                    <label class="gender-label">
                                        <input type="radio" name="gender" value="Khác" <%= ("Khác".equalsIgnoreCase(pUser.getGender()) || pUser.getGender() == null) ? "checked" : "" %>> Khác
                                    </label>
                                </div>
                            </div>
                            <div class="form-row">
                                <label for="dob">Ngày sinh</label>
                                <input type="date" id="dob" name="dob" value="<%= dobStr %>">
                            </div>
                        </div>

                        <div class="form-row">
                            <label for="address">Địa chỉ nhận hàng mặc định</label>
                            <textarea id="address" name="address" rows="3" placeholder="Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố để tự động điền khi đặt hàng..."><%= pUser.getAddress() != null ? pUser.getAddress() : "" %></textarea>
                            <span style="font-size:12px;color:#64748B;margin-top:4px;display:block;">Địa chỉ này sẽ được dùng làm địa chỉ giao hàng ưu tiên khi bạn thanh toán tại KeebHub.</span>
                        </div>

                        <div style="margin-top:24px;border-top:1px solid #F1F5F9;padding-top:18px;display:flex;justify-content:flex-end;">
                            <button type="submit" class="btn btn-blue" style="padding:12px 28px;font-weight:700;font-size:15px;cursor:pointer;">
                                Lưu thay đổi thông tin
                            </button>
                        </div>
                    </form>
                </div>

                <!-- TAB 2: ĐỔI MẬT KHẨU -->
                <div id="tab-password" style="display: <%= "password".equals(activeTab) ? "block" : "none" %>;">
                    <% if (pwdSuccessMsg != null) { %>
                    <div class="alert-box alert-success">
                        <span>✓</span> <div><%= pwdSuccessMsg %></div>
                    </div>
                    <% } %>
                    <% if (pwdErrorMsg != null) { %>
                    <div class="alert-box alert-danger">
                        <span>⚠</span> <div><%= pwdErrorMsg %></div>
                    </div>
                    <% } %>

                    <form method="POST" action="profile" style="max-width:560px;">
                        <input type="hidden" name="action" value="change_password">

                        <div class="form-row">
                            <label for="currentPassword">Mật khẩu hiện tại <span style="color:#EF4444;">*</span></label>
                            <input type="password" id="currentPassword" name="currentPassword" required placeholder="Nhập mật khẩu hiện tại của bạn">
                        </div>

                        <div class="form-row">
                            <label for="newPassword">Mật khẩu mới <span style="color:#EF4444;">*</span></label>
                            <input type="password" id="newPassword" name="newPassword" required minlength="6" placeholder="Mật khẩu mới ít nhất 6 ký tự">
                        </div>

                        <div class="form-row">
                            <label for="confirmPassword">Xác nhận mật khẩu mới <span style="color:#EF4444;">*</span></label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6" placeholder="Nhập lại mật khẩu mới">
                        </div>

                        <div style="margin-top:24px;border-top:1px solid #F1F5F9;padding-top:18px;">
                            <button type="submit" class="btn btn-blue" style="padding:12px 28px;font-weight:700;font-size:15px;cursor:pointer;">
                                Cập nhật mật khẩu
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </section>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />

<script>
function switchTab(tabName) {
    var infoTab = document.getElementById('tab-info');
    var pwdTab = document.getElementById('tab-password');
    var tabBtns = document.querySelectorAll('.profile-tab-btn');

    if (tabName === 'info') {
        infoTab.style.display = 'block';
        pwdTab.style.display = 'none';
        tabBtns[0].classList.add('active');
        tabBtns[1].classList.remove('active');
    } else {
        infoTab.style.display = 'none';
        pwdTab.style.display = 'block';
        tabBtns[0].classList.remove('active');
        tabBtns[1].classList.add('active');
    }
}
</script>

</body>
</html>
