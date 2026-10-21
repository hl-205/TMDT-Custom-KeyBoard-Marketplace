package dao;

import java.sql.*;
import java.util.*;

/** Địa chỉ thuộc tài khoản; dùng chung kết nối DBContext của dự án. */
public class AddressDAO {
    public static class Address {
        private final int id;
        private final String name, phone, address;
        private final boolean defaultAddress;
        public Address(int id, String name, String phone, String address, boolean defaultAddress) {
            this.id=id; this.name=name; this.phone=phone; this.address=address; this.defaultAddress=defaultAddress;
        }
        public int getId(){return id;}
        public String getName(){return name;}
        public String getPhone(){return phone;}
        public String getAddress(){return address;}
        public boolean isDefaultAddress(){return defaultAddress;}
    }

    public List<Address> findByUser(int userId) throws SQLException {
        List<Address> result = new ArrayList<>();
        String sql="SELECT id,receiver_name,receiver_phone,full_address,is_default FROM user_addresses WHERE user_id=? ORDER BY is_default DESC,id DESC";
        try(Connection c=DBContext.getConnection(); PreparedStatement p=c.prepareStatement(sql)) {
            p.setInt(1,userId);
            try(ResultSet r=p.executeQuery()) {
                while(r.next()) result.add(new Address(r.getInt(1),r.getString(2),r.getString(3),r.getString(4),r.getBoolean(5)));
            }
        }
        // Nếu chưa lưu sổ địa chỉ, sử dụng thông tin nhận hàng ở đơn gần nhất.
        if(result.isEmpty()) {
            String previous="SELECT id,receiver_name,receiver_phone,shipping_address FROM orders WHERE user_id=? AND shipping_address IS NOT NULL AND TRIM(shipping_address)<>'' ORDER BY created_at DESC,id DESC LIMIT 1";
            try(Connection c=DBContext.getConnection(); PreparedStatement p=c.prepareStatement(previous)) {
                p.setInt(1,userId);
                try(ResultSet r=p.executeQuery()) {
                    if(r.next()) result.add(new Address(-r.getInt(1),r.getString(2),r.getString(3),r.getString(4),false));
                }
            }
        }
        return result;
    }

    public Address findOwned(int userId,int addressId) throws SQLException {
        boolean previous=addressId<0;
        String sql=previous
                ? "SELECT id,receiver_name,receiver_phone,shipping_address FROM orders WHERE user_id=? AND id=?"
                : "SELECT id,receiver_name,receiver_phone,full_address,is_default FROM user_addresses WHERE user_id=? AND id=?";
        try(Connection c=DBContext.getConnection(); PreparedStatement p=c.prepareStatement(sql)) {
            p.setInt(1,userId); p.setInt(2,previous ? -addressId : addressId);
            try(ResultSet r=p.executeQuery()) {
                if(r.next()) return new Address(previous ? -r.getInt(1) : r.getInt(1),r.getString(2),r.getString(3),r.getString(4),previous ? false : r.getBoolean(5));
            }
        }
        return null;
    }

    public int save(int userId,String name,String phone,String address) throws SQLException {
        try(Connection c=DBContext.getConnection()) {
            boolean first;
            try(PreparedStatement p=c.prepareStatement("SELECT COUNT(*) FROM user_addresses WHERE user_id=?")) {
                p.setInt(1,userId);
                try(ResultSet r=p.executeQuery()) { r.next(); first=r.getInt(1)==0; }
            }
            try(PreparedStatement p=c.prepareStatement("INSERT INTO user_addresses(user_id,receiver_name,receiver_phone,full_address,is_default) VALUES(?,?,?,?,?)",Statement.RETURN_GENERATED_KEYS)) {
                p.setInt(1,userId); p.setString(2,name); p.setString(3,phone); p.setString(4,address); p.setBoolean(5,first);
                p.executeUpdate();
                try(ResultSet r=p.getGeneratedKeys()) { return r.next()?r.getInt(1):0; }
            }
        }
    }

    /** Chỉnh sửa địa chỉ thuộc đúng tài khoản; không tạo bản ghi mới. */
    public boolean update(int userId, int addressId, String name, String phone, String address) throws SQLException {
        if (addressId <= 0) return false;
        String sql = "UPDATE user_addresses SET receiver_name=?, receiver_phone=?, full_address=? WHERE id=? AND user_id=?";
        try (Connection c=DBContext.getConnection(); PreparedStatement p=c.prepareStatement(sql)) {
            p.setString(1,name); p.setString(2,phone); p.setString(3,address);
            p.setInt(4,addressId); p.setInt(5,userId);
            return p.executeUpdate()==1;
        }
    }

}
