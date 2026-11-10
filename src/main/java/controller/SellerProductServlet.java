package controller;

import dao.CustomOrderDAO;
import dao.CustomOrderDAO.SellerProductItem;
import dao.ShopDAO;
import model.Shop;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/seller-products")
public class SellerProductServlet extends HttpServlet {
    private final CustomOrderDAO customDAO = new CustomOrderDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login");
            return;
        }

        Shop sellerShop = shopDAO.getShopByOwnerId(currentUser.getId());
        int shopId = (sellerShop != null) ? sellerShop.getId() : 2;

        String action = request.getParameter("action");
        if ("toggle".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                customDAO.toggleSellerProductStatus(id, shopId);
            } catch (Exception ignored) {}
            response.sendRedirect("seller-products?msg=toggled");
            return;
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                customDAO.deleteSellerProduct(id, shopId);
            } catch (Exception ignored) {}
            response.sendRedirect("seller-products?msg=deleted");
            return;
        }

        String statusFilter = request.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "ALL";

        List<SellerProductItem> products = customDAO.getSellerProductsByShop(shopId, statusFilter);

        int allCount = customDAO.countSellerProductsByStatus(shopId, "ALL");
        int activeCount = customDAO.countSellerProductsByStatus(shopId, "ACTIVE");
        int pendingModCount = customDAO.countSellerProductsByStatus(shopId, "PENDING");
        int needsEditCount = customDAO.countSellerProductsByStatus(shopId, "NEEDS_EDIT")
                + customDAO.countSellerProductsByStatus(shopId, "REJECTED");
        int inactiveCount = customDAO.countSellerProductsByStatus(shopId, "INACTIVE");

        request.setAttribute("sellerShop", sellerShop);
        request.setAttribute("products", products);
        request.setAttribute("selectedStatus", statusFilter);
        request.setAttribute("allProductsCount", allCount);
        request.setAttribute("activeProductsCount", activeCount);
        request.setAttribute("pendingModCount", pendingModCount);
        request.setAttribute("needsEditCount", needsEditCount);
        request.setAttribute("inactiveProductsCount", inactiveCount);

        request.setAttribute("totalOrdersCount", customDAO.countOrdersByShopAndStatus(shopId, "ALL", false));
        request.setAttribute("pendingCount", customDAO.countOrdersByShopAndStatus(shopId, "PENDING", false));
        request.setAttribute("pendingCustomCount", customDAO.countOrdersByShopAndStatus(shopId, "PENDING", true));
        request.setAttribute("processingCustomCount", customDAO.countOrdersByShopAndStatus(shopId, "PROCESSING", true));

        request.getRequestDispatcher("seller-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login");
            return;
        }

        Shop sellerShop = shopDAO.getShopByOwnerId(currentUser.getId());
        int shopId = (sellerShop != null) ? sellerShop.getId() : 2;

        int productId = parseIntSafe(request.getParameter("productId"), 0);
        int categoryId = parseIntSafe(request.getParameter("categoryId"), 1);
        String sku = request.getParameter("sku");
        String name = request.getParameter("name");
        String brand = request.getParameter("brand");
        long price = parseLongSafe(request.getParameter("price"), 500000L);
        long oldPrice = parseLongSafe(request.getParameter("oldPrice"), 0L);
        int stock = parseIntSafe(request.getParameter("stock"), 20);
        boolean supportCustom = "on".equals(request.getParameter("supportCustom"));

        String layout = request.getParameter("layout");
        String mountType = request.getParameter("mountType");
        String pinType = request.getParameter("pinType");
        String switchType = request.getParameter("switchType");
        String actuationForce = request.getParameter("actuationForce");
        String shortDesc = request.getParameter("shortDesc");
        String description = request.getParameter("description");
        String specsText = request.getParameter("specsText");
        String compatText = request.getParameter("compatText");

        if (sku == null || sku.isBlank()) sku = "KH-SP-" + (System.currentTimeMillis() % 10000);
        if (name == null || name.isBlank()) name = "Sản phẩm mới từ " + (sellerShop != null ? sellerShop.getShopName() : "Xưởng");
        if (brand == null || brand.isBlank()) brand = (sellerShop != null) ? sellerShop.getShopName() : "KeebHub";

        customDAO.saveSellerProduct(
                productId, shopId, categoryId, sku, name, brand,
                price, oldPrice, stock, supportCustom,
                layout, mountType, pinType, switchType, actuationForce,
                shortDesc, description, specsText, compatText
        );

        response.sendRedirect("seller-products?msg=submitted_for_moderation");
    }

    private int parseIntSafe(String val, int def) {
        if (val == null || val.isBlank()) return def;
        try { return Integer.parseInt(val.replaceAll("[^0-9]", "")); }
        catch (Exception e) { return def; }
    }

    private long parseLongSafe(String val, long def) {
        if (val == null || val.isBlank()) return def;
        try { return Long.parseLong(val.replaceAll("[^0-9]", "")); }
        catch (Exception e) { return def; }
    }
}