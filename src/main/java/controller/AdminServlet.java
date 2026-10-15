package controller;

import dao.AdminDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ ADMIN mới được truy cập.");
            return;
        }
        try {
            req.setAttribute("users", dao.getUsers());
            req.setAttribute("orders", dao.getOrders());
            req.setAttribute("products", dao.getProducts());
            req.setAttribute("stats", dao.getStats());
            req.getRequestDispatcher("admin.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Không tải được dữ liệu quản trị", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ ADMIN mới được thao tác.");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {
            int id = Integer.parseInt(req.getParameter("id"));

            if ("userStatus".equals(action)) {
                dao.updateUserStatus(id, req.getParameter("status"));
            } else if ("orderStatus".equals(action)) {
                dao.updateOrderStatus(id, req.getParameter("status"));
            } else if ("productStatus".equals(action)) {
                dao.updateProductStatus(id, req.getParameter("status"));
            } else if ("deleteProduct".equals(action)) {
                dao.deleteProduct(id);
            }

            resp.sendRedirect(req.getContextPath() + "/admin");
        } catch (Exception e) {
            throw new ServletException("Không cập nhật được dữ liệu quản trị", e);
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        Object user = session.getAttribute("user");
        if (user == null) return false;

        try {
            return "ADMIN".equalsIgnoreCase((String) user.getClass().getMethod("getRole").invoke(user));
        } catch (Exception e) {
            return false;
        }
    }
}