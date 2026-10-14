package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import java.util.Random;

public class EmailUtils {
    // THAY EMAIL VÀ MẬT KHẨU ỨNG DỤNG (16 KÝ TỰ) CỦA BẠN VÀO ĐÂY:
    private static final String SENDER_EMAIL = "hoanglong280305@gmail.com";
    private static final String APP_PASSWORD = "cpvl jedf jlya mlby";

    public static String generateOTP() {
        Random rnd = new Random();
        int number = 100000 + rnd.nextInt(900000);
        return String.valueOf(number);
    }

    public static boolean sendOTPEmail(String toEmail, String otpCode, String purpose) {
        // In ra Console của Tomcat để đối chiếu khi test
        System.out.println("==================================================");
        System.out.println("[KEEBHUB OTP - " + purpose + "] Gửi tới: " + toEmail);
        System.out.println(">>> MÃ XÁC THỰC 6 SỐ CỦA BẠN LÀ: " + otpCode + " <<<");
        System.out.println("==================================================");

        if (SENDER_EMAIL.equals("your-email@gmail.com") || APP_PASSWORD.contains("xxxx")) {
            System.out.println("[CẢNH BÁO] Bạn chưa điền SENDER_EMAIL và APP_PASSWORD thật trong EmailUtils.java nên hệ thống chưa gửi qua Gmail.");
            return false;
        }

        // Tự động xóa khoảng trắng nếu người dùng copy App Password dạng "abcd efgh ijkl mnop"
        final String cleanAppPassword = APP_PASSWORD.replaceAll("\\s+", "");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL.trim(), cleanAppPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL.trim(), "KeebHub Marketplace", "UTF-8"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail.trim()));
            message.setSubject("[KeebHub] Mã xác thực OTP: " + otpCode, "UTF-8");

            String htmlContent = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:24px;border:1px solid #E2E8F0;border-radius:12px;'>"
                    + "<h2 style='color:#1B64F2;margin-top:0;'>KeebHub</h2>"
                    + "<p>Xin chào,</p>"
                    + "<p>Mã xác thực OTP cho yêu cầu <strong>" + purpose + "</strong> của bạn là:</p>"
                    + "<div style='font-size:28px;font-weight:bold;letter-spacing:6px;color:#0F172A;background:#F1F5F9;padding:14px;text-align:center;border-radius:8px;margin:20px 0;'>"
                    + otpCode + "</div>"
                    + "<p style='color:#64748B;font-size:13px;'>Mã này có hiệu lực trong vòng 05 phút. Tuyệt đối không chia sẻ mã này cho người khác.</p>"
                    + "</div>";

            message.setContent(htmlContent, "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        String[] parts = email.split("@");
        String name = parts[0];
        if (name.length() <= 3) return name + "••••@" + parts[1];
        return name.substring(0, 3) + "••••••@" + parts[1];
    }
}