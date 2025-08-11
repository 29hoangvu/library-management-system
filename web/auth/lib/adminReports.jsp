<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>

<%
    Users user = (Users) session.getAttribute("user");

    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <title>Thống kê - Báo cáo</title>
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/table_ad.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/admin.js"></script> 
    <style>
        .report-section {
            width: 100%;
/*            max-width: 900px;*/
            margin: 20px auto;
            background: #fff; padding: 20px; border-radius: 8px;
            box-shadow: 0 0 5px rgba(0,0,0,0.1);
        }      
        .filter-bar { margin-bottom: 20px; text-align: center; }
        .sl { padding: 5px; font-size: 14px; width: 150px; }
        button {
            padding: 5px 10px; font-size: 16px; background-color: #4285F4;
            color: white; border: none; cursor: pointer;
            border-radius: 10px;
        }
        button:hover { background-color: #306ace; }
        .total-row { font-weight: bold; background: #f1f1f1; }
        .nav-buttons {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin: 10px 0 20px -10%;
        }
        .nav-buttons a {
            padding: 10px 15px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .nav-buttons a:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Quản lý sách - Admin</h1>
    </div>
    <div class="sidebar">
        <h2>Menu</h2>
        <ul>
            <li><a href="adminDashboard.jsp">Dashboard</a></li>
            <li><a href="admin.jsp">Thêm sách</a></li>
            <li><a href="addBookItem.jsp">Vị trí sách</a></li>
            <% if (user.getRoleID() == 1) { %>
                <li><a href="createUser.jsp">Quản lý người dùng</a></li>
            <% } %>
            <li><a href="adminBorrowedBooks.jsp">Quản lý mượn trả sách</a></li>
        </ul>
        <div class="user-menu" onclick="toggleUserMenu()">
            <span><%= user.getUsername() %></span>
            <span id="arrowIcon" class="arrow">▼</span>
        </div>
        <div id="userDropup" class="user-dropup">
            <a href="#">Thông tin cá nhân</a>
            <a href="#">Cài đặt</a>
            <a href="LogOutServlet">Đăng xuất</a>
        </div>
    </div>

    <div class="content">
        <div class="nav-buttons">         
            <a href="adminBorrowedBooks.jsp">Quản lý Mượn/Trả</a>
            <a href="borrowList.jsp">Duyệt Mượn Sách</a>
            <a href="adminReports.jsp">Thống kê</a>
        </div>
        <div class="filter-bar">
            <form method="GET">
                <label for="reportType">Loại báo cáo </label>
                <select class="sl" name="reportType" id="reportType">
                    <option value="borrowReport" <%= "borrowReport".equals(request.getParameter("reportType")) ? "selected" : "" %>>Báo cáo mượn sách</option>
                    <option value="fineReport" <%= "fineReport".equals(request.getParameter("reportType")) ? "selected" : "" %>>Thống kê tiền phạt</option>
                </select>

                <label for="month">Chọn tháng </label>
                <select class="sl" name="month" id="month">
                    <option value="">-- Tất cả --</option>
                    <% for (int i = 1; i <= 12; i++) { %>
                        <option value="<%= i %>" <%= request.getParameter("month") != null && request.getParameter("month").equals(String.valueOf(i)) ? "selected" : "" %>>
                            Tháng <%= i %>
                        </option>
                    <% } %>
                </select>

                <label for="year">Chọn năm </label>
                <select class="sl" name="year" id="year">
                    <option value="">-- Tất cả --</option>
                    <%  
                        Connection connYear = DBConnection.getConnection();
                        PreparedStatement stmtYear = connYear.prepareStatement("SELECT DISTINCT YEAR(borrowed_date) AS year FROM borrow ORDER BY year DESC");
                        ResultSet rsYear = stmtYear.executeQuery();
                        while (rsYear.next()) {
                            int year = rsYear.getInt("year");
                    %>
                            <option value="<%= year %>" <%= request.getParameter("year") != null && request.getParameter("year").equals(String.valueOf(year)) ? "selected" : "" %>>
                                <%= year %>
                            </option>
                    <% } connYear.close(); %>
                </select>

                <button type="submit">Xem báo cáo</button>
            </form>
        </div>

        <%  
            Connection conn = DBConnection.getConnection();
            String reportType = request.getParameter("reportType");
            String monthFilter = request.getParameter("month");
            String yearFilter = request.getParameter("year");

            if ("fineReport".equals(reportType)) {
                String sqlFine = "SELECT MONTH(borrowed_date) AS month, YEAR(borrowed_date) AS year, users.username AS userName, SUM(fine_amount) AS totalFine " +
                                 "FROM borrow JOIN users ON borrow.user_id = users.id WHERE fine_amount > 0 ";
                if (monthFilter != null && !monthFilter.isEmpty()) sqlFine += " AND MONTH(borrowed_date) = " + monthFilter;
                if (yearFilter != null && !yearFilter.isEmpty()) sqlFine += " AND YEAR(borrowed_date) = " + yearFilter;
                sqlFine += " GROUP BY YEAR(borrowed_date), MONTH(borrowed_date), users.username ORDER BY year DESC, month ASC";

                ResultSet rsFine = conn.createStatement().executeQuery(sqlFine);
                int totalFineAmount = 0;
        %>
                <div class="report-section">
                    <h2>Thống kê tiền phạt</h2>
                    <table class="table">
                        <tr><th>Tháng</th><th>Năm</th><th>Người dùng</th><th>Tổng tiền phạt</th></tr>
                        <% while (rsFine.next()) { 
                            totalFineAmount += rsFine.getInt("totalFine");
                        %>
                        <tr>
                            <td><%= rsFine.getInt("month") %></td>
                            <td><%= rsFine.getInt("year") %></td>
                            <td><%= rsFine.getString("userName") %></td>
                            <td><%= rsFine.getInt("totalFine") %> VNĐ</td>
                        </tr>
                        <% } %>
                        <tr class="total-row">
                            <td colspan="3">Tổng cộng:</td>
                            <td><%= totalFineAmount %> VNĐ</td>
                        </tr>
                    </table>
                </div>
        <% } else if ("borrowReport".equals(reportType)) { 
                String sqlBorrow = "SELECT MONTH(borrowed_date) AS month, YEAR(borrowed_date) AS year, book.title, COUNT(*) AS count FROM borrow " +
                                   "JOIN bookitem ON borrow.book_item_id = bookitem.book_item_id " +
                                   "JOIN book ON bookitem.book_isbn = book.isbn " +
                                   "WHERE 1=1 ";
                if (monthFilter != null && !monthFilter.isEmpty()) sqlBorrow += " AND MONTH(borrowed_date) = " + monthFilter;
                if (yearFilter != null && !yearFilter.isEmpty()) sqlBorrow += " AND YEAR(borrowed_date) = " + yearFilter;
                sqlBorrow += " GROUP BY YEAR(borrowed_date), MONTH(borrowed_date), book.title ORDER BY year DESC, month ASC";

                ResultSet rsBorrow = conn.createStatement().executeQuery(sqlBorrow);
                int totalBorrows = 0;
        %>
                <div class="report-section">
                    <h2>Báo cáo mượn sách</h2>
                    <table class="table">
                        <tr><th>Tháng</th><th>Năm</th><th>Tên sách</th><th>Số lượt mượn</th></tr>
                        <% while (rsBorrow.next()) { 
                            totalBorrows += rsBorrow.getInt("count");
                        %>
                        <tr>
                            <td><%= rsBorrow.getInt("month") %></td>
                            <td><%= rsBorrow.getInt("year") %></td>
                            <td><%= rsBorrow.getString("title") %></td>
                            <td><%= rsBorrow.getInt("count") %></td>
                        </tr>
                        <% } %>
                        <tr class="total-row">
                            <td colspan="3">Tổng cộng:</td>
                            <td><%= totalBorrows %></td>
                        </tr>
                    </table>
                </div>
        <% } conn.close(); %>
    </div>
</body>
</html>
