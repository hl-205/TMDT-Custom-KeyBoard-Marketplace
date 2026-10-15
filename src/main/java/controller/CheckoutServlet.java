package controller;

import dao.OrderDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.*;
import model.CartItem;
import model.User;
import java.io.IOException;
import java.util.*;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) req.getSession().getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.setAttribute("cartItems", cart.values());
        req.getRequestDispatcher("checkout.jsp").forward(req, resp);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "login.jsp");
            return;
        }

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String name = req.getParameter("receiverName");
        String phone = req.getParameter("receiverPhone");
        String address = req.getParameter("shippingAddress");

        if (isBlank(name) || isBlank(phone) || isBlank(address)) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin giao hàng.");
            doGet(req, resp);
            return;
        }

        try {
            int id = new OrderDAO().createOrder(
                    user.getId(),
                    name.trim(),
                    phone.trim(),
                    address.trim(),
                    new ArrayList<>(cart.values())
            );
            cart.clear();
            resp.sendRedirect(req.getContextPath() + "/orders?success=1&orderId=" + id);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}