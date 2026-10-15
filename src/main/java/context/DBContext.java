package context;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    public Connection getConnection() throws SQLException {
        // Thông tin cấu hình kết nối MySQL keebhub_db
        String user = "root";
        String pass = ""; // Mật khẩu rỗng
        String url = "jdbc:mysql://localhost:3306/keebhub_db?useSSL=false&allowPublicKeyRetrieval=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";

        try {
            // Nạp MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException e) {
            System.err.println("Chưa thêm thư viện MySQL JDBC Driver!");
            e.printStackTrace();
            return null;
        }
    }

    // Hàm main để test kết nối trực tiếp
    public static void main(String[] args) {
        try {
            DBContext db = new DBContext();
            Connection conn = db.getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Kết nối CSDL keebhub_db thành công!");
            } else {
                System.out.println("❌ Kết nối thất bại!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}