package controller;

import dao.ProductDAO;
import model.Product;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@WebServlet(urlPatterns = {"/my-orders", "/review"})
public class ReviewServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/my-orders".equals(path)) {
            request.getRequestDispatcher("my-orders.jsp").forward(request, response);
            return;
        }

        int productId = 7; // Mặc định Keycap Akko Black & Pink ASA profile (chuẩn Frame 16)
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
        int productId = 7;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
        } catch (Exception ignored) {}

        int rating = 5;
        try {
            rating = Integer.parseInt(request.getParameter("rating"));
            if (rating < 1 || rating > 5) rating = 5;
        } catch (Exception ignored) {}

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

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Integer userId = (user != null) ? user.getId() : 1;
        String reviewerName = (user != null) ? user.getFullName() : "Lê Tùng Dương";
        String avatarText = (user != null && user.getAvatarText() != null) ? user.getAvatarText() : "DT";

        if ("on".equals(anonymous)) {
            reviewerName = "L*** D**";
        }

        StringBuilder fullComment = new StringBuilder();
        if (quickTags != null && quickTags.length > 0) {
            fullComment.append("[").append(String.join(" · ", quickTags)).append("] ");
        }
        fullComment.append(comment.trim());

        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        productDAO.addReview(productId, userId, reviewerName, avatarText, rating, variant, fullComment.toString(), today);

        response.sendRedirect("product-detail?id=" + productId + "#sec-danhgia");
    }
}