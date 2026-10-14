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

@WebServlet("/shop")
public class ShopServlet extends HttpServlet {
    private final ShopDAO shopDAO = new ShopDAO();
    private final ProductDAO productDAO = new ProductDAO();

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

        // Chỉ lấy đúng sản phẩm thuộc shopId này trong CSDL, tuyệt đối không lấy trộn từ shop khác
        List<Product> shopProducts = productDAO.getProductsByShop(shopId, catId, sort);

        request.setAttribute("shop", shop);
        request.setAttribute("services", shopDAO.getServicesByShopId(shopId));
        request.setAttribute("shopProducts", shopProducts);
        request.setAttribute("selectedCat", catId);
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("shop.jsp").forward(request, response);
    }
}