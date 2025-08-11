package Servlet;

import java.io.*;
import java.nio.file.Paths;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // Giới hạn file 5MB
public class AdminServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Lấy thông tin từ form
        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String subject = request.getParameter("subject");
        String publisher = request.getParameter("publisher");
        int publicationYear = Integer.parseInt(request.getParameter("publicationYear"));
        String language = request.getParameter("language");
        int numberOfPages = Integer.parseInt(request.getParameter("numberOfPages"));
        String format = request.getParameter("format");
        String authorName = request.getParameter("authorName");
        String isNewAuthor = request.getParameter("isNewAuthor");
        String authorIdParam = request.getParameter("authorId");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        double price = Double.parseDouble(request.getParameter("price"));
        String dateOfPurchaseStr = request.getParameter("dateOfPurchase");

        // Kiểm tra ngày nhập sách
        LocalDate dateOfPurchase;
        try {
            dateOfPurchase = LocalDate.parse(dateOfPurchaseStr);
        } catch (DateTimeParseException e) {
            sendResponse(response, "Lỗi: Định dạng ngày không hợp lệ.");
            return;
        }

        int authorId = 0;

        try (Connection conn = DBConnection.getConnection()) {
            // Xử lý tác giả (nếu là tác giả mới, thêm vào CSDL)
            if ("true".equals(isNewAuthor)) {
                authorId = getOrInsertAuthor(conn, authorName);
            } else if (authorIdParam != null && !authorIdParam.isEmpty()) {
                authorId = Integer.parseInt(authorIdParam);
            } else {
                throw new SQLException("Không xác định được tác giả.");
            }

            // Xử lý ảnh bìa (lưu tên file vào DB và ghi file vào thư mục /images)
            String imagePath = "images/default-cover.jpg";
            Part filePart = request.getPart("coverImage");

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                imagePath = "images/" + fileName;

                // Tạo thư mục nếu chưa có
                String realPath = getServletContext().getRealPath("/") + "images";
                File uploadDir = new File(realPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                // Ghi file vào thư mục images
                filePart.write(realPath + File.separator + fileName);
            }

            // Thêm sách vào bảng `book`
            String sqlBook = "INSERT INTO Book (isbn, title, subject, publisher, publicationYear, language, numberOfPages, format, authorId, quantity, coverImage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sqlBook)) {
                stmt.setString(1, isbn);
                stmt.setString(2, title);
                stmt.setString(3, subject);
                stmt.setString(4, publisher);
                stmt.setInt(5, publicationYear);
                stmt.setString(6, language);
                stmt.setInt(7, numberOfPages);
                stmt.setString(8, format);
                stmt.setInt(9, authorId);
                stmt.setInt(10, quantity);
                stmt.setString(11, imagePath);
                stmt.executeUpdate();
            }

            // Thêm sách vào bảng `bookitem`
            String sqlBookItem = "INSERT INTO BookItem (book_isbn, price, date_of_purchase) VALUES (?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sqlBookItem)) {
                stmt.setString(1, isbn);
                stmt.setDouble(2, price);
                stmt.setDate(3, Date.valueOf(dateOfPurchase));
                stmt.executeUpdate();
            }

            sendResponse(response, "Thêm sách thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(response, "Lỗi: " + e.getMessage());
        }
    }

    // Hàm kiểm tra hoặc thêm tác giả
    private int getOrInsertAuthor(Connection conn, String authorName) throws SQLException {
        String checkSQL = "SELECT id FROM Author WHERE name = ?";
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSQL)) {
            checkStmt.setString(1, authorName);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }

        String insertSQL = "INSERT INTO Author (name) VALUES (?)";
        try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS)) {
            insertStmt.setString(1, authorName);
            insertStmt.executeUpdate();
            ResultSet keys = insertStmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        }
        throw new SQLException("Không thể thêm hoặc tìm tác giả.");
    }

    // Hiển thị thông báo & chuyển hướng
    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('" + message + "'); window.location.href='admin.jsp';</script>");
    }
}
