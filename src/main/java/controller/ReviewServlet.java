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
import java.util.HashSet;
import java.util.Set;

@WebServlet(urlPatterns = {"/my-orders", "/my-reviews", "/review", "/review-action"})
public class ReviewServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final CustomOrderDAO customOrderDAO = new CustomOrderDAO();

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String path = request.getServletPath();

        // Cho phép bấm Like / Dislike (Hữu ích / Không hữu ích) trên đánh giá
        if ("/review-action".equals(path)) {
            String act = request.getParameter("act");
            String prodId = request.getParameter("productId");
            if (prodId == null || prodId.isBlank()) prodId = "1";

            if ("vote".equals(act)) {
                try {
                    int revId = Integer.parseInt(request.getParameter("reviewId"));
                    boolean helpful = "1".equals(request.getParameter("helpful"));
                    Set<String> votedSet = (Set<String>) session.getAttribute("votedReviews");
                    if (votedSet == null) {
                        votedSet = new HashSet<>();
                        session.setAttribute("votedReviews", votedSet);
                    }
                    String voteKey = revId + "_" + (helpful ? "up" : "down");
                    if (!votedSet.contains(voteKey)) {
                        productDAO.voteReviewHelpful(revId, helpful);
                        votedSet.add(voteKey);
                    }
                } catch (Exception ignored) {}
            }
            response.sendRedirect("product-detail?id=" + prodId + "#sec-danhgia");
            return;
        }

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        customOrderDAO.ensureDatabaseNormalized();
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
        if (orderCode == null || orderCode.isEmpty()) orderCode = "KH-20261010-002";

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
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        String path = request.getServletPath();
        if ("/review-action".equals(path)) {
            String prodId = request.getParameter("productId");
            if (prodId == null || prodId.isBlank()) prodId = "1";
            if (user == null) {
                response.sendRedirect("login?redirect=" + request.getContextPath() + "/product-detail?id=" + prodId);
                return;
            }
            String act = request.getParameter("act");
            if ("reply".equals(act)) {
                try {
                    int revId = Integer.parseInt(request.getParameter("reviewId"));
                    String replyComment = request.getParameter("replyComment");
                    if (replyComment != null && !replyComment.isBlank()) {
                        String roleBadge = "Khách hàng";
                        if ("SELLER".equalsIgnoreCase(user.getRole())) roleBadge = "Chủ xưởng";
                        else if ("ADMIN".equalsIgnoreCase(user.getRole())) roleBadge = "Quản trị viên";
                        productDAO.addReviewReply(revId, user.getId(), user.getFullName(), roleBadge, replyComment.trim());
                    }
                } catch (Exception ignored) {}
            }
            response.sendRedirect("product-detail?id=" + prodId + "#sec-danhgia");
            return;
        }

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
        String imageUrls = request.getParameter("imageUrls");
        boolean hasCustomService = "on".equals(request.getParameter("isCustomService"))
                || (variant != null && (variant.toLowerCase().contains("lube") || variant.toLowerCase().contains("custom") || variant.toLowerCase().contains("gói")));

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
        boolean ok = productDAO.addReview(
                productId, user.getId(), reviewerName, avatarText, rating,
                variantWithSubRatings, fullComment.toString(), today, imageUrls, hasCustomService
        );

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