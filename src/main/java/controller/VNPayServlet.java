package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import util.VNPayConfig;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/vnpay-payment")
public class VNPayServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr.trim());
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                resp.sendRedirect(req.getContextPath() + "/my-orders");
                return;
            }

            long amount = order.getTotalAmount().longValue() * 100; // VNPay tính bằng đơn vị đồng * 100

            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "other";
            String vnp_TxnRef = order.getOrderCode();
            String vnp_IpAddr = VNPayConfig.getIpAddress(req);
            String vnp_TmnCode = VNPayConfig.VNP_TMN_CODE;

            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            // vnp_OrderInfo bắt buộc Tiếng Việt không dấu, KHÔNG chứa ký tự đặc biệt như #, @, $
            vnp_Params.put("vnp_OrderInfo", "Thanh toan don hang KeebHub " + order.getOrderCode());
            vnp_Params.put("vnp_OrderType", orderType);
            vnp_Params.put("vnp_Locale", "vn");
            // vnp_IpAddr là trường BẮT BUỘC trong VNPay 2.1.0
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            // Xây dựng Return URL động theo máy chủ hiện hành
            String scheme = req.getScheme();
            String serverName = req.getServerName();
            int serverPort = req.getServerPort();
            String contextPath = req.getContextPath();
            String portStr = (("http".equals(scheme) && serverPort == 80) || ("https".equals(scheme) && serverPort == 443)) ? "" : ":" + serverPort;
            String returnUrl = scheme + "://" + serverName + portStr + contextPath + "/vnpay-return";
            vnp_Params.put("vnp_ReturnUrl", returnUrl);

            // Chuẩn hóa định dạng ngày giờ theo múi giờ Việt Nam GMT+7
            TimeZone tz = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");
            Calendar cld = Calendar.getInstance(tz);
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            formatter.setTimeZone(tz);
            String vnp_CreateDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

            cld.add(Calendar.MINUTE, 15);
            String vnp_ExpireDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            // Kiểm tra nếu người dùng chọn chế độ mô phỏng nhanh (Demo Simulation)
            String simulate = req.getParameter("simulate");
            if ("1".equals(simulate) || "true".equalsIgnoreCase(simulate)) {
                Map<String, String> returnParams = new HashMap<>();
                returnParams.put("vnp_Amount", String.valueOf(amount));
                returnParams.put("vnp_BankCode", "NCB");
                returnParams.put("vnp_BankTranNo", "VNP" + System.currentTimeMillis());
                returnParams.put("vnp_CardType", "ATM");
                returnParams.put("vnp_OrderInfo", "Thanh toan don hang KeebHub " + order.getOrderCode());
                returnParams.put("vnp_PayDate", vnp_CreateDate);
                returnParams.put("vnp_ResponseCode", "00");
                returnParams.put("vnp_TmnCode", vnp_TmnCode);
                returnParams.put("vnp_TransactionNo", String.valueOf(System.currentTimeMillis()));
                returnParams.put("vnp_TransactionStatus", "00");
                returnParams.put("vnp_TxnRef", vnp_TxnRef);

                List<String> simFieldNames = new ArrayList<>(returnParams.keySet());
                Collections.sort(simFieldNames);
                StringBuilder simHashData = new StringBuilder();
                StringBuilder simQuery = new StringBuilder();
                for (String fieldName : simFieldNames) {
                    String fieldValue = returnParams.get(fieldName);
                    if (fieldValue != null && !fieldValue.isEmpty()) {
                        if (simHashData.length() > 0) {
                            simHashData.append('&');
                            simQuery.append('&');
                        }
                        simHashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                        simQuery.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()))
                                .append('=')
                                .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    }
                }
                String simSecureHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, simHashData.toString());
                simQuery.append("&vnp_SecureHash=").append(simSecureHash);
                resp.sendRedirect(req.getContextPath() + "/vnpay-return?" + simQuery.toString());
                return;
            }

            // Sắp xếp tham số theo alphabet và băm checksum theo chuẩn VNPay
            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();

            for (String fieldName : fieldNames) {
                String fieldValue = vnp_Params.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    if (hashData.length() > 0) {
                        hashData.append('&');
                        query.append('&');
                    }
                    hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()))
                            .append('=')
                            .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                }
            }

            String queryUrl = query.toString();
            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.VNP_PAY_URL + "?" + queryUrl;

            resp.sendRedirect(paymentUrl);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/checkout?error=Loi_tao_giao_dich_vnpay");
        }
    }
}

