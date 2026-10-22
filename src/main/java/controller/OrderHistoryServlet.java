package controller;

import dao.OrderHistoryDAO;
import dao.ProductDAO;
import model.Product;
import model.OrderItem;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;

@WebServlet("/order-history")
public class OrderHistoryServlet extends HttpServlet {
    private final OrderHistoryDAO dao=new OrderHistoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp) throws ServletException,IOException {
        HttpSession s=req.getSession(false);
        User u=s==null?null:(User)s.getAttribute("user");
        if(u==null){resp.sendRedirect(req.getContextPath()+"/login?redirect=order-history");return;}
        try {
            String idParam=req.getParameter("id");
            if(idParam!=null&&!idParam.isBlank()) {
                int id=Integer.parseInt(idParam);
                Order order=dao.detail(id,u.getId(),"CUSTOMER");
                if(order==null){resp.sendError(404);return;}
                if(order.getUserId()!=u.getId()){resp.sendError(403);return;}
                req.setAttribute("detail",order);
                Map<Integer, Product> historyProducts = new HashMap<>();
                if (order.getItems() != null) {
                    for (OrderItem item : order.getItems()) {
                        if (item.getProductId() > 0 && !historyProducts.containsKey(item.getProductId())) {
                            historyProducts.put(item.getProductId(), productDAO.getProductById(item.getProductId()));
                        }
                    }
                }
                req.setAttribute("historyProducts", historyProducts);
            }
            String filter = req.getParameter("status");
            if (filter == null) filter = "ALL";
            filter = filter.toUpperCase(java.util.Locale.ROOT);
            if (!java.util.Arrays.asList("ALL", "PENDING", "CONFIRMED", "PROCESSING", "SHIPPING", "COMPLETED", "CANCELLED").contains(filter)) filter = "ALL";
            List<Order> records = dao.list(u.getId(),"CUSTOMER");
            List<Order> filtered = new ArrayList<>();
            for (Order record : records) {
                String current = record.getOrderStatus();
                if ("ALL".equals(filter) || filter.equals(current) || ("SHIPPING".equals(filter) && "SHIPPED".equals(current))) filtered.add(record);
            }
            req.setAttribute("activeTab",filter);
            req.setAttribute("historyOrders",filtered);
            req.getRequestDispatcher("/order-history.jsp").forward(req,resp);
        }catch(NumberFormatException e){resp.sendError(400);}catch(SQLException e){throw new ServletException(e);}
    }
}
