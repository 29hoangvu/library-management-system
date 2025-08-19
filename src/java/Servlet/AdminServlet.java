package Servlet;

import java.io.*;
import java.nio.file.Paths;
import java.sql.*;
import java.time.LocalDate;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class AdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // ---- LẤY FORM ----
        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
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

        String genreIdsCsv = request.getParameter("genreIds");   // "3,5,9"
        String newGenresCsv = request.getParameter("newGenres"); // "AI,Khoa học dữ liệu"

        // ---- PARSE NGÀY ----
        LocalDate dateOfPurchase;
        try {
            dateOfPurchase = LocalDate.parse(dateOfPurchaseStr);
        } catch (Exception e) {
            sendResponse(response, "Lỗi: Định dạng ngày không hợp lệ.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);  // BẮT ĐẦU TRANSACTION

            // ---- TÁC GIẢ ----
            int authorId;
            if ("true".equals(isNewAuthor)) {
                authorId = getOrInsertAuthor(conn, authorName);
            } else if (authorIdParam != null && !authorIdParam.isEmpty()) {
                authorId = Integer.parseInt(authorIdParam);
            } else {
                throw new SQLException("Không xác định được tác giả.");
            }

            // ---- ẢNH BÌA ----
            String imagePath = "images/default-cover.jpg";
            Part filePart = request.getPart("coverImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                imagePath = "images/" + fileName;
                String realPath = getServletContext().getRealPath("/") + "images";
                File uploadDir = new File(realPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }
                filePart.write(realPath + File.separator + fileName);
            }

            // ---- THÊM BOOK (KHÔNG CÓ subject) ----
            int bookId;
            String sqlBook = "INSERT INTO book (isbn, title, publisher, publicationYear, language, numberOfPages, format, authorId, coverImage, quantity, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE')";
            try (PreparedStatement ps = conn.prepareStatement(sqlBook, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, isbn);
                ps.setString(2, title);
                ps.setString(3, publisher);
                ps.setInt(4, publicationYear);
                ps.setString(5, language);
                ps.setInt(6, numberOfPages);
                ps.setString(7, format);
                ps.setInt(8, authorId);
                ps.setString(9, imagePath);
                ps.setInt(10, quantity);
                ps.executeUpdate();

                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        bookId = keys.getInt(1);
                    } else {
                        throw new SQLException("Không lấy được book.id sau khi insert.");
                    }
                }
            }

            // ---- THÊM BOOKITEM (nếu bạn cần record lô nhập) ----
            String sqlBookItem = "INSERT INTO bookitem (book_isbn, price, date_of_purchase) VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlBookItem)) {
                ps.setString(1, isbn);
                ps.setDouble(2, price);
                ps.setDate(3, java.sql.Date.valueOf(dateOfPurchase));
                ps.executeUpdate();
            }

            // ---- XỬ LÝ GENRE CÓ SẴN ----
            if (genreIdsCsv != null && !genreIdsCsv.isBlank()) {
                for (String s : genreIdsCsv.split(",")) {
                    int gid = Integer.parseInt(s.trim());
                    insertBookGenreIfAbsent(conn, bookId, gid);
                }
            }

            // ---- XỬ LÝ GENRE MỚI ----
            if (newGenresCsv != null && !newGenresCsv.isBlank()) {
                for (String name : newGenresCsv.split(",")) {
                    String trimmed = name.trim();
                    if (trimmed.isEmpty()) {
                        continue;
                    }
                    int gid = getOrInsertGenre(conn, trimmed);
                    insertBookGenreIfAbsent(conn, bookId, gid);
                }
            }

            conn.commit();
            sendResponse(response, "Thêm sách thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(response, "Lỗi: " + e.getMessage());
        }
    }

    // ========= HELPERS =========
    private int getOrInsertAuthor(Connection conn, String authorName) throws SQLException {
        try (PreparedStatement s = conn.prepareStatement("SELECT id FROM author WHERE name = ?")) {
            s.setString(1, authorName);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        try (PreparedStatement ins = conn.prepareStatement("INSERT INTO author(name) VALUES (?)", Statement.RETURN_GENERATED_KEYS)) {
            ins.setString(1, authorName);
            ins.executeUpdate();
            try (ResultSet keys = ins.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không thể thêm/tìm tác giả.");
    }

    private int getOrInsertGenre(Connection conn, String name) throws SQLException {
        try (PreparedStatement s = conn.prepareStatement("SELECT id FROM genre WHERE name = ?")) {
            s.setString(1, name);
            try (ResultSet rs = s.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        try (PreparedStatement ins = conn.prepareStatement("INSERT INTO genre(name) VALUES (?)", Statement.RETURN_GENERATED_KEYS)) {
            ins.setString(1, name);
            ins.executeUpdate();
            try (ResultSet keys = ins.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không thể thêm/tìm thể loại.");
    }

    private void insertBookGenreIfAbsent(Connection conn, int bookId, int genreId) throws SQLException {
        // tránh trùng
        try (PreparedStatement chk = conn.prepareStatement("SELECT 1 FROM book_genre WHERE book_id = ? AND genre_id = ?")) {
            chk.setInt(1, bookId);
            chk.setInt(2, genreId);
            try (ResultSet rs = chk.executeQuery()) {
                if (rs.next()) {
                    return;
                }
            }
        }
        try (PreparedStatement ins = conn.prepareStatement("INSERT INTO book_genre(book_id, genre_id) VALUES (?, ?)")) {
            ins.setInt(1, bookId);
            ins.setInt(2, genreId);
            ins.executeUpdate();
        }
    }

    private void sendResponse(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<script>alert('" + message + "'); window.location.href='auth/lib/admin.jsp';</script>");
    }
}
