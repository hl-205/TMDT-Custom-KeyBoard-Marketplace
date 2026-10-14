package controller;

import dao.UserDAO;
import util.EmailUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private static final String PHONE_REGEX = "^0\\d{9}$";
    private static final String PASSWORD_REGEX = "^(?=.*[A-Z])(?=.*\\d).{8,}$";
    private static final long OTP_TTL_MS = 5 * 60 * 1000L; // 5 phút

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("resend".equals(action)) {
            String regEmail = (String) session.getAttribute("reg_email");
            if (regEmail != null) {
                String newOtp = EmailUtils.generateOTP();
                long expiryTime = System.currentTimeMillis() + OTP_TTL_MS;
                session.setAttribute("reg_otp", newOtp);
                session.setAttribute("reg_otp_expiry", expiryTime);

                EmailUtils.sendOTPEmail(regEmail, newOtp, "Đăng ký tài khoản KeebHub");

                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(regEmail));
                request.setAttribute("remainingSeconds", 300L);
                request.setAttribute("infoMsg", "Đã gửi lại mã OTP mới (hiệu lực 5 phút).");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
        }
        request.setAttribute("step", 1);
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String stepParam = request.getParameter("step");
        HttpSession session = request.getSession();

        if ("1".equals(stepParam)) {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String agreeTerms = request.getParameter("agreeTerms");

            request.setAttribute("firstName", firstName);
            request.setAttribute("lastName", lastName);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);

            if (firstName == null || firstName.isBlank() || lastName == null || lastName.isBlank()
                    || email == null || email.isBlank() || phone == null || phone.isBlank()
                    || password == null || password.isBlank()) {
                request.setAttribute("error", "Vui lòng điền đầy đủ các trường thông tin.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (!phone.trim().matches(PHONE_REGEX)) {
                request.setAttribute("error", "Số điện thoại không hợp lệ (phải gồm đúng 10 chữ số và bắt đầu bằng số 0).");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (!password.matches(PASSWORD_REGEX)) {
                request.setAttribute("error", "Mật khẩu phải có tối thiểu 8 ký tự, bao gồm ít nhất 1 chữ cái viết hoa và 1 chữ số.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirmPassword)) {
                request.setAttribute("error", "Mật khẩu nhập lại không khớp.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (agreeTerms == null) {
                request.setAttribute("error", "Bạn cần đồng ý với Điều khoản sử dụng của KeebHub.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (userDAO.isEmailExists(email)) {
                request.setAttribute("error", "Email này đã được đăng ký. Vui lòng sử dụng email khác.");
                request.setAttribute("step", 1);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            String otp = EmailUtils.generateOTP();
            long expiryTime = System.currentTimeMillis() + OTP_TTL_MS;

            session.setAttribute("reg_firstName", firstName.trim());
            session.setAttribute("reg_lastName", lastName.trim());
            session.setAttribute("reg_email", email.trim());
            session.setAttribute("reg_phone", phone.trim());
            session.setAttribute("reg_password", password);
            session.setAttribute("reg_otp", otp);
            session.setAttribute("reg_otp_expiry", expiryTime);

            EmailUtils.sendOTPEmail(email.trim(), otp, "Đăng ký tài khoản KeebHub");

            request.setAttribute("step", 2);
            request.setAttribute("maskedEmail", EmailUtils.maskEmail(email.trim()));
            request.setAttribute("remainingSeconds", 300L);
            request.getRequestDispatcher("register.jsp").forward(request, response);

        } else if ("2".equals(stepParam)) {
            String otpInput = request.getParameter("otp");
            String sessionOtp = (String) session.getAttribute("reg_otp");
            Long expiryTime = (Long) session.getAttribute("reg_otp_expiry");
            String email = (String) session.getAttribute("reg_email");

            if (sessionOtp == null || email == null || expiryTime == null) {
                response.sendRedirect("register");
                return;
            }

            long remainingSec = Math.max(0L, (expiryTime - System.currentTimeMillis()) / 1000L);
            if (remainingSec <= 0) {
                request.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng bấm 'Gửi lại mã' để nhận mã mới.");
                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(email));
                request.setAttribute("remainingSeconds", 0L);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            if (otpInput != null && otpInput.trim().equals(sessionOtp)) {
                String firstName = (String) session.getAttribute("reg_firstName");
                String lastName = (String) session.getAttribute("reg_lastName");
                String phone = (String) session.getAttribute("reg_phone");
                String password = (String) session.getAttribute("reg_password");

                boolean success = userDAO.registerUser(firstName, lastName, email, phone, password);
                if (success) {
                    session.removeAttribute("reg_otp");
                    session.removeAttribute("reg_otp_expiry");
                    session.removeAttribute("reg_password");
                    request.setAttribute("step", 3);
                    request.setAttribute("registeredEmail", email);
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Không thể lưu tài khoản. Vui lòng thử lại.");
                    request.setAttribute("step", 1);
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Mã xác thực OTP không chính xác.");
                request.setAttribute("step", 2);
                request.setAttribute("maskedEmail", EmailUtils.maskEmail(email));
                request.setAttribute("remainingSeconds", remainingSec);
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        }
    }
}