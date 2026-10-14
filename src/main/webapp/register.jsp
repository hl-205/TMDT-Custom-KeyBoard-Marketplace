<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer stepObj = (Integer) request.getAttribute("step");
    int step = (stepObj != null) ? stepObj : 1;
    Long remSecObj = (Long) request.getAttribute("remainingSeconds");
    long remainingSeconds = (remSecObj != null) ? remSecObj : 300L;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng ký tài khoản - KeebHub</title>
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

        <div class="auth-left-center" style="margin-bottom: 40px;">
            <h1>Tạo tài khoản,<br>build phím đầu tiên</h1>
            <p class="lead-desc">Miễn phí hoàn toàn. Lưu cấu hình không giới hạn, nhận ưu đãi riêng cho thành viên mới và theo dõi đơn gia công theo thời gian thực.</p>

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

        <div class="auth-keeb-illustration" style="bottom: 160px;">
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
        <div></div>
    </div>

    <!-- Cột phải -->
    <div class="auth-right-panel">
        <div class="auth-form-container">
            <div class="auth-form-header">
                <h2>Đăng ký tài khoản</h2>
                <p>Đã có tài khoản? <a href="login">Đăng nhập</a></p>
            </div>

            <!-- Thanh tiến trình 3 bước -->
            <div class="auth-stepper">
                <div class="step-node <%= step == 1 ? "active" : "done" %>">
                    <span class="step-circle"><%= step > 1 ? "✓" : "1" %></span>
                    <span>Thông tin</span>
                </div>
                <div class="step-line"></div>
                <div class="step-node <%= step == 2 ? "active" : (step > 2 ? "done" : "") %>">
                    <span class="step-circle"><%= step > 2 ? "✓" : "2" %></span>
                    <span>Xác thực OTP</span>
                </div>
                <div class="step-line"></div>
                <div class="step-node <%= step == 3 ? "active" : "" %>">
                    <span class="step-circle">3</span>
                    <span>Hoàn tất</span>
                </div>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert-box alert-error" id="serverErrorBox"><%= request.getAttribute("error") %></div>
            <% } %>
            <div class="alert-box alert-error" id="clientErrorBox" style="display: none;"></div>

            <% if (request.getAttribute("infoMsg") != null) { %>
            <div class="alert-box alert-success"><%= request.getAttribute("infoMsg") %></div>
            <% } %>

            <% if (step == 1) { %>
            <!-- BƯỚC 1: ĐIỀN THÔNG TIN -->
            <form action="register" method="POST" id="registerStep1Form">
                <input type="hidden" name="step" value="1">
                <div class="form-row-2">
                    <div class="form-group">
                        <label>Họ</label>
                        <input type="text" name="firstName" class="form-control"
                               value="<%= request.getAttribute("firstName") != null ? request.getAttribute("firstName") : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label>Tên</label>
                        <input type="text" name="lastName" class="form-control"
                               value="<%= request.getAttribute("lastName") != null ? request.getAttribute("lastName") : "" %>" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" class="form-control"
                           value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
                    <span class="field-hint">Dùng để nhận xác nhận đơn hàng và thông báo tiến độ</span>
                </div>

                <div class="form-group">
                    <label>Số điện thoại</label>
                    <input type="tel" name="phone" id="regPhone" class="form-control"
                           inputmode="numeric" maxlength="10" pattern="0[0-9]{9}"
                           placeholder="0987654321"
                           oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                           value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>" required>
                </div>

                <div class="form-group">
                    <label>Mật khẩu</label>
                    <div class="password-input-wrap">
                        <input type="password" name="password" id="regPwd" class="form-control"
                               oninput="evaluatePasswordStrength(this.value)" required>
                        <button type="button" class="toggle-pwd-btn" onclick="togglePassword('regPwd', this)" title="Hiện/Ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                    <div class="pwd-strength-bars" id="pwdStrengthBars">
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                    </div>
                    <span class="field-hint" id="pwdHintText">Yêu cầu: tối thiểu 8 ký tự, có chữ hoa và số</span>
                </div>

                <div class="form-group">
                    <label>Nhập lại mật khẩu</label>
                    <div class="password-input-wrap">
                        <input type="password" name="confirmPassword" id="regConfirmPwd" class="form-control" required>
                        <button type="button" class="toggle-pwd-btn" onclick="togglePassword('regConfirmPwd', this)" title="Hiện/Ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                </div>

                <label class="checkbox-label">
                    <input type="checkbox" name="agreeTerms" checked>
                    <span>Tôi đồng ý với <a href="#">Điều khoản sử dụng</a> và <a href="policy.jsp">Chính sách bảo mật</a> của KeebHub</span>
                </label>

                <label class="checkbox-label" style="margin-bottom: 20px;">
                    <input type="checkbox" name="newsletter">
                    <span>Nhận email về group buy, hàng mới về và ưu đãi (có thể tắt bất cứ lúc nào)</span>
                </label>

                <button type="submit" class="btn-submit-primary">Tiếp tục · Gửi mã OTP</button>
            </form>

            <div class="auth-divider">hoặc đăng ký nhanh bằng</div>

            <div class="social-btn-grid">
                <a href="#" class="btn-social"><strong>G</strong> Google</a>
                <a href="#" class="btn-social"><strong>f</strong> Facebook</a>
            </div>

            <% } else if (step == 2) { %>
            <!-- BƯỚC 2: XÁC THỰC 6 SỐ OTP QUA EMAIL -->
            <p style="color: #64748B; margin-bottom: 18px;">
                Chúng tôi đã gửi mã 6 số tới <strong style="color: #0F172A;"><%= request.getAttribute("maskedEmail") %></strong>
            </p>

            <form action="register" method="POST" id="otpForm">
                <input type="hidden" name="step" value="2">
                <input type="hidden" name="otp" id="fullOtpInput">

                <div class="form-group">
                    <label>Mã xác thực</label>
                    <div class="otp-boxes-wrapper">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input" autofocus>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-digit-input">
                    </div>
                </div>

                <div class="otp-timer-row">
                    <span>Mã hết hạn sau <strong id="countdownTimer" data-seconds="<%= remainingSeconds %>">05:00</strong></span>
                    <a href="register?action=resend" style="font-weight: 700;">Gửi lại mã</a>
                </div>

                <button type="submit" class="btn-submit-primary" id="otpSubmitBtn">Xác nhận & Hoàn tất</button>
            </form>

            <div class="otp-spam-warning">
                ⚠️ Không nhận được mã? Kiểm tra hộp thư Spam hoặc Quảng cáo (hoặc cửa sổ Console của Tomcat nếu chưa cấu hình SMTP). Nếu email sai, <a href="register">nhập lại email khác.</a>
            </div>

            <% } else if (step == 3) { %>
            <!-- BƯỚC 3: HOÀN TẤT ĐĂNG KÝ -->
            <div style="text-align: center; padding: 20px 0;">
                <div style="width: 64px; height: 64px; border-radius: 50%; background: #DCFCE7; color: #16A34A; font-size: 30px; font-weight: bold; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">✓</div>
                <h3 style="font-size: 22px; margin-bottom: 8px;">Tạo tài khoản thành công!</h3>
                <p style="color: #64748B; margin-bottom: 24px;">
                    Email <strong><%= request.getAttribute("registeredEmail") %></strong> đã được xác thực. Bạn có thể đăng nhập ngay để bắt đầu build bàn phím.
                </p>
                <a href="login" class="btn-submit-primary" style="display: flex; align-items: center; justify-content: center;">Đăng nhập ngay</a>
            </div>
            <% } %>
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

    function evaluatePasswordStrength(pwd) {
        const bars = document.querySelectorAll('#pwdStrengthBars .pwd-bar');
        const hint = document.getElementById('pwdHintText');
        if (!bars.length || !hint) return;

        bars.forEach(b => b.className = 'pwd-bar');

        const hasLength = pwd.length >= 8;
        const hasUpper = /[A-Z]/.test(pwd);
        const hasNumber = /\d/.test(pwd);
        const hasSpecial = /[^A-Za-z0-9]/.test(pwd);

        let score = 0;
        if (hasLength) score++;
        if (hasUpper) score++;
        if (hasNumber) score++;
        if (hasSpecial && hasLength && hasUpper && hasNumber) score++;

        const colorClass = (hasLength && hasUpper && hasNumber) ? 'strong' : (score >= 2 ? 'medium' : 'weak');
        for (let i = 0; i < score; i++) {
            bars[i].classList.add(colorClass);
        }

        if (hasLength && hasUpper && hasNumber) {
            hint.textContent = 'Mạnh · tối thiểu 8 ký tự, có chữ hoa và số';
            hint.style.color = '#16A34A';
        } else {
            hint.textContent = 'Chưa đạt · cần tối thiểu 8 ký tự, có ít nhất 1 chữ hoa và 1 chữ số';
            hint.style.color = '#EF4444';
        }
    }

    // Kiểm tra chặn form Bước 1 ngay trên trình duyệt nếu sai SĐT hoặc mật khẩu
    const step1Form = document.getElementById('registerStep1Form');
    if (step1Form) {
        step1Form.addEventListener('submit', function(e) {
            const phone = document.getElementById('regPhone').value.trim();
            const pwd = document.getElementById('regPwd').value;
            const confirmPwd = document.getElementById('regConfirmPwd').value;
            const errBox = document.getElementById('clientErrorBox');

            if (!/^0\d{9}$/.test(phone)) {
                e.preventDefault();
                errBox.style.display = 'block';
                errBox.textContent = 'Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng số 0.';
                return;
            }
            if (!/^(?=.*[A-Z])(?=.*\d).{8,}$/.test(pwd)) {
                e.preventDefault();
                errBox.style.display = 'block';
                errBox.textContent = 'Mật khẩu phải có tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ hoa và 1 chữ số.';
                return;
            }
            if (pwd !== confirmPwd) {
                e.preventDefault();
                errBox.style.display = 'block';
                errBox.textContent = 'Mật khẩu nhập lại không khớp.';
            }
        });
    }

    // Xử lý 6 ô nhập OTP & Đồng hồ đếm ngược ở Bước 2
    const inputs = document.querySelectorAll('.otp-digit-input');
    const otpForm = document.getElementById('otpForm');
    if (inputs.length > 0 && otpForm) {
        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                e.target.value = e.target.value.replace(/[^0-9]/g, '');
                if (e.target.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !e.target.value && index > 0) {
                    inputs[index - 1].focus();
                }
            });
            input.addEventListener('paste', (e) => {
                const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g, '');
                if (pasted.length === 6) {
                    e.preventDefault();
                    inputs.forEach((inp, idx) => inp.value = pasted[idx] || '');
                    inputs[5].focus();
                }
            });
        });

        otpForm.addEventListener('submit', (e) => {
            let code = '';
            inputs.forEach(inp => code += inp.value.trim());
            if (code.length < 6) {
                e.preventDefault();
                const errBox = document.getElementById('clientErrorBox');
                errBox.style.display = 'block';
                errBox.textContent = 'Vui lòng nhập đủ 6 chữ số mã xác thực OTP.';
                return;
            }
            document.getElementById('fullOtpInput').value = code;
        });
    }

    // Đồng hồ đếm ngược thực tế
    const timerEl = document.getElementById('countdownTimer');
    const otpSubmitBtn = document.getElementById('otpSubmitBtn');
    if (timerEl) {
        let totalSeconds = parseInt(timerEl.getAttribute('data-seconds'), 10);
        if (isNaN(totalSeconds)) totalSeconds = 300;

        const renderTime = (sec) => {
            const m = String(Math.floor(sec / 60)).padStart(2, '0');
            const s = String(sec % 60).padStart(2, '0');
            timerEl.textContent = m + ':' + s;
        };

        renderTime(totalSeconds);
        const interval = setInterval(() => {
            if (totalSeconds > 0) {
                totalSeconds--;
                renderTime(totalSeconds);
            }
            if (totalSeconds <= 0) {
                clearInterval(interval);
                timerEl.textContent = '00:00 (Đã hết hạn)';
                timerEl.classList.add('expired');
                if (otpSubmitBtn) otpSubmitBtn.disabled = true;
            }
        }, 1000);
    }
</script>
</body>
</html>