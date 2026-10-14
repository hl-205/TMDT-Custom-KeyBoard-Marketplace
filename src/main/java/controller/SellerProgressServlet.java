package controller;

import dao.CustomOrderDAO;
import dao.CustomOrderDAO.CustomOrder;
import dao.CustomOrderDAO.ProgressStep;
import dao.ShopDAO;
import model.Shop;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/seller-progress", "/order-detail"})
public class SellerProgressServlet extends HttpServlet {
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
        request.setAttribute("sellerShop", sellerShop);
        request.setAttribute("totalOrdersCount", customDAO.countOrdersByStatus("ALL", false));
        request.setAttribute("pendingCustomCount", customDAO.countOrdersByStatus("PENDING", true));
        request.setAttribute("processingCustomCount", customDAO.countOrdersByStatus("PROCESSING", true));

        String path = request.getServletPath();
        CustomOrder order = null;

        String idParam = request.getParameter("id");
        String codeParam = request.getParameter("code");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                order = customDAO.getOrderById(Integer.parseInt(idParam));
            } catch (Exception ignored) {}
        } else if (codeParam != null && !codeParam.isEmpty()) {
            order = customDAO.getOrderByCode(codeParam);
        }

        if (order == null) {
            order = customDAO.getOrderByCode("KH-284193");
        }

        List<ProgressStep> steps = customDAO.getProgressSteps(order.getId());
        List<CustomOrder> workshopQueue = customDAO.getOrdersForSeller("PROCESSING", true);

        request.setAttribute("order", order);
        request.setAttribute("steps", steps);
        request.setAttribute("workshopQueue", workshopQueue);

        if ("/order-detail".equals(path)) {
            request.getRequestDispatcher("order-detail.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("seller-progress.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        int stepNumber = Integer.parseInt(request.getParameter("stepNumber"));
        String stepDesc = request.getParameter("stepDesc");
        String submitAction = request.getParameter("submitAction");

        if (stepDesc == null || stepDesc.isBlank()) {
            stepDesc = "Đã hoàn thành công đoạn và kiểm tra kỹ thuật đạt chuẩn.";
        }

        boolean markCompleted = !"draft".equals(submitAction);
        customDAO.updateProgressStep(orderId, stepNumber, stepDesc, markCompleted);

        response.sendRedirect("seller-progress?id=" + orderId + "&msg=" + (markCompleted ? "completed" : "draft"));
    }
}