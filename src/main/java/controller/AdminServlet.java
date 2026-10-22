package controller;

import com.google.gson.Gson;
import dao.AdminDAO;
import dao.OrderHistoryDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private final AdminDAO dao = new AdminDAO();
    private final OrderHistoryDAO historyDAO = new OrderHistoryDAO();
    private final Gson gson = new Gson();

    private static final List<String> ROLES = Arrays.asList("CUSTOMER", "USER", "SELLER", "ADMIN", "MODERATOR");
    private static final List<String> USER_STATUS = Arrays.asList("ACTIVE", "INACTIVE", "BLOCKED");
    private static final List<String> ORDER_STATUS = Arrays.asList("PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "SHIPPED", "COMPLETED", "CANCELLED");
    private static final List<String> PRODUCT_STATUS = Arrays.asList("ACTIVE", "INACTIVE");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private static final long MAX_MONEY = 999_999_999_999L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        if (!isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ tài khoản ADMIN mới được truy cập trang này.");
            return;
        }

        try {
            var users = dao.getUsers();
            var orders = dao.getOrders();
            var products = dao.getProducts();
            var shops = dao.getShops();
            var categories = dao.getCategories();
            var stats = dao.getStats();
            var revenueStats = dao.getRevenueStats(null, null);

            req.setAttribute("usersJson", gson.toJson(users));
            req.setAttribute("ordersJson", gson.toJson(orders));
            req.setAttribute("productsJson", gson.toJson(products));
            req.setAttribute("shopsJson", gson.toJson(shops));
            req.setAttribute("categoriesJson", gson.toJson(categories));
            req.setAttribute("statsJson", gson.toJson(stats));
            req.setAttribute("revenueStatsJson", gson.toJson(revenueStats));
            req.getRequestDispatcher("/admin.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Lỗi tải dữ liệu admin", e);
            throw new ServletException("Không thể tải dữ liệu quản trị. Hãy kiểm tra kết nối CSDL MySQL.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");

        if (!isAdmin(req)) {
            sendJson(resp, false, "Phiên đăng nhập không có quyền ADMIN hoặc đã hết hạn.", 0, null, null);
            return;
        }

        String action = trim(req.getParameter("action"));
        int id = parseInt(req.getParameter("id"));
        try {
            switch (action) {
                case "saveUser" -> {
                    String firstName = required(req, "first_name", "Họ");
                    String lastName = required(req, "last_name", "Tên");
                    String email = required(req, "email", "Email").toLowerCase();
                    String password = trim(req.getParameter("password"));
                    String role = oneOf(req.getParameter("role"), ROLES, "Vai trò");
                    String status = oneOf(req.getParameter("status"), USER_STATUS, "Trạng thái");

                    if (!EMAIL_PATTERN.matcher(email).matches()) throw new IllegalArgumentException("Email không đúng định dạng.");
                    if (id <= 0 && password.isBlank()) throw new IllegalArgumentException("Vui lòng nhập mật khẩu cho tài khoản mới.");
                    if (!password.isBlank() && password.length() < 6) throw new IllegalArgumentException("Mật khẩu phải có ít nhất 6 ký tự.");
                    if (password.length() > 255) throw new IllegalArgumentException("Mật khẩu quá dài.");
                    if (id > 0 && id == currentUserId(req) && (!"ADMIN".equals(role) || !"ACTIVE".equals(status))) {
                        throw new IllegalArgumentException("Không thể hạ quyền hoặc khóa tài khoản admin đang đăng nhập.");
                    }

                    int savedId = dao.saveUser(id, firstName, lastName, email, password, role, status);
                    sendJson(resp, true, "Đã lưu người dùng thành công.", savedId, dao.getStats(), null);
                }
                case "deleteUser" -> {
                    if (id <= 0) throw new IllegalArgumentException("Thiếu ID người dùng cần xóa.");
                    if (id == currentUserId(req)) throw new IllegalArgumentException("Bạn không thể xóa tài khoản đang đăng nhập.");
                    dao.deleteUser(id);
                    sendJson(resp, true, "Đã xóa người dùng và các dữ liệu liên quan thành công.", id, dao.getStats(), null);
                }
                case "saveProduct" -> {
                    String name = required(req, "name", "Tên sản phẩm");
                    String sku = required(req, "sku", "SKU");
                    if (name.length() > 255) throw new IllegalArgumentException("Tên sản phẩm tối đa 255 ký tự.");
                    if (sku.length() > 100) throw new IllegalArgumentException("Mã SKU tối đa 100 ký tự.");
                    int shopId = positiveInt(req.getParameter("shop_id"), "Cửa hàng");
                    int categoryId = positiveInt(req.getParameter("category_id"), "Danh mục");
                    String status = oneOf(req.getParameter("status"), PRODUCT_STATUS, "Trạng thái");
                    long price = nonNegativeLong(req.getParameter("price"), "Giá bán");
                    if (price > MAX_MONEY) throw new IllegalArgumentException("Giá bán vượt giới hạn cho phép.");
                    long stockValue = nonNegativeLong(req.getParameter("stock"), "Tồn kho");
                    if (stockValue > Integer.MAX_VALUE) throw new IllegalArgumentException("Số lượng tồn kho quá lớn.");

                    int savedId = dao.saveProduct(id, name, sku, shopId, categoryId, price, (int) stockValue, status);
                    sendJson(resp, true, "Đã lưu sản phẩm thành công.", savedId, dao.getStats(), null);
                }
                case "deleteProduct" -> {
                    if (id <= 0) throw new IllegalArgumentException("Thiếu ID sản phẩm cần xóa.");
                    boolean hardDeleted = dao.deleteProduct(id);
                    Map<String, Object> extra = new LinkedHashMap<>();
                    extra.put("hardDeleted", hardDeleted);
                    String message = hardDeleted
                            ? "Đã xóa hoàn toàn sản phẩm khỏi hệ thống."
                            : "Sản phẩm đã có đơn hàng nên được chuyển sang trạng thái ngừng bán để bảo toàn lịch sử mua hàng.";
                    sendJson(resp, true, message, id, dao.getStats(), extra);
                }
                case "saveOrder" -> {
                    String receiver = required(req, "receiver_name", "Tên người nhận");
                    String email = required(req, "customer_email", "Email khách hàng").toLowerCase();
                    String phone = required(req, "receiver_phone", "Số điện thoại người nhận");
                    String address = required(req, "shipping_address", "Địa chỉ giao hàng");
                    String status = id > 0 ? "PENDING" : "PENDING"; // Đơn mới mặc định chờ xác nhận; chỉ tab trạng thái được đổi trạng thái.
                    String orderCode = trim(req.getParameter("order_code"));

                    if (!EMAIL_PATTERN.matcher(email).matches()) throw new IllegalArgumentException("Email khách hàng không đúng định dạng.");
                    if (orderCode.length() > 30) throw new IllegalArgumentException("Mã đơn hàng tối đa 30 ký tự.");

                    int productId = parseInt(req.getParameter("product_id"));
                    int quantity = req.getParameter("quantity") == null || req.getParameter("quantity").isBlank()
                            ? 1 : positiveInt(req.getParameter("quantity"), "Số lượng");

                    Map<String, Object> orderResult = dao.saveOrder(id, orderCode, receiver, email, phone, address, productId, quantity, status);
                    int savedId = (int) orderResult.get("id");
                    Map<String, Object> extra = new LinkedHashMap<>();
                    if (orderResult.containsKey("orderCode")) {
                        extra.put("orderCode", orderResult.get("orderCode"));
                    }
                    if (orderResult.containsKey("totalAmount")) {
                        extra.put("totalAmount", orderResult.get("totalAmount"));
                    }
                    sendJson(resp, true, id > 0 ? "Đã cập nhật đơn hàng thành công." : "Đã tạo đơn hàng mới thành công.",
                            savedId, dao.getStats(), extra);
                }
                case "updateOrderStatus" -> {
                    if (id <= 0) throw new IllegalArgumentException("Thiếu ID đơn hàng.");
                    String status = oneOf(req.getParameter("status"), ORDER_STATUS, "Trạng thái");
                    if (!historyDAO.changeStatus(id, currentUserId(req), "ADMIN", status)) {
                        throw new IllegalArgumentException("Không thể chuyển trạng thái này. Hãy tải lại danh sách và kiểm tra trạng thái hiện tại.");
                    }
                    sendJson(resp, true, "Đã cập nhật trạng thái đơn hàng.", id, dao.getStats(), null);
                }
                case "deleteOrder" -> {
                    if (id <= 0) throw new IllegalArgumentException("Thiếu ID đơn hàng cần xóa.");
                    dao.deleteOrder(id);
                    sendJson(resp, true, "Đã xóa đơn hàng và các chi tiết liên quan.", id, dao.getStats(), null);
                }
                case "getRevenueStats" -> {
                    String fromDate = trim(req.getParameter("from_date"));
                    String toDate = trim(req.getParameter("to_date"));
                    var revStats = dao.getRevenueStats(fromDate, toDate);
                    sendJson(resp, true, "Tải thống kê doanh thu thành công.", 0, null, revStats);
                }
                default -> sendJson(resp, false, "Thao tác không hợp lệ.", 0, null, null);
            }
        } catch (IllegalArgumentException e) {
            sendJson(resp, false, e.getMessage(), 0, null, null);
        } catch (SQLException e) {
            sendJson(resp, false, friendlyError(e), 0, null, null);
        } catch (Exception e) {
            getServletContext().log("Admin operation failed", e);
            sendJson(resp, false, "Có lỗi hệ thống khi xử lý yêu cầu. Báo cáo quản trị viên hệ thống.", 0, null, null);
        }
    }

    private String friendlyError(SQLException e) {
        String message = e.getMessage() == null ? "Lỗi cơ sở dữ liệu." : e.getMessage();
        String lower = message.toLowerCase();
        if (lower.contains("duplicate entry")) return "Dữ liệu bị trùng: Email, mã đơn hàng hoặc mã SKU đã tồn tại.";
        if (lower.contains("foreign key constraint") || lower.contains("foreign key fails")) return "Không thể xóa/cập nhật vì bản ghi đang được dữ liệu khác liên kết sử dụng.";
        if (lower.contains("communications link failure") || lower.contains("connection refused")) return "Không kết nối được MySQL. Hãy kiểm tra dịch vụ MySQL.";
        return message;
    }

    private void sendJson(HttpServletResponse resp, boolean success, String message, int id,
                          Map<String, Object> stats, Map<String, Object> extra) throws IOException {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("success", success);
        body.put("message", message);
        body.put("id", id);
        if (stats != null) body.put("stats", stats);
        if (extra != null) body.putAll(extra);
        resp.getWriter().write(gson.toJson(body));
    }

    private static String required(HttpServletRequest req, String param, String label) {
        String value = trim(req.getParameter(param));
        if (value.isEmpty()) throw new IllegalArgumentException(label + " không được để trống.");
        return value;
    }

    private static String oneOf(String value, List<String> allowed, String label) {
        String normalized = trim(value).toUpperCase();
        if (!allowed.contains(normalized)) throw new IllegalArgumentException(label + " không hợp lệ.");
        return normalized;
    }

    private static long nonNegativeLong(String value, String label) {
        try {
            long number = Long.parseLong(trim(value));
            if (number < 0) throw new IllegalArgumentException(label + " không được âm.");
            return number;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(label + " phải là số nguyên.");
        }
    }

    private static int positiveInt(String value, String label) {
        int number = parseInt(value);
        if (number <= 0) throw new IllegalArgumentException(label + " phải lớn hơn 0.");
        return number;
    }

    private static String trim(String value) { return value == null ? "" : value.trim(); }

    private static int parseInt(String value) {
        try { return value == null || value.isBlank() ? 0 : Integer.parseInt(value.trim()); }
        catch (NumberFormatException e) { return 0; }
    }

    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") instanceof User user) return user.getId();
        return -1;
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User user)) return false;
        return "ADMIN".equalsIgnoreCase(user.getRole());
    }
}