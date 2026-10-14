package controller;

import dao.ProductDAO;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

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
            product = productDAO.getProductById(1);
        }

        request.setAttribute("product", product);
        request.setAttribute("colorOptions", productDAO.getOptionsByGroup(productId, "COLOR"));
        request.setAttribute("plateOptions", productDAO.getOptionsByGroup(productId, "PLATE"));
        request.setAttribute("specs", productDAO.getSpecsByProductId(productId));
        request.setAttribute("compatibilities", productDAO.getCompatibilitiesByProductId(productId));
        request.setAttribute("reviews", productDAO.getReviewsByProductId(productId));
        request.setAttribute("similarProducts", productDAO.getSimilarProducts(productId, 6));

        request.getRequestDispatcher("product-detail.jsp").forward(request, response);
    }
}