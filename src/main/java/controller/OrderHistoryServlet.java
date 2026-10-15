package controller;

import dao.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import model.User;
import java.io.IOException;

@WebServlet("/orders")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "login.jsp");
            return;
        }

        try {
            req.setAttribute("orders", new OrderDAO().findByUser(user.getId()));
            req.getRequestDispatcher("order-history.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải được lịch sử đơn hàng.", e);
        }
    }
}