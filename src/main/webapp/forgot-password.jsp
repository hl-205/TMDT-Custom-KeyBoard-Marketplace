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
    <title>Khôi phục mật khẩu - KeebHub</title>
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
            <h1>Quên mật khẩu?<br>Không sao cả</h1>
            <p class="lead-desc">Nhập email đã đăng ký, chúng tôi gửi mã xác thực 6 số. Toàn bộ quá trình mất chưa tới một phút.</p>

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

        <div class="auth-keeb-illustration" style="bottom: 180px;">
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
            <a href="login" class="back-login-link">‹ Quay lại đăng nhập</a>

            <% if (step == 1) { %>
            <div class="auth-form-header">
                <h2>Khôi phục mật khẩu</h2>
                <p>Nhập địa chỉ email đã đăng ký tài khoản KeebHub của bạn</p>
            </div>
            <% } else if (step == 2) { %>
            <div class="auth-form-header">
                <h2>Xác thực email</h2>
                <p>Chúng tôi đã gửi mã 6 số tới <strong style="color: #0F172A;"><%= request.getAttribute("maskedEmail") %></strong></p>
            </div>
            <% } else { %>
            <div class="auth-form-header">
                <h2>Mật khẩu mới</h2>
                <p>Thiết lập mật khẩu mới cho tài khoản của bạn</p>
            </div>
            <% } %>

            <!-- Stepper 3 bước -->
            <div class="auth-stepper">
                <div class="step-node <%= step == 1 ? "active" : "done" %>">
                    <span class="step-circle"><%= step > 1 ? "✓" : "1" %></span>
                    <span>Nhập email</span>
                </div>
                <div class="step-line"></div>
                <div class="step-node <%= step == 2 ? "active" : (step > 2 ? "done" : "") %>">
                    <span class="step-circle"><%= step > 2 ? "✓" : "2" %></span>
                    <span>Xác thực OTP</span>
                </div>
                <div class="step-line"></div>
                <div class="step-node <%= step == 3 ? "active" : "" %>">
                    <span class="step-circle">3</span>
                    <span>Mật khẩu mới</span>
                </div>
            </div>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert-box alert-error"><%= request.getAttribute("error") %></div>
            <% } %>
            <div class="alert-box alert-error" id="fpClientError" style="display: none;"></div>

            <% if (request.getAttribute("infoMsg") != null) { %>
            <div class="alert-box alert-success"><%= request.getAttribute("infoMsg") %></div>
            <% } %>

            <% if (step == 1) { %>
            <!-- BƯỚC 1: NHẬP EMAIL -->
            <form action="forgot-password" method="POST">
                <input type="hidden" name="step" value="1">
                <div class="form-group">
                    <label>Email đã đăng ký</label>
                    <input type="email" name="email" class="form-control"
                           placeholder="nva@gmail.com"
                           value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
                </div>
                <button type="submit" class="btn-submit-primary">Tiếp tục · Gửi mã xác thực</button>
            </form>

            <% } else if (step == 2) { %>
            <!-- BƯỚC 2: NHẬP 6 SỐ OTP (FRAME 12) -->
            <form action="forgot-password" method="POST" id="fpOtpForm">
                <input type="hidden" name="step" value="2">
                <input type="hidden" name="otp" id="fpFullOtp">

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
                    <span>Mã hết hạn sau <strong id="fpCountdownTimer" data-seconds="<%= remainingSeconds %>">05:00</strong></span>
                    <a href="forgot-password?action=resend" style="font-weight: 700;">Gửi lại mã</a>
                </div>

                <button type="submit" class="btn-submit-primary" id="fpOtpSubmitBtn">Xác nhận</button>
            </form>

            <div class="otp-spam-warning">
                ⚠️ Không nhận được mã? Kiểm tra hộp thư Spam hoặc Quảng cáo. Nếu email sai, <a href="forgot-password">nhập lại email khác.</a>
            </div>

            <% } else if (step == 3) { %>
            <!-- BƯỚC 3: ĐẶT LẠI MẬT KHẨU MỚI -->
            <form action="forgot-password" method="POST" id="fpResetPwdForm">
                <input type="hidden" name="step" value="3">
                <div class="form-group">
                    <label>Mật khẩu mới</label>
                    <div class="password-input-wrap">
                        <input type="password" name="newPassword" id="fpNewPwd" class="form-control"
                               oninput="evaluateFpPasswordStrength(this.value)" required>
                        <button type="button" class="toggle-pwd-btn" onclick="togglePassword('fpNewPwd', this)" title="Hiện/Ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                    <div class="pwd-strength-bars" id="fpPwdBars">
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                        <span class="pwd-bar"></span>
                    </div>
                    <span class="field-hint" id="fpPwdHint">Yêu cầu: tối thiểu 8 ký tự, có chữ hoa và số</span>
                </div>
                <div class="form-group">
                    <label>Nhập lại mật khẩu mới</label>
                    <div class="password-input-wrap">
                        <input type="password" name="confirmPassword" id="fpConfirmPwd" class="form-control" required>
                        <button type="button" class="toggle-pwd-btn" onclick="togglePassword('fpConfirmPwd', this)" title="Hiện/Ẩn mật khẩu">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                <circle cx="12" cy="12" r="3"></circle>
                            </svg>
                        </button>
                    </div>
                </div>
                <button type="submit" class="btn-submit-primary">Cập nhật mật khẩu</button>
            </form>
            <% } %>

            <div class="support-hotline-footer">
                Cần hỗ trợ? Gọi <strong>1900 6868</strong> (8h–21h mỗi ngày)
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

    function evaluateFpPasswordStrength(pwd) {
        const bars = document.querySelectorAll('#fpPwdBars .pwd-bar');
        const hint = document.getElementById('fpPwdHint');
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

    const fpInputs = document.querySelectorAll('.otp-digit-input');
    const fpForm = document.getElementById('fpOtpForm');
    if (fpInputs.length > 0 && fpForm) {
        fpInputs.forEach((input, idx) => {
            input.addEventListener('input', (e) => {
                e.target.value = e.target.value.replace(/[^0-9]/g, '');
                if (e.target.value.length === 1 && idx < fpInputs.length - 1) {
                    fpInputs[idx + 1].focus();
                }
            });
            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !e.target.value && idx > 0) {
                    fpInputs[idx - 1].focus();
                }
            });
            input.addEventListener('paste', (e) => {
                const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g, '');
                if (pasted.length === 6) {
                    e.preventDefault();
                    fpInputs.forEach((inp, i) => inp.value = pasted[i] || '');
                    fpInputs[5].focus();
                }
            });
        });

        fpForm.addEventListener('submit', (e) => {
            let otpVal = '';
            fpInputs.forEach(i => otpVal += i.value.trim());
            if (otpVal.length < 6) {
                e.preventDefault();
                const err = document.getElementById('fpClientError');
                err.style.display = 'block';
                err.textContent = 'Vui lòng nhập đủ 6 chữ số mã xác thực OTP.';
                return;
            }
            document.getElementById('fpFullOtp').value = otpVal;
        });
    }

    const fpTimerEl = document.getElementById('fpCountdownTimer');
    const fpSubmitBtn = document.getElementById('fpOtpSubmitBtn');
    if (fpTimerEl) {
        let totalSec = parseInt(fpTimerEl.getAttribute('data-seconds'), 10);
        if (isNaN(totalSec)) totalSec = 300;

        const render = (sec) => {
            const m = String(Math.floor(sec / 60)).padStart(2, '0');
            const s = String(sec % 60).padStart(2, '0');
            fpTimerEl.textContent = m + ':' + s;
        };

        render(totalSec);
        const timerId = setInterval(() => {
            if (totalSec > 0) {
                totalSec--;
                render(totalSec);
            }
            if (totalSec <= 0) {
                clearInterval(timerId);
                fpTimerEl.textContent = '00:00 (Đã hết hạn)';
                fpTimerEl.classList.add('expired');
                if (fpSubmitBtn) fpSubmitBtn.disabled = true;
            }
        }, 1000);
    }
</script>
</body>
</html>