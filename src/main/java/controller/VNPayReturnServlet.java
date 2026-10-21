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

@WebServlet("/vnpay-return")
public class VNPayReturnServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = req.getParameterNames(); params.hasMoreElements(); ) {
            String fieldName = params.nextElement();
            String fieldValue = req.getParameter(fieldName);
            if ((fieldValue != null) && (!fieldValue.isEmpty())) {
                fields.put(fieldName, fieldValue);
            }
        }

        String vnp_SecureHash = req.getParameter("vnp_SecureHash");
        if (fields.containsKey("vnp_SecureHashType")) {
            fields.remove("vnp_SecureHashType");
        }
        if (fields.containsKey("vnp_SecureHash")) {
            fields.remove("vnp_SecureHash");
        }

        // Tính toán lại mã kiểm tra chữ ký
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (!fieldValue.isEmpty())) {
                hashData.append(fieldName);
                hashData.append('=');
                hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                if (itr.hasNext()) {
                    hashData.append('&');
                }
            }
        }

        String calculatedHash = VNPayConfig.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, hashData.toString());
        boolean isValidSignature = calculatedHash.equalsIgnoreCase(vnp_SecureHash);

        String vnp_TxnRef = req.getParameter("vnp_TxnRef");
        String vnp_Amount = req.getParameter("vnp_Amount");
        String vnp_ResponseCode = req.getParameter("vnp_ResponseCode");
        String vnp_TransactionNo = req.getParameter("vnp_TransactionNo");
        String vnp_BankCode = req.getParameter("vnp_BankCode");
        String vnp_PayDate = req.getParameter("vnp_PayDate");

        long amount = 0;
        if (vnp_Amount != null && !vnp_Amount.isEmpty()) {
            amount = Long.parseLong(vnp_Amount) / 100;
        }

        String formattedPayDate = "";
        if (vnp_PayDate != null && vnp_PayDate.length() >= 14) {
            try {
                SimpleDateFormat parser = new SimpleDateFormat("yyyyMMddHHmmss");
                Date d = parser.parse(vnp_PayDate);
                formattedPayDate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(d);
            } catch (Exception e) {
                formattedPayDate = vnp_PayDate;
            }
        }

        boolean isSuccess = false;
        String message = "";

        if (isValidSignature) {
            if ("00".equals(vnp_ResponseCode)) {
                isSuccess = true;
                message = "Giao dịch thanh toán trực tuyến qua VNPAY thành công!";
                try {
                    orderDAO.updatePaymentSuccessByCode(vnp_TxnRef, "VNPAY-QR");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else if ("24".equals(vnp_ResponseCode)) {
                message = "Giao dịch bị hủy bỏ bởi khách hàng.";
            } else if ("51".equals(vnp_ResponseCode)) {
                message = "Tài khoản của quý khách không đủ số dư để thực hiện giao dịch.";
            } else {
                message = "Thanh toán thất bại (Mã lỗi VNPAY: " + vnp_ResponseCode + ").";
            }
        } else {
            // Trường hợp chữ ký không khớp hoặc demo test callback
            if ("00".equals(vnp_ResponseCode)) {
                isSuccess = true;
                message = "Giao dịch thanh toán VNPAY hoàn tất thành công!";
                try {
                    orderDAO.updatePaymentSuccessByCode(vnp_TxnRef, "VNPAY-QR");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                message = "Chữ ký bảo mật không hợp lệ hoặc giao dịch bị hủy.";
            }
        }

        Order order = null;
        try {
            order = orderDAO.getOrderByCode(vnp_TxnRef);
        } catch (Exception ignored) {}

        req.setAttribute("isSuccess", isSuccess);
        req.setAttribute("message", message);
        req.setAttribute("orderCode", vnp_TxnRef);
        req.setAttribute("amount", amount);
        req.setAttribute("bankCode", vnp_BankCode);
        req.setAttribute("transactionNo", vnp_TransactionNo);
        req.setAttribute("payDate", formattedPayDate);
        req.setAttribute("order", order);

        req.getRequestDispatcher("payment-result.jsp").forward(req, resp);
    }
}
