<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - KeebHub</title>
    <link rel="stylesheet" href="assets/css/auth.css">
</head>
<body>

<div class="auth-split-layout">
    <!-- Cột trái -->
    <div class="auth-left-panel">
        <a href="index.jsp" class="auth-brand-logo">
            <div class="auth-logo-box">K</div>
            <span>Keeb<em>Hub</em></span>
        </a>

        <div class="auth-left-center">
            <h1>Chào mừng trở lại,<br>thợ build phím</h1>
            <p class="lead-desc">Đăng nhập để tiếp tục cấu hình đang lưu, theo dõi tiến độ gia công và quản lý đơn hàng của bạn.</p>

            <div class="auth-feature-list">
                <div class="auth-feature-item">
                    <div class="feature-icon-box">⚙️</div>
                    <div>
                        <strong>Custom Builder thông minh</strong>
                        <span>Tự kiểm tra tương thích từng linh kiện</span>
                    </div>
                </div>
                <div class="auth-feature-item">
                    <div class="feature-icon-box">🛠️</div>
                    <div>
                        <strong>142 xưởng gia công đã thẩm định</strong>
                        <span>Theo dõi tiến độ kèm ảnh thực tế</span>
                    </div>
                </div>
                <div class="auth-feature-item">
                    <div class="feature-icon-box">🔒</div>
                    <div>
                        <strong>Sàn giữ tiền</strong>
                        <span>Chỉ chuyển cho shop khi bạn nhận hàng</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="auth-keeb-illustration">
            <div class="keeb-illus-row">
                <span class="ki-key"></span><span class="ki-key"></span><span class="ki-key orange"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span>
            </div>
            <div class="keeb-illus-row">
                <span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key orange"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span>
            </div>
            <div class="keeb-illus-row">
                <span class="ki-key"></span><span class="ki-key"></span><span class="ki-key orange"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key"></span><span class="ki-key orange"></span><span class="ki-key"></span><span class="ki-key"></span>
            </div>
            <div class="keeb-illus-row">
                <span class="ki-key"></span><span class="ki-key orange"></span><span class="ki-key space"></span><span class="ki-key"></span><span class="ki-key"></span>
            </div>
        </div>

        <div class="auth-testimonial">
            <p>“Lần đầu build phím mà không phải hỏi ai. Chọn sai stab là nó báo ngay, đỡ mất 400k.”</p>
            <div class="testimonial-author">
                <div class="testimonial-avatar">PV</div>
                <div>
                    <strong>Phạm Vũ</strong>
                    <span>Đã build 3 bàn phím tại KeebHub</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Cột phải -->
    <div class="auth-right-panel">
        <div class="auth-form-container">
            <div class="auth-form-header">
                <h2>Đăng nhập</h2>
                <p>Chưa có tài khoản? <a href="register">Đăng ký miễn phí</a></p>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert-box alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <% if (request.getAttribute("successMsg") != null) { %>
            <div class="alert-box alert-success"><%= request.getAttribute("successMsg") %></div>
            <% } %>

            <div class="social-btn-grid">
                <a href="#" class="btn-social"><strong>G</strong> Google</a>
                <a href="#" class="btn-social"><strong>f</strong> Facebook</a>
            </div>

            <div class="auth-divider">hoặc đăng nhập bằng email</div>

            <%
                String redirectVal = request.getParameter("redirect");
                if (redirectVal == null || redirectVal.isBlank()) {
                    redirectVal = (String) request.getAttribute("redirect");
                }
            %>
            <form action="login" method="POST">
                <% if (redirectVal != null && !redirectVal.isBlank()) { %>
                <input type="hidden" name="redirect" value="<%= redirectVal %>">
                <% } %>
                <div class="form-group">
                    <label>Email hoặc số điện thoại</label>
                    <input type="text" name="account" class="form-control"
                           value="<%= request.getAttribute("account") != null ? request.getAttribute("account") : "" %>"
                           placeholder="nva@gmail.com" required>
                </div>

                <div class="form-group">
                    <label>Mật khẩu</label>
                    <div class="password-input-wrap">
                        <input type="password" name="password" id="loginPwd" class="form-control" required>
                        <button type="button" class="toggle-pwd-btn" onclick="togglePassword('loginPwd', this)" title="Hiện/Ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                    <span class="field-hint">Nhấn biểu tượng con mắt để hiện mật khẩu</span>
                </div>

                <div class="form-options-row">
                    <label class="checkbox-label" style="margin-bottom: 0;">
                        <input type="checkbox" name="remember" checked>
                        <span>Ghi nhớ đăng nhập</span>
                    </label>
                    <a href="forgot-password" style="font-weight: 700;">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="btn-submit-primary">Đăng nhập</button>
            </form>

            <div class="seller-callout-box">
                <span>🏪</span>
                <div>
                    Bạn là chủ shop? <a href="#">Đăng nhập Kênh người bán</a> để quản lý đơn và tiến độ gia công.
                </div>
            </div>

            <div class="auth-terms-note">
                Bằng việc đăng nhập, bạn đồng ý với <a href="#">Điều khoản sử dụng</a> và <a href="policy.jsp">Chính sách bảo mật</a> của KeebHub.
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword(inputId, btn) {
        const input = document.getElementById(inputId);
        if (!input) return;
        if (input.type === 'password') {
            input.type = 'text';
            btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
        } else {
            input.type = 'password';
            btn.innerHTML = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
        }
    }
</script>
</body>
</html>