package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet(urlPatterns = {"/profile", "/customer/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy thông tin mới nhất từ database
        User freshUser = userDAO.getUserById(sessionUser.getId());
        if (freshUser != null) {
            session.setAttribute("user", freshUser);
            request.setAttribute("profileUser", freshUser);
        } else {
            request.setAttribute("profileUser", sessionUser);
        }

        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;

        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "update_profile";

        if ("update_profile".equalsIgnoreCase(action)) {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String phone = request.getParameter("phone");
            String gender = request.getParameter("gender");
            String dob = request.getParameter("dob");
            String address = request.getParameter("address");

            if (firstName == null || firstName.trim().isEmpty() || lastName == null || lastName.trim().isEmpty()) {
                request.setAttribute("errorMsg", "Họ và tên không được để trống.");
                forwardWithUser(request, response, sessionUser.getId());
                return;
            }

            boolean success = userDAO.updateProfile(sessionUser.getId(), firstName, lastName, phone, gender, dob, address);
            if (success) {
                User updated = userDAO.getUserById(sessionUser.getId());
                session.setAttribute("user", updated);
                request.setAttribute("profileUser", updated);
                request.setAttribute("successMsg", "Cập nhật thông tin cá nhân và địa chỉ thành công!");
            } else {
                request.setAttribute("errorMsg", "Có lỗi xảy ra trong quá trình cập nhật thông tin. Vui lòng thử lại.");
                forwardWithUser(request, response, sessionUser.getId());
                return;
            }
        } else if ("change_password".equalsIgnoreCase(action)) {
            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (currentPassword == null || currentPassword.isBlank() ||
                newPassword == null || newPassword.isBlank() ||
                confirmPassword == null || confirmPassword.isBlank()) {
                request.setAttribute("pwdErrorMsg", "Vui lòng nhập đầy đủ các trường mật khẩu.");
                request.setAttribute("activeTab", "password");
                forwardWithUser(request, response, sessionUser.getId());
                return;
            }

            if (newPassword.length() < 6) {
                request.setAttribute("pwdErrorMsg", "Mật khẩu mới phải có tối thiểu 6 ký tự.");
                request.setAttribute("activeTab", "password");
                forwardWithUser(request, response, sessionUser.getId());
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("pwdErrorMsg", "Xác nhận mật khẩu mới không trùng khớp.");
                request.setAttribute("activeTab", "password");
                forwardWithUser(request, response, sessionUser.getId());
                return;
            }

            boolean changed = userDAO.changePassword(sessionUser.getId(), currentPassword, newPassword);
            if (changed) {
                request.setAttribute("pwdSuccessMsg", "Đổi mật khẩu tài khoản thành công!");
                request.setAttribute("activeTab", "password");
            } else {
                request.setAttribute("pwdErrorMsg", "Mật khẩu hiện tại không chính xác.");
                request.setAttribute("activeTab", "password");
            }
        }

        forwardWithUser(request, response, sessionUser.getId());
    }

    private void forwardWithUser(HttpServletRequest request, HttpServletResponse response, int userId)
            throws ServletException, IOException {
        User user = userDAO.getUserById(userId);
        request.setAttribute("profileUser", user);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}
