package controller;

import dao.ProductDAO;
import dao.ShopDAO;
import model.Product;
import model.Shop;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/shop")
public class ShopServlet extends HttpServlet {
    private final ShopDAO shopDAO = new ShopDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private static final int PAGE_SIZE = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int shopId = 1;
        try {
            if (request.getParameter("id") != null) {
                shopId = Integer.parseInt(request.getParameter("id"));
            }
        } catch (NumberFormatException ignored) {}

        Integer catId = null;
        try {
            if (request.getParameter("cat") != null && !request.getParameter("cat").isEmpty()) {
                catId = Integer.parseInt(request.getParameter("cat"));
            }
        } catch (NumberFormatException ignored) {}

        String sort = request.getParameter("sort");
        if (sort == null || sort.isEmpty()) sort = "popular";

        Shop shop = shopDAO.getShopById(shopId);
        if (shop == null) {
            shop = shopDAO.getShopById(1);
            shopId = 1;
        }

        List<Product> allShopProducts = productDAO.getProductsByShop(shopId, catId, sort);
        int totalProducts = allShopProducts.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalProducts / PAGE_SIZE));

        int currentPage = 1;
        try {
            if (request.getParameter("page") != null) {
                currentPage = Integer.parseInt(request.getParameter("page"));
            }
        } catch (NumberFormatException ignored) {}
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int fromIndex = (currentPage - 1) * PAGE_SIZE;
        int toIndex = Math.min(fromIndex + PAGE_SIZE, totalProducts);
        List<Product> pagedShopProducts = (totalProducts > 0)
                ? allShopProducts.subList(fromIndex, toIndex)
                : new ArrayList<>();

        request.setAttribute("shop", shop);
        request.setAttribute("services", shopDAO.getServicesByShopId(shopId));
        request.setAttribute("shopProducts", pagedShopProducts);
        request.setAttribute("totalShopProducts", totalProducts);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("selectedCat", catId);
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("shop.jsp").forward(request, response);
    }
}