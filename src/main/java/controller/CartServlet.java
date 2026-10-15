package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.CartItem;
import model.Product;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    @SuppressWarnings("unchecked")
    private Map<Integer, CartItem> getCart(HttpSession session) {
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new LinkedHashMap<>();
            session.setAttribute("cart", cart);
        }
        return cart;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("cartItems", getCart(req.getSession()).values());
        req.getRequestDispatcher("/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = getCart(session);
        String action = req.getParameter("action");

        // Nhận diện cả 'productId' và 'id' từ Form gửi lên
        String productIdStr = req.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            productIdStr = req.getParameter("id");
        }

        try {
            if (productIdStr == null || productIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Không tìm thấy ID sản phẩm.");
            }

            int productId = Integer.parseInt(productIdStr.trim());

            if ("remove".equals(action)) {
                cart.remove(productId);
            } else if ("update".equals(action)) {
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                CartItem item = cart.get(productId);
                if (item != null) {
                    item.setQuantity(quantity);
                }
            } else {
                // Hành động mặc định: THÊM VÀO GIỎ HÀNG (ADD)
                ProductDAO productDAO = new ProductDAO();
                Product product = productDAO.getProductById(productId);

                if (product == null) {
                    session.setAttribute("flashError", "Không tìm thấy sản phẩm có ID: " + productId);
                } else if (product.getStock() <= 0) {
                    session.setAttribute("flashError", "Sản phẩm \"" + product.getName() + "\" hiện đã hết hàng.");
                } else {
                    String qtyStr = req.getParameter("quantity");
                    int addQty = (qtyStr != null && !qtyStr.trim().isEmpty()) ? Integer.parseInt(qtyStr.trim()) : 1;

                    CartItem item = cart.get(productId);
                    if (item == null) {
                        cart.put(productId, new CartItem(product, Math.min(addQty, product.getStock())));
                    } else {
                        int newQty = item.getQuantity() + addQty;
                        if (newQty > product.getStock()) {
                            newQty = product.getStock();
                            session.setAttribute("flashError", "Số lượng trong giỏ đã đạt giới hạn tồn kho.");
                        }
                        item.setQuantity(newQty);
                    }
                }
            }
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Mã sản phẩm hoặc số lượng không hợp lệ.");
        } catch (Exception e) {
            session.setAttribute("flashError", "Lỗi cập nhật giỏ hàng: " + e.getMessage());
        }

        // "Mua ngay" -> sau khi thêm vào giỏ thì chuyển thẳng sang thanh toán
        if (req.getParameter("buyNow") != null && session.getAttribute("flashError") == null) {
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}