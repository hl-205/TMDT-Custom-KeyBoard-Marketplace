package controller;

import dao.ProductDAO;
import dao.ProductDAO.ReviewItem;
import dao.ProductDAO.ReviewStats;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/product-detail")
public class ProductDetailServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int productId = 1;
        String idParam = request.getParameter("id");
        if (idParam != null) {
            try {
                productId = Integer.parseInt(idParam);
            } catch (NumberFormatException ignored) {
            }
        }

        Product product = productDAO.getProductById(productId);
        if (product == null) {
            productId = 1;
            product = productDAO.getProductById(1);
        }

        Integer starFilter = null;
        String starParam = request.getParameter("star");
        if (starParam != null && !starParam.isBlank()) {
            try {
                int s = Integer.parseInt(starParam.trim());
                if (s >= 1 && s <= 5) starFilter = s;
            } catch (NumberFormatException ignored) {}
        }

        boolean hasImage = "1".equals(request.getParameter("hasImage"));
        boolean hasCustom = "1".equals(request.getParameter("hasCustom"));

        int revLimit = 15;
        String limitParam = request.getParameter("revLimit");
        if (limitParam != null && !limitParam.isBlank()) {
            try {
                revLimit = Math.max(15, Integer.parseInt(limitParam.trim()));
            } catch (NumberFormatException ignored) {}
        }

        ReviewStats reviewStats = productDAO.getReviewStatsByProduct(productId);
        int filteredReviewCount = productDAO.countReviewsFiltered(productId, starFilter, hasImage, hasCustom);
        List<ReviewItem> reviewItems = productDAO.getFilteredReviewsPaginated(
                productId, starFilter, hasImage, hasCustom, revLimit, 0
        );

        request.setAttribute("product", product);
        request.setAttribute("colorOptions", productDAO.getOptionsByGroup(productId, "COLOR"));
        request.setAttribute("plateOptions", productDAO.getOptionsByGroup(productId, "PLATE"));
        request.setAttribute("specs", productDAO.getSpecsByProductId(productId));
        request.setAttribute("compatibilities", productDAO.getCompatibilitiesByProductId(productId));
        request.setAttribute("reviews", productDAO.getReviewsByProductId(productId));
        request.setAttribute("reviewStats", reviewStats);
        request.setAttribute("reviewItems", reviewItems);
        request.setAttribute("filteredReviewCount", filteredReviewCount);
        request.setAttribute("starFilter", starFilter);
        request.setAttribute("hasImage", hasImage);
        request.setAttribute("hasCustom", hasCustom);
        request.setAttribute("revLimit", revLimit);
        request.setAttribute("similarProducts", productDAO.getSimilarProducts(productId, 6));

        request.getRequestDispatcher("product-detail.jsp").forward(request, response);
    }
}