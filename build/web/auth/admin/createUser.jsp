<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, Data.Users, Servlet.DBConnection" %>

<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1)) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
%>
<html>
<head>
    <title>Quản lý Người Dùng - Admin</title>
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <link rel="stylesheet" href="./CSS/admin1.css">
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <script src="./JS/admin.js"></script>
    <style>
        /* NAVBAR */
        .navbar-am {
            padding: 10px 0;
            text-align: center;
            background-color: #ddd;
            
        }

        .navbar-am button {
            background: none;
            border: none;
            font-size: 16px;
            padding: 14px 20px;
            cursor: pointer;
            transition: background 0.3s ease-in-out;
            
        }

        .navbar-am button:hover {
            background-color: #0056b3;
            border-radius: 5px;
        }

        /* TABLE STYLES */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: center;
        }

        th {
            background-color: #007bff;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        /* BUTTON STYLES */
        button {
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }

        button[name="action"][value="approve"] {
            background-color: #28a745;
            color: white;
        }

        button[name="action"][value="approve"]:hover {
            background-color: #218838;
        }

        button[name="action"][value="reject"] {
            background-color: #dc3545;
            color: white;
        }

        button[name="action"][value="reject"]:hover {
            background-color: #c82333;
        }

    </style>
    <script>
        function showSection(sectionId) {
            document.querySelectorAll('.content-section').forEach(section => {
                section.style.display = 'none';
            });
            document.getElementById(sectionId).style.display = 'block';
        }

        // Mặc định hiển thị phần "Tạo tài khoản"
        window.onload = function () {
            showSection('manageUsersSection');
        };
    </script>
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
            <li><a href="createUser.jsp">Quản lý người dùng</a></li>
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
            <div class="navbar-am">
            <button onclick="showSection('manageUsersSection')">📋 Quản lý người dùng</button>
            <button onclick="showSection('createUserSection')">➕ Tạo tài khoản</button>
            <button onclick="showSection('approveUsersSection')">✅ Duyệt tài khoản</button>
        </div>
        <!-- Quản lý người dùng -->
        <div id="manageUsersSection" class="content-section">
            <h2> Quản lý Người Dùng</h2>
            <table border="1">
                <tr>
                    <th>ID</th>
                    <th>Tên người dùng</th>
                    <th>Vai trò</th>
                    <th>Trạng thái</th>
                    <th>Ngày hết hạn</th>
                </tr>
                <% 
                    Connection conn = null;
                    PreparedStatement stmt1 = null;
                    ResultSet rs = null;

                    try {
                        conn = DBConnection.getConnection();
                        stmt1 = conn.prepareStatement("SELECT id, username, roleID, status, expiryDate FROM users");
                        rs = stmt1.executeQuery();

                        while (rs.next()) { 
                %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("username") %></td>
                    <td>
                        <%= (rs.getInt("roleID") == 1) ? "Admin" : (rs.getInt("roleID") == 2) ? "Librarian" : "Member" %>
                    </td>
                    <td><%= rs.getString("status") %></td>
                    <td>
                        <% 
                            String expiryDate = rs.getString("expiryDate");
                            out.print((expiryDate == null || expiryDate.isEmpty()) ? "Vĩnh viễn" : expiryDate);
                        %>
                    </td>
                </tr>
                <% 
                        }
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Lỗi lấy danh sách người dùng: " + e.getMessage() + "</p>");
                    } finally {
                        if (rs != null) rs.close();
                        if (stmt1 != null) stmt1.close();
                        if (conn != null) conn.close();
                    }
                %>
            </table>
        </div>

        <!-- Tạo tài khoản -->
        <div id="createUserSection" class="content-section active">
            <h2>Tạo Người Dùng Mới</h2>
            <form class="form" action="AddUserServlet" method="post">
                <label for="username">Tên người dùng:</label>
                <input type="text" id="username" name="username" placeholder="Nhập tên đăng nhập" required>

                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" name="password" placeholder="Nhập mật khẩu" required>

                <label for="roleID">Chọn vai trò:</label>
                <select id="roleID" name="roleID" required>
                    <option value="1">Admin</option>
                    <option value="2">Librarian</option>
                    <option value="3">Member</option>
                </select>

                <button class="btn" type="submit">Thêm Người Dùng</button>
            </form>
        </div>

        <!-- Duyệt đơn đăng ký -->
        <div id="approveUsersSection" class="content-section">
            <h2>✅ Duyệt Đơn Đăng Ký</h2>
            <table border="1">
                <tr>
                    <th>ID</th>
                    <th>Tên người dùng</th>
                    <th>Thao tác</th>
                </tr>
                <% 
                    Connection conn2 = null;
                    PreparedStatement stmt2 = null;
                    ResultSet rsPending = null;

                    try {
                        conn2 = DBConnection.getConnection(); // Mở kết nối mới
                        stmt2 = conn2.prepareStatement("SELECT id, username FROM users WHERE status = 'PENDING'");
                        rsPending = stmt2.executeQuery();

                        while (rsPending.next()) { 
                %>
                <tr>
                    <td><%= rsPending.getInt("id") %></td>
                    <td><%= rsPending.getString("username") %></td>
                    <td>
                        <form action="ApproveUserServlet" method="post" style="display:inline;">
                            <input type="hidden" name="userID" value="<%= rsPending.getInt("id") %>">
                            <button type="submit" name="action" value="approve">Duyệt</button>
                        </form>
                        <form action="ApproveUserServlet" method="post" style="display:inline;">
                            <input type="hidden" name="userID" value="<%= rsPending.getInt("id") %>">
                            <button type="submit" name="action" value="reject" style="background:red;color:white;">Từ chối</button>
                        </form>
                    </td>
                </tr>
                <% 
                        }
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Lỗi lấy danh sách tài khoản chờ duyệt: " + e.getMessage() + "</p>");
                    } finally {
                        if (rsPending != null) rsPending.close();
                        if (stmt2 != null) stmt2.close();
                        if (conn2 != null) conn2.close(); // Đóng kết nối mới
                    }
                %>
            </table>
        </div>

    </div>
</body>
</html>