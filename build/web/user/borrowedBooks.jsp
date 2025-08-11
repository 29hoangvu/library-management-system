<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>

<%
    Connection conn = DBConnection.getConnection();
    if (conn == null) {
        out.println("<p>Lỗi kết nối CSDL</p>");
        return;
    }

    Users user = (Users) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    int userId = user.getId();
    List<Map<String, String>> borrowedBooks = new ArrayList<>();

    try {
        String query = "SELECT br.borrow_id, b.isbn, b.title, br.borrowed_date, br.due_date, br.return_date, br.status " +
                       "FROM borrow br " +
                       "JOIN bookitem bi ON br.book_item_id = bi.book_item_id " +
                       "JOIN book b ON bi.book_isbn = b.isbn " +
                       "WHERE br.user_id = ?";
        PreparedStatement stmt = conn.prepareStatement(query);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, String> book = new HashMap<>();
            book.put("borrow_id", rs.getString("borrow_id")); // Lấy borrow_id để hủy đăng ký
            book.put("isbn", rs.getString("isbn"));
            book.put("title", rs.getString("title"));
            book.put("borrowed_date", rs.getString("borrowed_date"));
            book.put("due_date", rs.getString("due_date"));
            book.put("return_date", rs.getString("return_date") == null ? "Chưa trả" : rs.getString("return_date"));

            String status = rs.getString("status");

            book.put("status", status);
            borrowedBooks.add(book);
        }

        rs.close();
        stmt.close();
    } catch (SQLException e) {
        out.println("<p>Lỗi truy vấn dữ liệu: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
    <title>Sách đã mượn</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="./CSS/home.css">
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <script src="./JS/home.js"></script> 
    <style>
        table { width: 100%; border-collapse: collapse;}
        th, td { padding: 10px; border: 1px solid #ddd; }
        th { background-color: #007bff; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .status { font-weight: bold; }
        .status.waiting { color: orange; }
        .status.borrowed { color: green; }
        .status.overdue { color: red; }
        .status.returned { color: blue; }
        .cancel-btn { background-color: red; color: white; border: none; padding: 5px 10px; cursor: pointer; }
        .h1{
            float: left; 
            margin-right: 10%;
            margin-left: 10px;
            font-size: 2.5rem;
            margin-top: 15px;
            color: #fff;
            background: url('./images/nen2.jpg') center;
            background-size: cover;
            background-clip: text;
            color: transparent;
            animation: animate 10s linear infinite;
        }
        @keyframes animate{
            to{
                background-position-x: -200px;
            }
        }
    </style>
    <script>
        function confirmCancel(borrowId) {
            if (confirm("Bạn có chắc chắn muốn hủy đăng ký mượn sách này?")) {
                window.location.href = "CancelBorrowServlet?borrow_id=" + borrowId;
            }
        }
    </script>
</head>
<body>

<div class="container">
    <div class="header">
            <a href="index.jsp">
                <h1 class="h1">LIBRARY</h1>
            </a>
            <form action="index.jsp" method="get" class="search-form">
                <input type="text" name="search" placeholder="Tìm sách theo tên hoặc tác giả..." 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button type="submit">Tìm kiếm</button>
            </form>
            <div class="user-menu" style="float: right; position: relative;">
                <%
                    if (user != null) {
                        String avatarUrl = "AvatarServlet?userId=" + user.getId();
                        String defaultAvatar = "./images/default-avatar.png"; // Ảnh mặc định
                %>
                    <div class="dropdown">
                        <img src="<%= avatarUrl %>" onerror="this.onerror=null; this.src='<%= defaultAvatar %>';" 
                             alt="Avatar" class="avatar" onclick="toggleDropdown()">
                        <div class="dropdown-content" id="userDropdown">
                            <div class="user-info">
                                <img src="<%= avatarUrl %>" onerror="this.onerror=null; this.src='<%= defaultAvatar %>';" 
                                     alt="Avatar" class="avatar-large">
                                <p><%= user.getUsername() %></p>
                            </div>
                            <a href="profile.jsp">Xem thông tin</a>
                            <a href="borrowedBooks.jsp">Sách đã mượn</a>
                            <a href="LogOutServlet">Đăng xuất</a>
                        </div>
                    </div>
                <%
                    } else {
                %>
                    <a href="login.jsp" class="btn-login" title="Đăng nhập">
                        <i class="fas fa-sign-in-alt"></i>
                    </a>
                <%
                    }
                %>
            </div>
        </div>
    <div class="menu">          
            <div class="menu-navbar">
                <ul>
                    <li><a href="#hardcover">Sách Bìa Cứng</a></li>
                    <li><a href="#paperback">Sách Bìa Mềm</a></li>
                    <li><a href="#ebook">Ebook</a></li>
                </ul>
            </div>   
        </div>
        
        <div class="content">
            <h2>Sách đã mượn</h2>
        <table>
            <thead>
                <tr>
                    <th>ISBN</th>
                    <th>Tên sách</th>
                    <th>Ngày mượn</th>
                    <th>Hạn trả</th>
                    <th>Ngày trả</th>
                    <th>Trạng thái</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, String> book : borrowedBooks) { 
                    String status = book.get("status");
                    String statusClass = "waiting"; // Mặc định là "Chờ duyệt"
                    String statusText = "Chờ duyệt"; // Hiển thị tiếng Việt

                    if ("Pending Approval".equals(status)) {
                        statusClass = "waiting";
                        statusText = "Chờ duyệt";
                    } else if ("Borrowed".equals(status)) {
                        statusClass = "borrowed";
                        statusText = "Đang mượn";
                    } else if ("Overdue".equals(status)) {
                        statusClass = "overdue";
                        statusText = "Quá hạn";
                    } else if ("Returned".equals(status)) {
                        statusClass = "returned";
                        statusText = "Đã trả";
                    }
                %>
                    <tr>
                        <td><%= book.get("isbn") %></td>
                        <td><%= book.get("title") %></td>
                        <td><%= book.get("borrowed_date") %></td>
                        <td><%= book.get("due_date") %></td>
                        <td><%= book.get("return_date") %></td>
                        <td class="status <%= statusClass %>"><%= statusText %></td>
                        <td>
                            <% if ("Pending Approval".equals(status)) { %>
                                <button class="cancel-btn" onclick="confirmCancel('<%= book.get("borrow_id") %>')">Hủy</button>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    <div class="footer">
        <p>Bản quyền &copy; 2025 - Thư viện sách</p>
    </div>
    
</div>

</body>
</html>
