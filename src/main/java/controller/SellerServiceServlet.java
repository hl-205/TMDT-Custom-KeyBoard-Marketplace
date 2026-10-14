package controller;

import dao.CustomOrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/seller-services")
public class SellerServiceServlet extends HttpServlet {
    private final CustomOrderDAO customDAO = new CustomOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        request.setAttribute("services", customDAO.getAllServicesByShop(2)); // Shop 2: SwitchHouse
        request.getRequestDispatcher("seller-services.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String formType = request.getParameter("formType");

        if ("capacity".equals(formType)) {
            HttpSession session = request.getSession();
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
            customDAO.addServicePackage(2, serviceName, price, durationText, description, isPopular);
        }
        response.sendRedirect("seller-services?msg=saved");
    }
}