package controller;

import com.google.gson.Gson;
import dao.AdminDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();
    private final Gson gson = new Gson();

    private static final List<String> ROLES = Arrays.asList("CUSTOMER", "USER", "SELLER", "ADMIN", "MODERATOR");
    private static final List<String> USER_STATUS = Arrays.asList("ACTIVE", "INACTIVE", "BLOCKED");
    private static final List<String> ORDER_STATUS = Arrays.asList("PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "COMPLETED", "CANCELLED");
    private static final List<String> PRODUCT_STATUS = Arrays.asList("ACTIVE", "INACTIVE");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ ADMIN mới được truy cập.");
            return;
        }

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
        resp.setContentType("application/json; charset=UTF-8");

        if (!isAdmin(req)) {
            sendJson(resp, false, "Chỉ ADMIN mới có quyền thực hiện.", 0, null, null);
            return;
        }

        String action = req.getParameter("action");
        int id = parseInt(req.getParameter("id"));

        try {
            if ("saveUser".equals(action)) {
                String firstName = required(req, "first_name", "Họ");
                String lastName = required(req, "last_name", "Tên");
                String email = required(req, "email", "Email");
                String role = oneOf(req.getParameter("role"), ROLES, "Vai trò");
                String status = oneOf(req.getParameter("status"), USER_STATUS, "Trạng thái");
                if (id > 0 && id == currentUserId(req) && (!"ADMIN".equals(role) || !"ACTIVE".equals(status))) {
                    throw new IllegalArgumentException("Không thể hạ quyền hoặc khóa chính tài khoản admin đang đăng nhập.");
                }
                int savedId = dao.saveUser(id, firstName, lastName, email, req.getParameter("password"), role, status);
                sendJson(resp, true, "Đã lưu thông tin người dùng!", savedId, dao.getStats(), null);

            } else if ("deleteUser".equals(action)) {
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID người dùng cần xóa.");
                if (id == currentUserId(req)) throw new IllegalArgumentException("Bạn không thể tự xóa tài khoản đang đăng nhập.");
                dao.deleteUser(id);
                sendJson(resp, true, "Đã xóa người dùng thành công!", id, dao.getStats(), null);

            } else if ("saveOrder".equals(action)) {
                String receiver = required(req, "receiver_name", "Tên người nhận");
                String email = required(req, "customer_email", "Email khách hàng");
                String status = oneOf(req.getParameter("status"), ORDER_STATUS, "Trạng thái");
                long total = nonNegativeLong(req.getParameter("total_amount"), "Tổng tiền");
                String orderCode = trim(req.getParameter("order_code"));
                if (orderCode.isEmpty()) orderCode = "KH" + System.currentTimeMillis(); // trả về cho giao diện hiển thị
                int savedId = dao.saveOrder(id, orderCode, receiver, email, total, status);
                Map<String, Object> extra = new LinkedHashMap<>();
                extra.put("orderCode", orderCode);
                sendJson(resp, true, "Đã lưu đơn hàng thành công!", savedId, dao.getStats(), extra);

            } else if ("deleteOrder".equals(action)) {
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID đơn hàng cần xóa.");
                dao.deleteOrder(id);
                sendJson(resp, true, "Đã xóa đơn hàng thành công!", id, dao.getStats(), null);

            } else if ("saveProduct".equals(action)) {
                String name = required(req, "name", "Tên sản phẩm");
                String sku = required(req, "sku", "SKU");
                String shop = required(req, "shop_name", "Tên cửa hàng");
                String status = oneOf(req.getParameter("status"), PRODUCT_STATUS, "Trạng thái");
                long price = nonNegativeLong(req.getParameter("price"), "Giá bán");
                int stock = (int) Math.min(nonNegativeLong(req.getParameter("stock"), "Tồn kho"), Integer.MAX_VALUE);
                int savedId = dao.saveProduct(id, name, sku, shop, price, stock, status);
                sendJson(resp, true, "Đã lưu sản phẩm thành công!", savedId, dao.getStats(), null);

            } else if ("deleteProduct".equals(action)) {
                if (id <= 0) throw new IllegalArgumentException("Thiếu ID sản phẩm cần xóa.");
                dao.deleteProduct(id);
                sendJson(resp, true, "Đã xóa sản phẩm thành công!", id, dao.getStats(), null);

            } else {
                sendJson(resp, false, "Thao tác không hợp lệ!", 0, null, null);
            }
        } catch (IllegalArgumentException e) {
            sendJson(resp, false, e.getMessage(), 0, null, null);
        } catch (Exception e) {
            e.printStackTrace();
            sendJson(resp, false, friendlyError(e), 0, null, null);
        }
    }

    // Dịch lỗi SQL hay gặp sang tiếng Việt dễ hiểu
    private String friendlyError(Exception e) {
        String m = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
        if (m.contains("Duplicate entry")) return "Dữ liệu bị trùng (email / mã đơn / SKU đã tồn tại).";
        if (m.contains("foreign key constraint")) return "Không thể thực hiện vì còn dữ liệu khác đang liên kết.";
        return m;
    }

    private void sendJson(HttpServletResponse resp, boolean success, String message, int id,
                          Map<String, Object> stats, Map<String, Object> extra) throws IOException {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", success);
        body.put("message", message);
        body.put("id", id);
        if (stats != null) body.put("stats", stats);   // Gson tự xuất đúng cả roleStats / orderStatusStats
        if (extra != null) body.putAll(extra);
        resp.getWriter().write(gson.toJson(body));
    }

    private static String required(HttpServletRequest req, String param, String label) {
        String v = trim(req.getParameter(param));
        if (v.isEmpty()) throw new IllegalArgumentException(label + " không được để trống.");
        return v;
    }

    private static String oneOf(String v, List<String> allowed, String label) {
        String t = trim(v);
        if (!allowed.contains(t)) throw new IllegalArgumentException(label + " không hợp lệ.");
        return t;
    }

    private static long nonNegativeLong(String v, String label) {
        long n;
        try {
            n = Long.parseLong(trim(v));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(label + " phải là số nguyên.");
        }
        if (n < 0) throw new IllegalArgumentException(label + " không được âm.");
        return n;
    }

    private static String trim(String s) { return s == null ? "" : s.trim(); }

    private static int parseInt(String s) {
        try { return (s == null || s.trim().isEmpty()) ? 0 : Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") instanceof User) {
            return ((User) session.getAttribute("user")).getId();
        }
        return -1;
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
