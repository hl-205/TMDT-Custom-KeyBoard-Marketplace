package controller;

import dao.CartDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;
import model.GoogleAccount;
import model.User;
import util.GoogleUtils;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/login-google")
public class GoogleLoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String baseUrl = request.getScheme() + "://" + request.getServerName()
                + ((request.getServerPort() == 80 || request.getServerPort() == 443) ? "" : ":" + request.getServerPort())
                + request.getContextPath();

        String error = request.getParameter("error");
        if (error != null) {
            request.setAttribute("error", "Bạn đã hủy đăng nhập bằng Google.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String code = request.getParameter("code");
        String redirect = request.getParameter("state");
        if (redirect == null || redirect.isBlank()) {
            redirect = request.getParameter("redirect");
        }

        // Bước 1: Nếu chưa có 'code' -> Chuyển hướng người dùng sang trang chọn tài khoản của Google
        if (code == null || code.isBlank()) {
            String authUrl = GoogleUtils.getAuthorizationUrl(baseUrl, redirect);
            response.sendRedirect(authUrl);
            return;
        }

        // Bước 2: Google trả về 'code' -> Đổi lấy Token & Thông tin User
        try {
            String redirectUri = GoogleUtils.getRedirectUri(baseUrl);
            String accessToken = GoogleUtils.getToken(code, redirectUri);
            GoogleAccount googleAcc = GoogleUtils.getUserInfo(accessToken);

            if (googleAcc == null || googleAcc.getEmail() == null || googleAcc.getEmail().isBlank()) {
                request.setAttribute("error", "Không lấy được địa chỉ Email từ tài khoản Google.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Kiểm tra tài khoản trong DB (nếu chưa có sẽ tự động tạo mới)
            String firstName = googleAcc.getGiven_name();
            String lastName = googleAcc.getFamily_name();
            if ((firstName == null || firstName.isBlank()) && googleAcc.getName() != null) {
                String[] parts = googleAcc.getName().trim().split("\\s+", 2);
                firstName = parts[0];
                lastName = parts.length > 1 ? parts[1] : "";
            }

            User user = userDAO.loginOrRegisterGoogleUser(googleAcc.getEmail(), firstName, lastName);
            if (user == null) {
                request.setAttribute("error", "Không thể khởi tạo tài khoản Google. Vui lòng thử lại.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
                request.setAttribute("error", "Tài khoản của bạn hiện đang bị khóa.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Đồng bộ giỏ hàng (Giống hệt LoginServlet)
            HttpSession session = request.getSession();
            User previousUser = (User) session.getAttribute("user");
            boolean isGuestCart = previousUser == null;

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
                log("Đăng nhập Google thành công nhưng đồng bộ giỏ hàng thất bại", ex);
                if (!isGuestCart) session.removeAttribute("cart");
                session.setAttribute("cartSyncError", "Không đồng bộ được giỏ hàng. Vui lòng thử lại sau.");
            }

            // Lưu thông tin User vào Session
            session.setAttribute("user", user);
            session.setAttribute("userAvatar", user.getAvatarText());
            session.setAttribute("userName", user.getShortDisplayName());
            session.setAttribute("userFullName", user.getFullName());
            session.setAttribute("userEmail", user.getEmail());

            // Chuyển hướng an toàn
            String ctx = request.getContextPath();
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

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đăng nhập bằng Google thất bại. Vui lòng thử lại.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}