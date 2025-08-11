<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Servlet.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Data.Users" %>
<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp"); // Chuyển về trang chính nếu không có quyền
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý mượn sách</title>
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/table_ad.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/adminBorrowedBooks.js"></script>
    <script src="./JS/admin.js"></script>
    <script>
        function approveBorrow(borrowId, bookItemId) {
            if (confirm("Bạn có chắc chắn muốn duyệt yêu cầu mượn sách này?")) {
                window.location.href = "ApproveBorrowServlet?borrowId=" + borrowId + "&bookItemId=" + bookItemId;
            }
        }
    </script>
    <style>
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
        <table border="1">
            <tr>
                <th>Người mượn</th>
                <th>Tên sách</th>
                <th>ISBN</th>
                <th>Ngày mượn</th>
                <th>Ngày hết hạn</th>
                <th>Trạng thái</th>
                <th>Hành động</th>
            </tr>
            <%
                Connection conn = DBConnection.getConnection();
                String sql = "SELECT b.borrow_id, u.username, bk.title, bk.isbn, b.borrowed_date, b.due_date, b.status, b.book_item_id " +
                             "FROM borrow b " +
                             "JOIN users u ON b.user_id = u.id " +
                             "JOIN bookitem bi ON b.book_item_id = bi.book_item_id " +
                             "JOIN book bk ON bi.book_isbn = bk.isbn " +  
                             "WHERE b.status = 'Pending Approval'";
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                String status = rs.getString("status");
                String statusVN = "";
                switch (status) {
                    case "Pending Approval":
                        statusVN = "Chờ duyệt";
                        break;
                    case "Approved":
                        statusVN = "Đã duyệt";
                        break;
                    case "Rejected":
                        statusVN = "Từ chối";
                        break;
                    case "Borrowed":
                        statusVN = "Đang mượn";
                        break;
                    case "Returned":
                        statusVN = "Đã trả";
                        break;
                    case "Overdue":
                        statusVN = "Quá hạn";
                        break;
                    default:
                        statusVN = "Không xác định";
                }
            %>
            <tr>
                <td><%= rs.getString("username") %></td>
                <td><%= rs.getString("title") %></td>
                <td><%= rs.getString("isbn") %></td>
                <td><%= rs.getDate("borrowed_date") %></td>
                <td><%= rs.getDate("due_date") %></td>
                <td><%= statusVN %></td>
                <td>
                    <button class="btn-edit" onclick="approveBorrow(<%= rs.getInt("borrow_id") %>, <%= rs.getInt("book_item_id") %>)">
                        Duyệt
                    </button>
                </td>
            </tr>
            <%
                }
                conn.close();
            %>
        </table>
    </div>
</body>
</html>
