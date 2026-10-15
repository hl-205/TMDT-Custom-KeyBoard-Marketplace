package controller;

import dao.ShopDAO;
import model.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/shops")
public class ShopsServlet extends HttpServlet {
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String type    = request.getParameter("type");   // "workshop" | "verified" | null
        String sort    = request.getParameter("sort");   // "popular" | "rating" | "newest" | "followers"

        Double minRating = null;
        try {
            String ratingParam = request.getParameter("minRating");
            if (ratingParam != null && !ratingParam.isEmpty()) {
                minRating = Double.parseDouble(ratingParam);
            }
        } catch (NumberFormatException ignored) {}

        if (sort == null || sort.isEmpty()) sort = "popular";
        if (keyword != null && keyword.trim().isEmpty()) keyword = null;

        List<Shop> shops = shopDAO.searchShops(keyword, type, minRating, sort);

        request.setAttribute("shops",     shops);
        request.setAttribute("keyword",   keyword  != null ? keyword  : "");
        request.setAttribute("type",      type     != null ? type     : "");
        request.setAttribute("sort",      sort);
        request.setAttribute("minRating", minRating);
        request.setAttribute("totalShops", shops.size());

        request.getRequestDispatcher("shops.jsp").forward(request, response);
    }
}