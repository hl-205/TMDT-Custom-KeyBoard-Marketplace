package controller;

import dao.CartDAO;
import dao.UserDAO;
import model.CartItem;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("redirect", request.getParameter("redirect"));
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String account = request.getParameter("account");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        String redirect = request.getParameter("redirect");

        if (account == null || account.trim().isEmpty() || password == null || password.isEmpty()) {
            showError(request, response, account, redirect,
                    "Vui lòng nhập đầy đủ Email/Số điện thoại và mật khẩu.");
            return;
        }

        User user = userDAO.checkLogin(account.trim(), password);
        if (user == null) {
            showError(request, response, account, redirect,
                    "Email/Số điện thoại hoặc mật khẩu không chính xác.");
            return;
        }

        HttpSession session = request.getSession();
        User previousUser = (User) session.getAttribute("user");
        boolean isGuestCart = previousUser == null;

        // Một biến thể được định danh bởi productId + variantLabel + extraPrice.
        // Chỉ gộp giỏ khách; không trộn giỏ của các tài khoản khác nhau.
        try {
            Map<String, CartItem> mergedCart = new LinkedHashMap<>(cartDAO.getCartByUserId(user.getId()));
            if (isGuestCart) {
                Object savedCart = session.getAttribute("cart");
                if (savedCart instanceof Map<?, ?>) {
                    Map<?, ?> guestCart = (Map<?, ?>) savedCart;
                    for (Object value : guestCart.values()) {
                        if (!(value instanceof CartItem)) continue;
                        CartItem item = (CartItem) value;
                        if (item.getProduct() == null || item.getProduct().getId() <= 0) continue;
                        String key = item.getKey();
                        CartItem existing = mergedCart.get(key);
                        if (existing == null) {
                            mergedCart.put(key, item);
                        } else {
                            long total = (long) existing.getQuantity() + item.getQuantity();
                            existing.setQuantity((int) Math.min(99L, total));
                        }
                    }
                    if (!guestCart.isEmpty()) {
                        cartDAO.syncCart(user.getId(), mergedCart);
                    }
                }
            }
            session.setAttribute("cart", mergedCart);
            session.removeAttribute("cartSyncError");
        } catch (RuntimeException ex) {
            log("Đăng nhập thành công nhưng đồng bộ giỏ hàng thất bại", ex);
            // Không để giỏ của một tài khoản cũ xuất hiện ở tài khoản mới.
            if (!isGuestCart) session.removeAttribute("cart");
            session.setAttribute("cartSyncError", "Không đồng bộ được giỏ hàng. Vui lòng thử lại sau.");
        }

        session.setAttribute("user", user);
        session.setAttribute("userAvatar", user.getAvatarText());
        session.setAttribute("userName", user.getShortDisplayName());
        session.setAttribute("userFullName", user.getFullName());
        session.setAttribute("userEmail", user.getEmail());

        if ("on".equals(remember)) {
            Cookie cookie = new Cookie("rememberedAccount", account.trim());
            cookie.setMaxAge(7 * 24 * 60 * 60);
            cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            cookie.setHttpOnly(true);
            response.addCookie(cookie);
        }

        String ctx = request.getContextPath();
        // Chỉ cho phép đường dẫn trong ứng dụng, tránh redirect tới website lạ.
        if (redirect != null && !redirect.isBlank()
                && redirect.startsWith(ctx + "/")
                && !redirect.startsWith(ctx + "//")
                && !redirect.contains("\\")
                && !redirect.contains("\r") && !redirect.contains("\n")
                && !redirect.contains("/login")) {
            response.sendRedirect(redirect);
        } else {
            response.sendRedirect(ctx + "/index.jsp");
        }
    }

    private void showError(HttpServletRequest request, HttpServletResponse response,
                           String account, String redirect, String message)
            throws ServletException, IOException {
        request.setAttribute("error", message);
        request.setAttribute("account", account);
        request.setAttribute("redirect", redirect);
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}
