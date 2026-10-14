package controller;

import dao.UserDAO;
import util.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private static final String PASSWORD_REGEX = "^(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final long OTP_TTL_MS = 5 * 60 * 1000L; // 5 phút

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("resend".equals(action)) {
            String fpEmail = (String) session.getAttribute("fp_email");
            if (fpEmail != null) {
                String newOtp = EmailUtils.generateOTP();
                long expiryTime = System.currentTimeMillis() + OTP_TTL_MS;
                session.setAttribute("fp_otp", newOtp);
                session.setAttribute("fp_otp_expiry", expiryTime);

                EmailUtils.sendOTPEmail(fpEmail, newOtp, "Khôi phục mật khẩu KeebHub");

                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(fpEmail));
                request.setAttribute("remainingSeconds", 300L);
                request.setAttribute("infoMsg", "Đã gửi lại mã OTP mới tới email của bạn.");
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }
        }
        request.setAttribute("step", 1);
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String stepParam = request.getParameter("step");
        HttpSession session = request.getSession();

        if ("1".equals(stepParam)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập địa chỉ email đã đăng ký.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            if (!userDAO.isEmailExists(email.trim())) {
                request.setAttribute("error", "Email này chưa được đăng ký trong hệ thống KeebHub.");
                request.setAttribute("email", email);
                request.setAttribute("step", 1);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            String otp = EmailUtils.generateOTP();
            long expiryTime = System.currentTimeMillis() + OTP_TTL_MS;

            session.setAttribute("fp_email", email.trim());
            session.setAttribute("fp_otp", otp);
            session.setAttribute("fp_otp_expiry", expiryTime);
            session.setAttribute("fp_verified", false);

            EmailUtils.sendOTPEmail(email.trim(), otp, "Khôi phục mật khẩu KeebHub");

            request.setAttribute("step", 2);
            request.setAttribute("maskedEmail", EmailUtils.maskEmail(email.trim()));
            request.setAttribute("remainingSeconds", 300L);
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);

        } else if ("2".equals(stepParam)) {
            String otpInput = request.getParameter("otp");
            String sessionOtp = (String) session.getAttribute("fp_otp");
            Long expiryTime = (Long) session.getAttribute("fp_otp_expiry");
            String fpEmail = (String) session.getAttribute("fp_email");

            if (sessionOtp == null || fpEmail == null || expiryTime == null) {
                response.sendRedirect("forgot-password");
                return;
            }

            long remainingSec = Math.max(0L, (expiryTime - System.currentTimeMillis()) / 1000L);
            if (remainingSec <= 0) {
                request.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng bấm 'Gửi lại mã' để nhận mã mới.");
                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(fpEmail));
                request.setAttribute("remainingSeconds", 0L);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            if (otpInput != null && otpInput.trim().equals(sessionOtp)) {
                session.setAttribute("fp_verified", true);
                request.setAttribute("step", 3);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Mã xác thực OTP không chính xác. Vui lòng kiểm tra lại.");
                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(fpEmail));
                request.setAttribute("remainingSeconds", remainingSec);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            }

        } else if ("3".equals(stepParam)) {
            Boolean verified = (Boolean) session.getAttribute("fp_verified");
            String fpEmail = (String) session.getAttribute("fp_email");

            if (verified == null || !verified || fpEmail == null) {
                response.sendRedirect("forgot-password");
                return;
            }

            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || !newPassword.matches(PASSWORD_REGEX)) {
                request.setAttribute("error", "Mật khẩu mới phải có tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ cái viết hoa và 1 chữ số.");
                request.setAttribute("step", 3);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu nhập lại không khớp.");
                request.setAttribute("step", 3);
                request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
                return;
            }

            userDAO.updatePasswordByEmail(fpEmail, newPassword);
            session.removeAttribute("fp_email");
            session.removeAttribute("fp_otp");
            session.removeAttribute("fp_otp_expiry");
            session.removeAttribute("fp_verified");

            request.setAttribute("successMsg", "Đổi mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}