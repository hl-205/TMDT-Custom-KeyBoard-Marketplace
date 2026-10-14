package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String account = request.getParameter("account");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        if (account == null || account.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ Email/Số điện thoại và mật khẩu.");
            request.setAttribute("account", account);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.checkLogin(account, password);
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userAvatar", user.getAvatarText());
            session.setAttribute("userName", user.getShortDisplayName());
            session.setAttribute("userFullName", user.getFullName());
            session.setAttribute("userEmail", user.getEmail());

            if ("on".equals(remember)) {
                Cookie c = new Cookie("rememberedAccount", account.trim());
                c.setMaxAge(7 * 24 * 60 * 60);
                response.addCookie(c);
            }
            response.sendRedirect("index.jsp");
        } else {
            request.setAttribute("error", "Email/Số điện thoại hoặc mật khẩu không chính xác.");
            request.setAttribute("account", account);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}