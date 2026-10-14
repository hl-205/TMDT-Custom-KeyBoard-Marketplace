Hãy đảm bảo máy tính đã cài đặt các công cụ sau:
1. **Java Development Kit (JDK):** Bắt buộc sử dụng **JDK 21** (hoặc JRE tương thích JDK 21). Kiểm tra trong pom.xml có 2 dòng này rồi thì mới chính xác 
        <maven.compiler.target>21</maven.compiler.target>
        <maven.compiler.source>21</maven.compiler.source>
2. **Apache Tomcat:** Phiên bản **Tomcat 10** (hoặc Tomcat 10.1.x trở lên sử dụng chuẩn `jakarta.servlet`)
3. **Database:** WampServer
4. **Quản lý CSDL:** Navicat Premium

---

Thiết lập Database (WampServer & Navicat)
1. Khởi động **WampServer** (đảm bảo icon dưới khay hệ thống chuyển sang màu xanh lá)
2. Mở **Navicat**, tạo một kết nối MySQL mới (`Connection > MySQL`):
   * Connection Name: `KeebHubLocal`
   * Host: `localhost`
   * Port: `3306`
   * User Name: `root`
   * Password: *(để trống)*
3. Mở kết nối vừa tạo, bấm nút **New Query** trên thanh công cụ
4. Mở file `database/keebhub_db.sql` có sẵn trong thư mục dự án, copy toàn bộ nội dung dán vào cửa sổ Query của Navicat và bấm **Run**

---

Cấu hình Apache Tomcat 10 & JDK 21
1. Vào **File > Project Structure** (hoặc nhấn `Ctrl + Alt + Shift + S`):
   * Mục **SDK**: Chọn `21` (hoặc JDK 21 tương ứng)
   * Mục **Language level**: Chọn `21`
2. Trên góc phải màn hình IntelliJ, chọn **Add Configuration...** (hoặc bấm vào cấu hình Server hiện có):
   * Nhấn dấu **+** > chọn **Tomcat Server > Local**
   * Ở mục **Application server**, chọn thư mục đã cài đặt Apache Tomcat 10 của bạn
   * Chuyển sang tab **Deployment** > nhấn dấu **+** > chọn **Artifact...** > chọn `KeebHub:war exploded`
   * Tại ô **Application context** ở dưới cùng, xóa hết và chỉ để lại dấu **`/`**
   * Nhấn **Apply** và **OK**

---

Tuyệt đối **không code trực tiếp trên nhánh `main`**. Khi bắt đầu làm một tính năng mới, hãy tuân thủ:
1. Cập nhật code mới nhất từ nhánh chính:
   ```bash
   git checkout main
   git pull origin main
