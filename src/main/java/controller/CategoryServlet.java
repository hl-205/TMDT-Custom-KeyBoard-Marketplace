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
import java.util.Arrays;
import java.util.List;

@WebServlet(urlPatterns = {"/category", "/search"})
public class CategoryServlet extends HttpServlet {
    private final ProductDAO productDAO = new ProductDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer catId = parseIntOrNull(request.getParameter("cat"));
        String keyword = request.getParameter("keyword");
        String[] brands = request.getParameterValues("brand");
        String[] switchTypes = request.getParameterValues("switchType");
        String[] forces = request.getParameterValues("force");
        String[] layouts = request.getParameterValues("layout");
        String[] mounts = request.getParameterValues("mount");
        Long minPrice = parseLongOrNull(request.getParameter("minPrice"));
        Long maxPrice = parseLongOrNull(request.getParameter("maxPrice"));
        Boolean inStock = "1".equals(request.getParameter("inStock"));
        Boolean supportCustom = "1".equals(request.getParameter("custom"));
        Double minRating = parseDoubleOrNull(request.getParameter("rating"));
        String sort = request.getParameter("sort");
        if (sort == null || sort.isEmpty()) sort = "popular";

        List<Product> products = productDAO.filterProducts(
                catId, keyword, brands, switchTypes, forces, layouts, mounts,
                minPrice, maxPrice, inStock, supportCustom, minRating, sort
        );

        List<Shop> matchedShops = null;
        if (keyword != null && !keyword.trim().isEmpty()) {
            matchedShops = shopDAO.searchShops(keyword, null, null, null);
        }

        // Tạo danh sách các tag "Đang lọc" hiển thị trên đầu trang (như Frame 04)
        List<String> activeTags = new ArrayList<>();
        if (brands != null) activeTags.addAll(Arrays.asList(brands));
        if (switchTypes != null) activeTags.addAll(Arrays.asList(switchTypes));
        if (forces != null) activeTags.addAll(Arrays.asList(forces));
        if (layouts != null) activeTags.addAll(Arrays.asList(layouts));
        if (mounts != null) activeTags.addAll(Arrays.asList(mounts));
        if (inStock) activeTags.add("Còn hàng");
        if (supportCustom) activeTags.add("Hỗ trợ gia công");
        if (minPrice != null || maxPrice != null) {
            activeTags.add("Giá: " + (minPrice != null ? minPrice / 1000 + "k" : "0") + " - " + (maxPrice != null ? maxPrice / 1000 + "k" : "Max"));
        }

        request.setAttribute("products", products);
        request.setAttribute("matchedShops", matchedShops);
        request.setAttribute("catId", catId);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedBrands", brands != null ? Arrays.asList(brands) : new ArrayList<>());
        request.setAttribute("selectedSwitchTypes", switchTypes != null ? Arrays.asList(switchTypes) : new ArrayList<>());
        request.setAttribute("selectedForces", forces != null ? Arrays.asList(forces) : new ArrayList<>());
        request.setAttribute("selectedLayouts", layouts != null ? Arrays.asList(layouts) : new ArrayList<>());
        request.setAttribute("selectedMounts", mounts != null ? Arrays.asList(mounts) : new ArrayList<>());
        request.setAttribute("minPrice", minPrice);
        request.setAttribute("maxPrice", maxPrice);
        request.setAttribute("inStock", inStock);
        request.setAttribute("supportCustom", supportCustom);
        request.setAttribute("minRating", minRating);
        request.setAttribute("sort", sort);
        request.setAttribute("activeTags", activeTags);

        request.getRequestDispatcher("category.jsp").forward(request, response);
    }

    private Integer parseIntOrNull(String val) {
        try { return (val != null && !val.isBlank()) ? Integer.parseInt(val.trim()) : null; }
        catch (Exception e) { return null; }
    }

    private Long parseLongOrNull(String val) {
        try { return (val != null && !val.isBlank()) ? Long.parseLong(val.trim().replaceAll("[^0-9]", "")) : null; }
        catch (Exception e) { return null; }
    }

    private Double parseDoubleOrNull(String val) {
        try { return (val != null && !val.isBlank()) ? Double.parseDouble(val.trim()) : null; }
        catch (Exception e) { return null; }
    }
}