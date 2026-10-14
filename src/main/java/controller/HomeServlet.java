package controller;

import dao.ProductDAO;
import dao.ShopDAO;
import model.Product;
import model.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/home", "/index"})
public class HomeServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Product> bestSellingProducts = productDAO.getBestSellingProducts(6);
        List<Shop> topShops = shopDAO.getTopShops(4);

        request.setAttribute("bestSellingProducts", bestSellingProducts);
        request.setAttribute("topShops", topShops);

        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}
