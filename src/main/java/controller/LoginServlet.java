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

            // Lỗi giỏ hàng không được làm mất trạng thái đăng nhập.
            try {
                Map<String, CartItem> dbCart = cartDAO.getCartByUserId(user.getId());
                @SuppressWarnings("unchecked")
                Map<String, CartItem> sessionCart = (Map<String, CartItem>) session.getAttribute("cart");
                if (sessionCart != null && !sessionCart.isEmpty()) {
                    for (CartItem item : sessionCart.values()) {
                        if (item == null || item.getProduct() == null) continue;
                        CartItem existing = dbCart.get(item.getKey());
                        if (existing != null && existing.getExtraPrice() == item.getExtraPrice()) {
                            existing.setQuantity(Math.min(99, existing.getQuantity() + item.getQuantity()));
                        } else {
                            dbCart.put(item.getKey(), item);
                        }
                    }
                    cartDAO.syncCart(user.getId(), dbCart);
                }
                session.setAttribute("cart", dbCart);
            } catch (RuntimeException ex) {
                log("Đăng nhập thành công nhưng đồng bộ giỏ hàng thất bại", ex);
                // Giữ session cart hiện tại; không ghi đè bằng một giỏ hàng rỗng.
                session.setAttribute("cartSyncError", "Không đồng bộ được giỏ hàng. Vui lòng thử lại sau.");
            }

            // --- XỬ LÝ LƯU COOKIE GHI NHỚ TÀI KHOẢN ---
            if ("on".equals(remember)) {
                Cookie c = new Cookie("rememberedAccount", account.trim());
                c.setMaxAge(7 * 24 * 60 * 60); // Lưu 7 ngày
                response.addCookie(c);
            }

            if (redirect != null && !redirect.isBlank() && redirect.startsWith(request.getContextPath() + "/") && !redirect.contains("//")) {
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } else {
            request.setAttribute("error", "Email/Số điện thoại hoặc mật khẩu không chính xác.");
            request.setAttribute("account", account);
            request.setAttribute("redirect", redirect);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}