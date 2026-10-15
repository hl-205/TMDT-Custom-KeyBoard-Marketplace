package controller;

import dao.AdminDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền Admin
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ ADMIN mới được truy cập.");
            return;
        }

        // 2. Lấy dữ liệu và chuyển tiếp hướng tới admin.jsp
        try {
            req.setAttribute("users", dao.getUsers());
            req.setAttribute("orders", dao.getOrders());
            req.setAttribute("products", dao.getProducts());
            req.setAttribute("stats", dao.getStats());

            req.getRequestDispatcher("/admin.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Không tải được dữ liệu quản trị", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra quyền Admin
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ ADMIN mới được thao tác.");
            return;
        }

        // 2. Xử lý các thao tác cập nhật/xóa
        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                int id = Integer.parseInt(idParam);
                String status = req.getParameter("status");

                if ("userStatus".equals(action)) {
                    dao.updateUserStatus(id, status);
                } else if ("orderStatus".equals(action)) {
                    dao.updateOrderStatus(id, status);
                } else if ("productStatus".equals(action)) {
                    dao.updateProductStatus(id, status);
                } else if ("deleteProduct".equals(action)) {
                    dao.deleteProduct(id);
                }
            }

            resp.sendRedirect(req.getContextPath() + "/admin");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Không cập nhật được dữ liệu quản trị", e);
        }
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        Object obj = session.getAttribute("user");
        if (obj instanceof User) {
            User user = (User) obj;
            return user.getRole() != null && "ADMIN".equalsIgnoreCase(user.getRole());
        }
        return false;
    }
}