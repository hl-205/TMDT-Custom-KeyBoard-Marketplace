package controller;

import dao.CartDAO;
import dao.UserDAO;
import model.CartItem;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Map;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String redirect = request.getParameter("redirect");
        request.setAttribute("redirect", redirect);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String account = request.getParameter("account");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        String redirect = request.getParameter("redirect");

        if (account == null || account.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ Email/Số điện thoại và mật khẩu.");
            request.setAttribute("account", account);
            request.setAttribute("redirect", redirect);
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

            // --- XỬ LÝ ĐỒNG BỘ GIỎ HÀNG VÀO DATABASE ---
            Map<Integer, CartItem> dbCart = cartDAO.getCartByUserId(user.getId());

            @SuppressWarnings("unchecked")
            Map<Integer, CartItem> sessionCart = (Map<Integer, CartItem>) session.getAttribute("cart");

            if (sessionCart != null && !sessionCart.isEmpty()) {
                for (CartItem item : sessionCart.values()) {
                    int pId = item.getProduct().getId();
                    int currentQty = dbCart.containsKey(pId) ? dbCart.get(pId).getQuantity() : 0;
                    int newQty = currentQty + item.getQuantity();

                    cartDAO.saveOrUpdateItem(user.getId(), pId, newQty);
                }
                // Tải lại giỏ hàng đầy đủ từ DB sau khi đã gộp
                dbCart = cartDAO.getCartByUserId(user.getId());
            }

            // Cập nhật lại giỏ hàng trong Session
            session.setAttribute("cart", dbCart);

            // --- XỬ LÝ LƯU COOKIE GHI NHỚ TÀI KHOẢN ---
            if ("on".equals(remember)) {
                Cookie c = new Cookie("rememberedAccount", account.trim());
                c.setMaxAge(7 * 24 * 60 * 60); // Lưu 7 ngày
                response.addCookie(c);
            }

            if (redirect != null && !redirect.isBlank() && !redirect.contains("login")) {
                response.sendRedirect(redirect);
                return;
            }
            response.sendRedirect("index.jsp");
        } else {
            request.setAttribute("error", "Email/Số điện thoại hoặc mật khẩu không chính xác.");
            request.setAttribute("account", account);
            request.setAttribute("redirect", redirect);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}