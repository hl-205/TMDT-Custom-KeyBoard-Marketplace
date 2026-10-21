package util;

import jakarta.servlet.http.HttpServletRequest;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

public class VNPayConfig {

    public static String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static String VNP_RETURN_URL = "/vnpay-return";
    public static String VNP_TMN_CODE = "CGXZLS0Z";
    public static String VNP_HASH_SECRET = "XNBCJFAKAZQSGTARRLGCHVZWCIOIGSHN";
    public static String VNP_API_URL = "https://sandbox.vnpayment.vn/merchant_webapi/api/transaction";

    static {
        // Tự động nạp thông số từ vnpay.properties nếu có
        try (InputStream in = VNPayConfig.class.getClassLoader().getResourceAsStream("vnpay.properties")) {
            if (in != null) {
                Properties prop = new Properties();
                prop.load(in);
                if (prop.getProperty("vnp_TmnCode") != null && !prop.getProperty("vnp_TmnCode").isBlank()) {
                    VNP_TMN_CODE = prop.getProperty("vnp_TmnCode").trim();
                }
                if (prop.getProperty("vnp_HashSecret") != null && !prop.getProperty("vnp_HashSecret").isBlank()) {
                    VNP_HASH_SECRET = prop.getProperty("vnp_HashSecret").trim();
                }
                if (prop.getProperty("vnp_PayUrl") != null && !prop.getProperty("vnp_PayUrl").isBlank()) {
                    VNP_PAY_URL = prop.getProperty("vnp_PayUrl").trim();
                }
                if (prop.getProperty("vnp_ReturnUrl") != null && !prop.getProperty("vnp_ReturnUrl").isBlank()) {
                    VNP_RETURN_URL = prop.getProperty("vnp_ReturnUrl").trim();
                }
            }
        } catch (Exception ignored) {}
    }

    public static String md5(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(message.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    public static String sha256(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(message.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    // Thuật toán chuẩn HmacSHA512 của VNPay
    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) {
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
            final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKey);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    public static String getIpAddress(HttpServletRequest request) {
        String ipAddress;
        try {
            ipAddress = request.getHeader("X-FORWARDED-FOR");
            if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("WL-Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getRemoteAddr();
            }
            if (ipAddress != null && ipAddress.contains(",")) {
                ipAddress = ipAddress.split(",")[0].trim();
            }
            if ("0:0:0:0:0:0:0:1".equals(ipAddress) || "::1".equals(ipAddress) || ipAddress == null || ipAddress.isBlank()) {
                ipAddress = "127.0.0.1";
            }
        } catch (Exception e) {
            ipAddress = "127.0.0.1";
        }
        return ipAddress;
    }

    // Hash dữ liệu dạng thô (Raw values)
    public static String hashAllFields(Map<String, String> fields) {
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder sb = new StringBuilder();
        for (String fieldName : fieldNames) {
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (!fieldValue.isEmpty())) {
                if (sb.length() > 0) {
                    sb.append('&');
                }
                sb.append(fieldName).append('=').append(fieldValue);
            }
        }
        return hmacSHA512(VNP_HASH_SECRET, sb.toString());
    }

    // Hash dữ liệu đã URL-encoded theo chuẩn VNPay
    public static String hashAllFieldsUrlEncoded(Map<String, String> fields) {
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder sb = new StringBuilder();
        for (String fieldName : fieldNames) {
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (!fieldValue.isEmpty())) {
                if (sb.length() > 0) {
                    sb.append('&');
                }
                sb.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII));
            }
        }
        return hmacSHA512(VNP_HASH_SECRET, sb.toString());
    }
}

