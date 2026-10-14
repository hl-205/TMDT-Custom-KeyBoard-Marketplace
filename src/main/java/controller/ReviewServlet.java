package controller;

import dao.CustomOrderDAO;
import dao.ProductDAO;
import model.Product;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Set;

@WebServlet(urlPatterns = {"/my-orders", "/my-reviews", "/review"})
public class ReviewServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final CustomOrderDAO customOrderDAO = new CustomOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        // Đảm bảo dữ liệu DB đã được chuẩn hóa (tách review mẫu Nguyễn Minh, Trần Hoàng khỏi user_id=1)
        customOrderDAO.ensureDatabaseNormalized();

        String path = request.getServletPath();
        Set<Integer> reviewedProductIds = productDAO.getReviewedProductIdsByUser(user.getId());
        request.setAttribute("reviewedProductIds", reviewedProductIds);

        if ("/my-orders".equals(path)) {
            request.setAttribute("userOrders", customOrderDAO.getOrdersByUserId(user.getId()));
            request.getRequestDispatcher("my-orders.jsp").forward(request, response);
            return;
        }

        if ("/my-reviews".equals(path)) {
            request.setAttribute("pendingReviewOrders", customOrderDAO.getPendingReviewOrdersByUser(user.getId()));
            request.setAttribute("myReviews", productDAO.getReviewsByUserId(user.getId()));
            request.getRequestDispatcher("my-reviews.jsp").forward(request, response);
            return;
        }

        int productId = 7;
        try {
            if (request.getParameter("productId") != null) {
                productId = Integer.parseInt(request.getParameter("productId"));
            }
        } catch (NumberFormatException ignored) {}

        String orderCode = request.getParameter("orderCode");
        if (orderCode == null || orderCode.isEmpty()) orderCode = "KH-281044";

        String variant = request.getParameter("variant");
        if (variant == null || variant.isEmpty()) variant = "Phân loại: Black & Pink · ×1";

        Product product = productDAO.getProductById(productId);
        if (product == null) product = productDAO.getProductById(1);

        request.setAttribute("product", product);
        request.setAttribute("orderCode", orderCode);
        request.setAttribute("variant", variant);
        request.getRequestDispatcher("review.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        int productId = 7;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
        } catch (Exception ignored) {}

        int rating = parseRating(request.getParameter("rating"));
        int qualityRating = parseRating(request.getParameter("qualityRating"));
        int accuracyRating = parseRating(request.getParameter("accuracyRating"));
        int deliveryRating = parseRating(request.getParameter("deliveryRating"));

        String orderCode = request.getParameter("orderCode");
        String variant = request.getParameter("variant");
        String comment = request.getParameter("comment");
        String[] quickTags = request.getParameterValues("quickTags");
        String anonymous = request.getParameter("anonymous");

        if (comment == null || comment.trim().length() < 20) {
            Product product = productDAO.getProductById(productId);
            request.setAttribute("product", product);
            request.setAttribute("orderCode", orderCode);
            request.setAttribute("variant", variant);
            request.setAttribute("comment", comment);
            request.setAttribute("error", "Nhận xét của bạn phải có tối thiểu 20 ký tự.");
            request.getRequestDispatcher("review.jsp").forward(request, response);
            return;
        }

        String reviewerName = user.getFullName();
        String avatarText = (user.getAvatarText() != null && !user.getAvatarText().isBlank()) ? user.getAvatarText() : "KH";

        if ("on".equals(anonymous)) {
            reviewerName = user.getMaskedName();
        }

        String variantWithSubRatings = variant + " · (Chất lượng: " + qualityRating + "★ | Mô tả: " + accuracyRating + "★ | Giao hàng: " + deliveryRating + "★)";

        StringBuilder fullComment = new StringBuilder();
        if (quickTags != null && quickTags.length > 0) {
            fullComment.append("[").append(String.join(" · ", quickTags)).append("] ");
        }
        fullComment.append(comment.trim());

        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        boolean ok = productDAO.addReview(productId, user.getId(), reviewerName, avatarText, rating, variantWithSubRatings, fullComment.toString(), today);

        if (ok) {
            user.setPoints(user.getPoints() + 50);
            session.setAttribute("user", user);
        }

        response.sendRedirect("my-reviews?msg=submitted");
    }

    private int parseRating(String val) {
        try {
            int r = Integer.parseInt(val);
            return (r >= 1 && r <= 5) ? r : 5;
        } catch (Exception e) {
            return 5;
        }
    }
}