package controller;

import dao.ShopDAO;
import model.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/shops", "/shops-search"})
public class ShopSearchServlet extends HttpServlet {
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        Boolean workshopOnly = "1".equals(request.getParameter("workshop"));
        Boolean verifiedOnly = "1".equals(request.getParameter("verified"));
        String sort = request.getParameter("sort");
        if (sort == null || sort.isEmpty()) {
            sort = "rating";
        }

        List<Shop> shops = shopDAO.searchShops(keyword, workshopOnly, verifiedOnly, sort);

        request.setAttribute("shops", shops);
        request.setAttribute("keyword", keyword);
        request.setAttribute("workshopOnly", workshopOnly);
        request.setAttribute("verifiedOnly", verifiedOnly);
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("shops.jsp").forward(request, response);
    }
}
