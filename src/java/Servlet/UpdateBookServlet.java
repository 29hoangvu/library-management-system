package Servlet;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@MultipartConfig(maxFileSize = 16177215) // Giới hạn ảnh tối đa ~16MB
public class UpdateBookServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String subject = request.getParameter("subject");
        String publisher = request.getParameter("publisher");
        String language = request.getParameter("language");
        String format = request.getParameter("format");
        String description = request.getParameter("description");
        String authorName = request.getParameter("authorName"); // Lấy tên tác giả từ form

        int publicationYear = parseInteger(request.getParameter("publicationYear"));
        int numberOfPages = parseInteger(request.getParameter("numberOfPages"));
        int quantity = parseInteger(request.getParameter("quantity"));

        Part filePart = request.getPart("coverImage"); 
        InputStream fileContent = null;
        if (filePart != null && filePart.getSize() > 0) {
            fileContent = filePart.getInputStream();
        }

        Connection conn = null;
        PreparedStatement stmt = null, stmtSummary = null, stmtBookId = null, stmtAuthor = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // Kiểm tra và lấy authorID từ bảng author
            int authorID = -1;
            String checkAuthorSQL = "SELECT id FROM author WHERE name = ?";
            stmtAuthor = conn.prepareStatement(checkAuthorSQL);
            stmtAuthor.setString(1, authorName);
            rs = stmtAuthor.executeQuery();

            if (rs.next()) {
                authorID = rs.getInt("id"); // Tác giả đã tồn tại
            } else {
                // Thêm tác giả mới nếu chưa có
                String insertAuthorSQL = "INSERT INTO author (name) VALUES (?)";
                stmtAuthor = conn.prepareStatement(insertAuthorSQL, Statement.RETURN_GENERATED_KEYS);
                stmtAuthor.setString(1, authorName);
                stmtAuthor.executeUpdate();
                rs = stmtAuthor.getGeneratedKeys();
                if (rs.next()) {
                    authorID = rs.getInt(1); // Lấy ID của tác giả vừa thêm
                }
            }

            // Lấy book_id từ bảng book
            String getBookIdSQL = "SELECT id FROM book WHERE isbn=?";
            stmtBookId = conn.prepareStatement(getBookIdSQL);
            stmtBookId.setString(1, isbn);
            rs = stmtBookId.executeQuery();

            int bookId = -1;
            if (rs.next()) {
                bookId = rs.getInt("id");
            } else {
                response.sendRedirect("editBook.jsp?isbn=" + isbn + "&error=Không tìm thấy sách");
                return;
            }

            // Cập nhật thông tin sách
            String updateBookSQL = "UPDATE book SET title=?, subject=?, publisher=?, publicationYear=?, language=?, numberOfPages=?, format=?, quantity=?, authorID=?";
            if (fileContent != null) {
                updateBookSQL += ", coverImage=?";
            }
            updateBookSQL += " WHERE isbn=?";

            stmt = conn.prepareStatement(updateBookSQL);
            stmt.setString(1, title);
            stmt.setString(2, subject);
            stmt.setString(3, publisher);
            stmt.setInt(4, publicationYear);
            stmt.setString(5, language);
            stmt.setInt(6, numberOfPages);
            stmt.setString(7, format);
            stmt.setInt(8, quantity);
            stmt.setInt(9, authorID); // Gán authorID mới

            int paramIndex = 10;
            if (fileContent != null) {
                stmt.setBinaryStream(paramIndex++, fileContent, filePart.getSize());
            }
            stmt.setString(paramIndex, isbn);

            stmt.executeUpdate();

            // Cập nhật mô tả sách
            if (description != null && !description.trim().isEmpty()) {
                String updateSummarySQL = "INSERT INTO book_description (id, isbn, description) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE description=?";
                stmtSummary = conn.prepareStatement(updateSummarySQL);
                stmtSummary.setInt(1, bookId);
                stmtSummary.setString(2, isbn);
                stmtSummary.setString(3, description);
                stmtSummary.setString(4, description);
                stmtSummary.executeUpdate();
            }

            conn.commit(); // Hoàn tất transaction
            response.sendRedirect("editBook.jsp?isbn=" + isbn + "&update=success");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // Hủy thay đổi nếu lỗi
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            response.sendRedirect("editBook.jsp?isbn=" + isbn + "&error=" + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmtBookId != null) stmtBookId.close();
                if (stmt != null) stmt.close();
                if (stmtSummary != null) stmtSummary.close();
                if (stmtAuthor != null) stmtAuthor.close();
                if (conn != null) conn.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    private int parseInteger(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
