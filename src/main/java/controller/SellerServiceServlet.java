package controller;

import dao.CustomOrderDAO;
import dao.CustomOrderDAO.ServicePackage;
import dao.ShopDAO;
import model.Shop;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/seller-services")
public class SellerServiceServlet extends HttpServlet {
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
                customDAO.toggleServiceStatus(id);
            } catch (Exception ignored) {}
            response.sendRedirect("seller-services?msg=updated");
            return;
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                customDAO.deleteServicePackage(id);
            } catch (Exception ignored) {}
            response.sendRedirect("seller-services?msg=deleted");
            return;
        }

        List<ServicePackage> services = customDAO.getAllServicesByShop(shopId);
        int totalSoldMonth = 0;
        long totalCustomRevenue = 0;
        int activePkgCount = 0;
        for (ServicePackage sp : services) {
            totalSoldMonth += sp.getSoldMonth();
            totalCustomRevenue += (sp.getPrice() * sp.getSoldMonth());
            if ("ACTIVE".equals(sp.getStatus())) activePkgCount++;
        }

        request.setAttribute("sellerShop", sellerShop);
        request.setAttribute("services", services);
        request.setAttribute("totalSoldMonth", totalSoldMonth);
        request.setAttribute("formattedCustomRevenue", CustomOrderDAO.formatVND(totalCustomRevenue));
        request.setAttribute("activePkgCount", activePkgCount);
        request.setAttribute("totalOrdersCount", customDAO.countOrdersByStatus("ALL", false));
        request.setAttribute("pendingCustomCount", customDAO.countOrdersByStatus("PENDING", true));
        request.setAttribute("processingCustomCount", customDAO.countOrdersByStatus("PROCESSING", true));

        request.getRequestDispatcher("seller-services.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login");
            return;
        }
        Shop sellerShop = shopDAO.getShopByOwnerId(currentUser.getId());
        int shopId = (sellerShop != null) ? sellerShop.getId() : 2;

        String formType = request.getParameter("formType");
        if ("capacity".equals(formType)) {
            session.setAttribute("cap_maxOrders", request.getParameter("maxOrders"));
            session.setAttribute("cap_staffCount", request.getParameter("staffCount"));
            session.setAttribute("cap_workHours", request.getParameter("workHours"));
            response.sendRedirect("seller-services?msg=capacity_saved");
            return;
        }

        String idParam = request.getParameter("serviceId");
        String serviceName = request.getParameter("serviceName");
        String priceStr = request.getParameter("price");
        String durationText = request.getParameter("durationText");
        String description = request.getParameter("description");
        boolean isPopular = "on".equals(request.getParameter("isPopular"));

        long price = 450000;
        try {
            price = Long.parseLong(priceStr.replaceAll("[^0-9]", ""));
        } catch (Exception ignored) {}

        if (idParam != null && !idParam.isBlank()) {
            int id = Integer.parseInt(idParam);
            customDAO.updateServicePackage(id, serviceName, price, durationText, description, isPopular);
        } else {
            customDAO.addServicePackage(shopId, serviceName, price, durationText, description, isPopular);
        }
        response.sendRedirect("seller-services?msg=saved");
    }
}