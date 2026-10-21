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

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

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
        Map<Integer, List<Shop.CustomServiceItem>> servicesMap = new LinkedHashMap<>();
        for (Shop ws : workshops) {
            servicesMap.put(ws.getId(), builderDAO.getServicesByShop(ws.getId()));
        }

        // Linh kiện được chọn (mặc định chọn Kit Tofu60 và Switch Oil King nếu chưa có để khớp Figma mockup)
        int defaultKit = (preKitId > 0) ? preKitId : 1;
        int selKit     = parseIntSafe(request.getParameter("selKit"),     defaultKit);
        int selSwitch  = parseIntSafe(request.getParameter("selSwitch"),  2); // Gateron Oil King
        int selKeycap  = parseIntSafe(request.getParameter("selKeycap"),  0);
        int selStab    = parseIntSafe(request.getParameter("selStab"),    6); // Durock V2
        int selService = parseIntSafe(request.getParameter("selService"), 0);

        // Áp dụng kiểm tra tương thích động cho switch, keycap, stabilizer dựa trên kit đã chọn
        BuilderProduct selectedKit = builderDAO.getProductById(selKit);
        if (selectedKit == null && !kits.isEmpty()) {
            selectedKit = kits.get(0);
            selKit = selectedKit.getId();
        }
        builderDAO.applyCompatibility(selectedKit, switches, keycaps, stabs);

        // Bước hiện tại (1: Kit, 2: Switch, 3: Keycap, 4: Gia công & Stab, 5: Xem lại & Đặt hàng)
        int step = parseIntSafe(request.getParameter("step"), (selKit > 0 ? 2 : 1));

        // Kiểm tra tương thích tổng thể
        List<CompatResult> compatResults = builderDAO.checkCompatibility(selKit, selSwitch, selKeycap, selStab);
        BuilderProduct selectedSwitch = builderDAO.getProductById(selSwitch);
        BuilderProduct selectedKeycap = selKeycap > 0 ? builderDAO.getProductById(selKeycap) : null;
        BuilderProduct selectedStab   = selStab > 0   ? builderDAO.getProductById(selStab)   : null;

        // Đặt attributes
        request.setAttribute("kits",           kits);
        request.setAttribute("switches",       switches);
        request.setAttribute("keycaps",        keycaps);
        request.setAttribute("stabs",          stabs);
        request.setAttribute("workshops",      workshops);
        request.setAttribute("servicesMap",    servicesMap);
        request.setAttribute("compatResults",  compatResults);
        request.setAttribute("preKitId",       preKitId);
        request.setAttribute("selKit",         selKit);
        request.setAttribute("selSwitch",      selSwitch);
        request.setAttribute("selKeycap",      selKeycap);
        request.setAttribute("selStab",        selStab);
        request.setAttribute("selService",     selService);
        request.setAttribute("selectedKit",    selectedKit);
        request.setAttribute("selectedSwitch", selectedSwitch);
        request.setAttribute("selectedKeycap", selectedKeycap);
        request.setAttribute("selectedStab",   selectedStab);
        request.setAttribute("currentStep",    step);

        request.getRequestDispatcher("custom-builder.jsp").forward(request, response);
    }

    // ──────────────────────────────────────────────
    // POST: Lưu nháp, Kiểm tra tương thích, hoặc Tạo đơn
    // ──────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        String action = request.getParameter("action");

        // ── A) Lưu nháp cấu hình ──
        if ("save-draft".equals(action)) {
            session.setAttribute("builderSuccess", "Đã lưu bản nháp cấu hình thành công vào phiên làm việc!");
            int k = parseIntSafe(request.getParameter("kitId"), 1);
            int s = parseIntSafe(request.getParameter("switchId"), 2);
            int kc = parseIntSafe(request.getParameter("keycapId"), 0);
            int st = parseIntSafe(request.getParameter("stabId"), 6);
            int svc = parseIntSafe(request.getParameter("serviceId"), 0);
            int step = parseIntSafe(request.getParameter("step"), 2);
            response.sendRedirect(String.format("custom-builder?selKit=%d&selSwitch=%d&selKeycap=%d&selStab=%d&selService=%d&step=%d", k, s, kc, st, svc, step));
            return;
        }

        // ── B) Kiểm tra tương thích (AJAX hoặc Redirect) ──
        if ("check-compat".equals(action)) {
            int kitId     = parseIntSafe(request.getParameter("kitId"),     1);
            int switchId  = parseIntSafe(request.getParameter("switchId"),  2);
            int keycapId  = parseIntSafe(request.getParameter("keycapId"),  0);
            int stabId    = parseIntSafe(request.getParameter("stabId"),    6);
            int serviceId = parseIntSafe(request.getParameter("serviceId"), 0);
            int step      = parseIntSafe(request.getParameter("step"),      2);

            List<CompatResult> results = builderDAO.checkCompatibility(kitId, switchId, keycapId, stabId);
            boolean isAllCompat = results.stream().allMatch(CompatResult::isCompatible);

            String isAjax = request.getHeader("X-Requested-With");
            String accept = request.getHeader("Accept");
            String format = request.getParameter("format");
            if ("XMLHttpRequest".equalsIgnoreCase(isAjax) || "json".equalsIgnoreCase(format)
                    || (accept != null && accept.contains("application/json"))) {
                response.setContentType("application/json;charset=UTF-8");
                Map<String, Object> json = new HashMap<>();
                json.put("success", true);
                json.put("allCompatible", isAllCompat);
                json.put("results", results);
                new com.google.gson.Gson().toJson(json, response.getWriter());
                return;
            }

            String redirectUrl = String.format(
                    "custom-builder?selKit=%d&selSwitch=%d&selKeycap=%d&selStab=%d&selService=%d&step=%d",
                    kitId, switchId, keycapId, stabId, serviceId, step);
            response.sendRedirect(redirectUrl);
            return;
        }

        // Kiểm tra đăng nhập trước khi đặt đơn
        if (currentUser == null) {
            response.sendRedirect("login?redirect=custom-builder");
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
