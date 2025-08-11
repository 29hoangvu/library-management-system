package Servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import Data.Users;

@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Users user = (Users) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = user.getId();
        String fullName = request.getParameter("fullName");
        String gender = request.getParameter("gender");
        String birthDate = request.getParameter("birthDate");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;

        try {
            conn = DBConnection.getConnection();

            // Kiểm tra xem đã có thông tin trong user_profile chưa
            String checkSql = "SELECT userID FROM user_profile WHERE userID = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            ResultSet rs = psCheck.executeQuery();

            boolean exists = rs.next();

            if (exists) {
                // Cập nhật
                String updateSql = "UPDATE user_profile SET fullName=?, gender=?, birthDate=?, phone=?, address=? WHERE userID=?";
                psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setString(1, fullName);
                psUpdate.setString(2, gender);
                psUpdate.setString(3, birthDate);
                psUpdate.setString(4, phone);
                psUpdate.setString(5, address);
                psUpdate.setInt(6, userId);
                psUpdate.executeUpdate();
            } else {
                // Thêm mới
                String insertSql = "INSERT INTO user_profile (userID, fullName, gender, birthDate, phone, address) VALUES (?, ?, ?, ?, ?, ?)";
                psInsert = conn.prepareStatement(insertSql);
                psInsert.setInt(1, userId);
                psInsert.setString(2, fullName);
                psInsert.setString(3, gender);
                psInsert.setString(4, birthDate);
                psInsert.setString(5, phone);
                psInsert.setString(6, address);
                psInsert.executeUpdate();
            }

            // Gửi trạng thái thành công về client
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } finally {
            try { if (psCheck != null) psCheck.close(); } catch (Exception e) {}
            try { if (psUpdate != null) psUpdate.close(); } catch (Exception e) {}
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
