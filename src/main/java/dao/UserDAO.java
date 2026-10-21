package dao;

import model.User;
import java.sql.*;

public class UserDAO {

    private static boolean schemaChecked = false;

    public static synchronized void ensureUserTableSchema() {
        if (schemaChecked) return;
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            try {
                st.executeUpdate("ALTER TABLE users ADD COLUMN address VARCHAR(255) DEFAULT ''");
            } catch (SQLException ignored) {}
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public User checkLogin(String account, String password) {
        ensureUserTableSchema();
        String sql = "SELECT * FROM users WHERE (email = ? OR phone = ?) AND password = ? AND status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, account.trim());
            ps.setString(2, account.trim());
            ps.setString(3, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int id) {
        ensureUserTableSchema();
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(int id, String firstName, String lastName, String phone, String gender, String dob, String address) {
        ensureUserTableSchema();
        String avatar = "KH";
        String f = (firstName != null) ? firstName.trim() : "";
        String l = (lastName != null) ? lastName.trim() : "";
        if (!f.isEmpty() && !l.isEmpty()) {
            avatar = ("" + f.charAt(0) + l.charAt(0)).toUpperCase();
        } else if (!f.isEmpty()) {
            avatar = f.substring(0, Math.min(2, f.length())).toUpperCase();
        } else if (!l.isEmpty()) {
            avatar = l.substring(0, Math.min(2, l.length())).toUpperCase();
        }

        String sql = "UPDATE users SET first_name = ?, last_name = ?, phone = ?, gender = ?, dob = ?, address = ?, avatar_text = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, f);
            ps.setString(2, l);
            ps.setString(3, phone != null ? phone.trim() : "");
            ps.setString(4, (gender != null && !gender.isBlank()) ? gender.trim() : "Nam");

            if (dob != null && !dob.isBlank()) {
                try {
                    ps.setDate(5, Date.valueOf(dob.trim()));
                } catch (IllegalArgumentException ex) {
                    ps.setNull(5, Types.DATE);
                }
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setString(6, address != null ? address.trim() : "");
            ps.setString(7, avatar);
            ps.setInt(8, id);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(int id, String oldPassword, String newPassword) {
        String verifySql = "SELECT id FROM users WHERE id = ? AND password = ?";
        String updateSql = "UPDATE users SET password = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement psVerify = conn.prepareStatement(verifySql)) {
                psVerify.setInt(1, id);
                psVerify.setString(2, oldPassword);
                try (ResultSet rs = psVerify.executeQuery()) {
                    if (!rs.next()) {
                        return false; // Mật khẩu cũ không đúng
                    }
                }
            }
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setString(1, newPassword);
                psUpdate.setInt(2, id);
                return psUpdate.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isEmailExists(String email) {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(String firstName, String lastName, String email, String phone, String password) {
        ensureUserTableSchema();
        String avatar = "KH";
        if (firstName != null && !firstName.isEmpty() && lastName != null && !lastName.isEmpty()) {
            avatar = ("" + firstName.trim().charAt(0) + lastName.trim().charAt(0)).toUpperCase();
        }
        String sql = "INSERT INTO users (first_name, last_name, email, phone, password, avatar_text, role, points, is_verified, status, address) "
                + "VALUES (?, ?, ?, ?, ?, ?, 'CUSTOMER', 0, 1, 'ACTIVE', '')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, firstName.trim());
            ps.setString(2, lastName.trim());
            ps.setString(3, email.trim());
            ps.setString(4, phone.trim());
            ps.setString(5, password);
            ps.setString(6, avatar);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setPassword(rs.getString("password"));
        u.setGender(rs.getString("gender"));
        u.setDob(rs.getDate("dob"));
        u.setAvatarText(rs.getString("avatar_text"));
        u.setRole(rs.getString("role"));
        u.setPoints(rs.getInt("points"));
        u.setVerified(rs.getInt("is_verified") == 1);
        u.setStatus(rs.getString("status"));
        try {
            u.setAddress(rs.getString("address"));
        } catch (SQLException ignored) {
            u.setAddress("");
        }
        return u;
    }
}