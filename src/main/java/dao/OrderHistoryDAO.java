package dao;

import model.Order;
import java.sql.*;
import java.util.*;

public class OrderHistoryDAO {
    private final OrderDAO base = new OrderDAO();

    public List<Order> list(int userId, String role) throws SQLException {
        // Mỗi người xem đơn mình đã đặt; Admin xem toàn bộ đơn hàng.
        if ("ADMIN".equalsIgnoreCase(role)) return base.findAll();
        return base.findByUser(userId);
    }

    public Order detail(int id,int userId,String role) throws SQLException {
        String sql="SELECT o.id FROM orders o LEFT JOIN shops s ON s.id=o.shop_id WHERE o.id=? AND ( (?='ADMIN') OR (?='SELLER' AND s.owner_id=?) OR (o.user_id=?) )";
        try(Connection c=DBContext.getConnection();PreparedStatement ps=c.prepareStatement(sql)) {
            ps.setInt(1,id); ps.setString(2,role); ps.setString(3,role); ps.setInt(4,userId); ps.setInt(5,userId);
            try(ResultSet rs=ps.executeQuery()){return rs.next()?base.getOrderById(id):null;}
        }
    }

    public boolean changeStatus(int id,int userId,String role,String next) throws SQLException {
        try(Connection c=DBContext.getConnection()) {
            c.setAutoCommit(false);
            try {
                String current; int buyer; int owner;
                try(PreparedStatement ps=c.prepareStatement("SELECT o.order_status,o.user_id,COALESCE(s.owner_id,-1) FROM orders o LEFT JOIN shops s ON s.id=o.shop_id WHERE o.id=? FOR UPDATE")) {
                    ps.setInt(1,id);
                    try(ResultSet rs=ps.executeQuery()) { if(!rs.next()) { c.rollback();return false; } current=rs.getString(1);buyer=rs.getInt(2);owner=rs.getInt(3); }
                }
                boolean admin="ADMIN".equalsIgnoreCase(role);
                // Admin được bỏ qua bước trung gian, nhưng không được lùi hoặc mở lại đơn đã kết thúc.
                List<String> flow=Arrays.asList("PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "SHIPPED", "COMPLETED");
                int currentStep=flow.indexOf(current), nextStep=flow.indexOf(next);
                boolean permitted=admin && currentStep>=0 && currentStep<flow.size()-1 &&
                        ("CANCELLED".equals(next) || nextStep>currentStep);
                if(!permitted){c.rollback();return false;}
                int pct=0;
                if ("CONFIRMED".equals(next)) pct=20;
                else if ("PROCESSING".equals(next)) pct=50;
                else if ("SHIPPING".equals(next)) pct=80;
                else if ("SHIPPED".equals(next)) pct=90;
                else if ("COMPLETED".equals(next)) pct=100;
                try(PreparedStatement ps=c.prepareStatement("UPDATE orders SET order_status=?, progress_percent=? WHERE id=?")) {
                    ps.setString(1,next);ps.setInt(2,pct);ps.setInt(3,id);ps.executeUpdate();
                }
                if("CANCELLED".equals(next)) {
                    // Restore stock only for itemized checkout orders. Legacy orders without order_items are untouched.
                    try(PreparedStatement ps=c.prepareStatement("SELECT product_id,quantity FROM order_items WHERE order_id=?")) {
                        ps.setInt(1,id);
                        try(ResultSet rs=ps.executeQuery()) {
                            try(PreparedStatement up=c.prepareStatement("UPDATE products SET stock=stock+?,sold_count=GREATEST(0,sold_count-?) WHERE id=?")) {
                                while(rs.next()) {int q=rs.getInt(2);up.setInt(1,q);up.setInt(2,q);up.setInt(3,rs.getInt(1));up.executeUpdate();}
                            }
                        }
                    }
                }
                c.commit();return true;
            }catch(SQLException|RuntimeException e){c.rollback();throw e;}
            finally{c.setAutoCommit(true);}
        }
    }
}
