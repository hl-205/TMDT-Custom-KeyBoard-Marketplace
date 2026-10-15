package controller;

import dao.CustomBuilderDAO;
import dao.CustomBuilderDAO.*;
import dao.ShopDAO;
import model.Shop;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Servlet cho chức năng Custom Builder của Customer.
 * GET  /custom-builder         → Hiển thị trang cấu hình build
 * POST /custom-builder?action=check-compat → Trả về kết quả tương thích (AJAX/redirect)
 * POST /custom-builder?action=place-order  → Tạo đơn custom và redirect my-orders
 */
@WebServlet("/custom-builder")
public class CustomBuilderServlet extends HttpServlet {

    private final CustomBuilderDAO builderDAO = new CustomBuilderDAO();
    private final ShopDAO shopDAO = new ShopDAO();

    // ──────────────────────────────────────────────
    // GET: Load trang Custom Builder
    // ──────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra đăng nhập
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login?redirect=custom-builder");
            return;
        }

        // Nếu vào từ product-detail thì pre-select kit
        int preKitId = 0;
        String kitIdParam = request.getParameter("kitId");
        if (kitIdParam != null) {
            try { preKitId = Integer.parseInt(kitIdParam); } catch (NumberFormatException ignored) {}
        }

        // Load tất cả sản phẩm theo từng nhóm
        List<BuilderProduct> kits       = builderDAO.getProductsByCategory(1); // Kit bàn phím
        List<BuilderProduct> switches   = builderDAO.getProductsByCategory(2); // Switch
        List<BuilderProduct> keycaps    = builderDAO.getProductsByCategory(3); // Keycap
        List<BuilderProduct> stabs      = builderDAO.getProductsByCategory(4); // Stabilizer

        // Load danh sách shop xưởng & gói dịch vụ
        List<Shop> workshops = builderDAO.getWorkshopShops();
        // Gom services của tất cả workshop vào map shopId -> list services
        Map<Integer, List<Shop.CustomServiceItem>> servicesMap = new LinkedHashMap<>();
        for (Shop ws : workshops) {
            servicesMap.put(ws.getId(), builderDAO.getServicesByShop(ws.getId()));
        }

        // Nếu user đã chọn linh kiện (từ query param), tính tương thích ngay
        int selKit    = parseIntSafe(request.getParameter("selKit"),    preKitId);
        int selSwitch = parseIntSafe(request.getParameter("selSwitch"), 0);
        int selKeycap = parseIntSafe(request.getParameter("selKeycap"), 0);
        int selStab   = parseIntSafe(request.getParameter("selStab"),   0);

        List<CompatResult> compatResults = null;
        if (selKit > 0 || selSwitch > 0) {
            compatResults = builderDAO.checkCompatibility(selKit, selSwitch, selKeycap, selStab);
        }

        // Đặt attributes
        request.setAttribute("kits",          kits);
        request.setAttribute("switches",      switches);
        request.setAttribute("keycaps",       keycaps);
        request.setAttribute("stabs",         stabs);
        request.setAttribute("workshops",     workshops);
        request.setAttribute("servicesMap",   servicesMap);
        request.setAttribute("compatResults", compatResults);
        request.setAttribute("preKitId",      preKitId);
        request.setAttribute("selKit",        selKit);
        request.setAttribute("selSwitch",     selSwitch);
        request.setAttribute("selKeycap",     selKeycap);
        request.setAttribute("selStab",       selStab);

        request.getRequestDispatcher("custom-builder.jsp").forward(request, response);
    }

    // ──────────────────────────────────────────────
    // POST: Kiểm tra tương thích hoặc Tạo đơn
    // ──────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login?redirect=custom-builder");
            return;
        }

        String action = request.getParameter("action");

        // ── A) Chỉ kiểm tra tương thích, redirect lại trang với kết quả ──
        if ("check-compat".equals(action)) {
            int kitId    = parseIntSafe(request.getParameter("kitId"),    0);
            int switchId = parseIntSafe(request.getParameter("switchId"), 0);
            int keycapId = parseIntSafe(request.getParameter("keycapId"), 0);
            int stabId   = parseIntSafe(request.getParameter("stabId"),   0);
            int serviceId = parseIntSafe(request.getParameter("serviceId"), 0);

            String redirectUrl = String.format(
                    "custom-builder?selKit=%d&selSwitch=%d&selKeycap=%d&selStab=%d&selService=%d",
                    kitId, switchId, keycapId, stabId, serviceId);
            response.sendRedirect(redirectUrl);
            return;
        }

        // ── B) Đặt đơn custom ──────────────────────────────────────────
        if ("place-order".equals(action)) {
            BuildConfig cfg = new BuildConfig();
            cfg.setKitId(parseIntSafe(request.getParameter("kitId"), 0));
            cfg.setSwitchId(parseIntSafe(request.getParameter("switchId"), 0));
            cfg.setKeycapId(parseIntSafe(request.getParameter("keycapId"), 0));
            cfg.setStabId(parseIntSafe(request.getParameter("stabId"), 0));
            cfg.setServiceId(parseIntSafe(request.getParameter("serviceId"), 0));
            cfg.setSwitchQty(parseIntSafe(request.getParameter("switchQty"), 70));
            cfg.setCustomNote(request.getParameter("customNote"));

            String receiverName    = request.getParameter("receiverName");
            String receiverPhone   = request.getParameter("receiverPhone");
            String shippingAddress = request.getParameter("shippingAddress");
            String paymentMethod   = request.getParameter("paymentMethod");

            // Tính subtotal từ giá các linh kiện
            long subtotal = 0;
            if (cfg.getKitId() > 0) {
                BuilderProduct kit = builderDAO.getProductById(cfg.getKitId());
                if (kit != null) subtotal += kit.getPrice();
            }
            if (cfg.getSwitchId() > 0) {
                BuilderProduct sw = builderDAO.getProductById(cfg.getSwitchId());
                if (sw != null) subtotal += sw.getPrice();
            }
            if (cfg.getKeycapId() > 0) {
                BuilderProduct kc = builderDAO.getProductById(cfg.getKeycapId());
                if (kc != null) subtotal += kc.getPrice();
            }
            if (cfg.getStabId() > 0) {
                BuilderProduct st = builderDAO.getProductById(cfg.getStabId());
                if (st != null) subtotal += st.getPrice();
            }

            // Lấy phí gia công từ service đã chọn
            long customFee = 0;
            if (cfg.getServiceId() > 0) {
                List<Shop.CustomServiceItem> allServices = new ArrayList<>();
                for (Shop ws : builderDAO.getWorkshopShops()) {
                    allServices.addAll(builderDAO.getServicesByShop(ws.getId()));
                }
                for (Shop.CustomServiceItem svc : allServices) {
                    if (svc.getId() == cfg.getServiceId()) {
                        customFee = svc.getPrice();
                        break;
                    }
                }
            }

            // Validate tối thiểu cần chọn kit
            if (cfg.getKitId() <= 0 || receiverName == null || receiverName.isBlank()
                    || receiverPhone == null || receiverPhone.isBlank()
                    || shippingAddress == null || shippingAddress.isBlank()) {
                session.setAttribute("builderError", "Vui lòng chọn ít nhất Kit bàn phím và điền đầy đủ thông tin giao hàng.");
                response.sendRedirect("custom-builder");
                return;
            }

            String orderCode = builderDAO.createCustomOrder(
                    currentUser.getId(), cfg,
                    receiverName.trim(), receiverPhone.trim(),
                    shippingAddress.trim(),
                    paymentMethod != null ? paymentMethod : "VNPAY",
                    subtotal, customFee
            );

            if (orderCode != null) {
                session.setAttribute("builderSuccess",
                        "Đặt đơn custom thành công! Mã đơn: " + orderCode + ". Shop sẽ xác nhận trong 24h.");
                response.sendRedirect("my-orders");
            } else {
                session.setAttribute("builderError", "Có lỗi khi tạo đơn. Vui lòng thử lại.");
                response.sendRedirect("custom-builder");
            }
            return;
        }

        // Fallback
        response.sendRedirect("custom-builder");
    }

    private int parseIntSafe(String val, int defaultVal) {
        if (val == null || val.isBlank()) return defaultVal;
        try { return Integer.parseInt(val.trim()); }
        catch (NumberFormatException e) { return defaultVal; }
    }
}
