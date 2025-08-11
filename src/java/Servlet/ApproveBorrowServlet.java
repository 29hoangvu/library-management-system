package Servlet;
//duyet mượn sách
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ApproveBorrowServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String borrowId = request.getParameter("borrowId");
        String bookItemId = request.getParameter("bookItemId");

        if (borrowId == null || bookItemId == null) {
            sendResponse(response, "Thiếu dữ liệu!");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu transaction

            // 1️⃣ Lấy ISBN từ bookitem để cập nhật số lượng sách
            String getIsbnSql = "SELECT book_isbn FROM bookitem WHERE book_item_id = ?";
            PreparedStatement getIsbnStmt = conn.prepareStatement(getIsbnSql);
            getIsbnStmt.setInt(1, Integer.parseInt(bookItemId));
            ResultSet isbnRs = getIsbnStmt.executeQuery();
            
            if (!isbnRs.next()) {
                sendResponse(response, "Không tìm thấy sách.");
                return;
            }

            String isbn = isbnRs.getString("book_isbn");

            // 2️⃣ Kiểm tra số lượng sách trong bảng book
            String checkQuantitySql = "SELECT quantity FROM book WHERE isbn = ?";
            PreparedStatement checkQuantityStmt = conn.prepareStatement(checkQuantitySql);
            checkQuantityStmt.setString(1, isbn);
            ResultSet quantityRs = checkQuantityStmt.executeQuery();

            if (quantityRs.next()) {
                int quantity = quantityRs.getInt("quantity");
                if (quantity <= 0) {
                    sendResponse(response, "Sách đã hết, không thể duyệt!");
                    return;
                }
            } else {
                sendResponse(response, "Lỗi: Không tìm thấy sách.");
                return;
            }

            // 3️⃣ Cập nhật trạng thái phiếu mượn thành "Đang mượn"
            String updateBorrowSql = "UPDATE borrow SET status = 'Borrowed' WHERE borrow_id = ?";
            PreparedStatement updateBorrowStmt = conn.prepareStatement(updateBorrowSql);
            updateBorrowStmt.setInt(1, Integer.parseInt(borrowId));

            // 4️⃣ Giảm số lượng sách trong bảng book
            String updateBookQuantitySql = "UPDATE book SET quantity = quantity - 1 WHERE isbn = ?";
            PreparedStatement updateBookStmt = conn.prepareStatement(updateBookQuantitySql);
            updateBookStmt.setString(1, isbn);

            int rowsBorrow = updateBorrowStmt.executeUpdate();
            int rowsBook = updateBookStmt.executeUpdate();

            if (rowsBorrow > 0 && rowsBook > 0) {
                conn.commit(); // Xác nhận transaction
                sendResponse(response, "Duyệt mượn thành công!");
            } else {
                conn.rollback(); // Hoàn tác nếu có lỗi
                sendResponse(response, "Lỗi cập nhật dữ liệu.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            sendResponse(response, "Lỗi hệ thống! Vui lòng thử lại sau.");
        }
    }

    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('" + message + "'); window.location.href='borrowList.jsp';</script>");
    }
}
