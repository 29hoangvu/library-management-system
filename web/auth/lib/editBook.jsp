<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="Data.Users, Servlet.DBConnection" %>
<%
    Users user = (Users) session.getAttribute("user");

    // Kiểm tra nếu chưa đăng nhập hoặc không có quyền truy cập
    if (user == null || (user.getRoleID() != 1 && user.getRoleID() != 2)) {
        response.sendRedirect("index.jsp"); // Chuyển về trang chính nếu không có quyền
        return;
    }   
%>
<% 
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DBConnection.getConnection();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<%
    String isbn = request.getParameter("isbn");
    if (isbn == null || isbn.isEmpty()) {
        response.sendRedirect("bookList.jsp");
        return;
    }

    String title = "", subject = "", publisher = "", language = "", format = "", summary = "", description = "";
    int publicationYear = 0, numberOfPages = 0, quantity = 0;
    List<Integer> currentAuthors = new ArrayList<>();
    Map<Integer, String> allAuthors = new HashMap<>();
    int authorID = 0;
    String authorName = "";
    try {
        String query = "SELECT b.*, d.description FROM book b LEFT JOIN book_description d ON b.isbn = d.isbn WHERE b.isbn = ?";
        stmt = conn.prepareStatement(query);
        stmt.setString(1, isbn);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            title = rs.getString("title");
            subject = rs.getString("subject");
            publisher = rs.getString("publisher");
            publicationYear = rs.getInt("publicationYear");
            language = rs.getString("language");
            numberOfPages = rs.getInt("numberOfPages");
            format = rs.getString("format");
            quantity = rs.getInt("quantity");
            description = rs.getString("description") != null ? rs.getString("description") : "";
        } else {
            response.sendRedirect("bookList.jsp");
            return;
        }

        String authorQuery = "SELECT a.id, a.name FROM author a JOIN book b ON a.id = b.authorID WHERE b.isbn = ?";
        stmt = conn.prepareStatement(authorQuery);
        stmt.setString(1, isbn);
        rs = stmt.executeQuery();
        if (rs.next()) {
            authorID = rs.getInt("id");
            authorName = rs.getString("name");
        }
        rs.close();
        stmt.close();
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>Lỗi: " + e.getMessage() + "</p>");
    }
%>

<html>
<head>
    <title>Chỉnh sửa thông tin sách</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link rel="stylesheet" href="./CSS/navbar.css">
    <script src="./JS/admin.js"></script>
    <link rel="stylesheet" href="./CSS/ad_menu.css">
    <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />
    <style>      
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        .container {
            width: 60%;
            margin: auto;
            margin-top: 10px;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);
        }
        
        .book-details {
            display: flex;
            gap: 20px;
        }
        .book-image {
            width: 200px;
            height: 250px;
            border: 1px solid #ddd;
        }
        .book-info {
            flex: 1;
        }
        label {
            font-weight: bold;
            display: block;
            margin-top: 10px;
        }
        input, select, textarea {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .btn-save {
            background-color: #3498db;
            color: white;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            border: none;
            display: block;
            width: 100%;
            margin-top: 20px;
            font-size: 16px;
        }
        .header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .btn-back {
            background-color: #ccc;
            color: black;
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 14px;
        }

        .btn-back:hover {
            background-color: #bbb;
        }
        
    </style>
</head>
<body>
    <%
        String update = request.getParameter("update");
        String error = request.getParameter("error");
        
        if (format == null) {
            format = "Hardcover"; // Giá trị mặc định nếu format null
        }
        if ("success".equals(update)) {
    %>
        <script>
            alert("Cập nhật sách thành công!");
            window.location.href = "adminDashboard.jsp"; // Chuyển hướng về danh sách sách
        </script>
    <%
        } else if (error != null) {
            String decodedError = URLDecoder.decode(error, "UTF-8"); // Giải mã lỗi nếu cần
    %>
        <script>
            alert("Lỗi khi cập nhật sách: <%= decodedError %>");
        </script>
    <%
        }
    %>
    
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
    <div class="container">
        <div class="header-container">
            <a href="adminDashboard.jsp" class="btn-back">
                <i class="fa fa-arrow-left"></i>
            </a>
            <h2>Chỉnh sửa thông tin sách</h2>
        </div>
        <form action="UpdateBookServlet" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="isbn" value="<%= isbn %>">

            <div class="book-details">
                <!-- Ảnh sách bên trái -->
                <div>
                    <img src="ImageServlet?isbn=<%= isbn %>" class="book-image" alt="Ảnh bìa sách">
                    <label>Chọn ảnh mới</label>
                    <input type="file" name="coverImage" accept="image/*">
                </div>

                <!-- Thông tin sách bên phải -->
                <div class="book-info">
                    <label>Tiêu đề sách</label>
                    <input type="text" name="title" value="<%= title %>">

                    <label>Thể loại</label>
                    <input type="text" name="subject" value="<%= subject %>">
                    
                    <label>Tác giả</label>
                    <input type="text" name="authorName" id="authorName" list="authorList" value="<%= authorName%>" required>
                    <datalist id="authorList">
                    <%
                        if (conn != null) {
                            Statement stmt2 = conn.createStatement();
                            ResultSet rs2 = stmt2.executeQuery("SELECT id, name FROM Author");
                            while (rs2.next()) {
                    %>
                    <option value="<%= rs2.getString("name") %>" data-id="<%= rs2.getInt("id") %>"></option>
                    <%
                            }
                            rs2.close();
                            stmt2.close();
                            conn.close(); // Đóng kết nối
                        } else {
                            out.println("<option value='' disabled>Không thể tải danh sách tác giả</option>");
                        }
                    %>
                </datalist>
                    
                    <label>Nhà xuất bản</label>
                    <input type="text" name="publisher" value="<%= publisher %>">

                    <label>Năm xuất bản</label>
                    <input type="number" name="publicationYear" value="<%= publicationYear %>">

                    <label>Ngôn ngữ</label>
                    <input type="text" name="language" value="<%= language %>">

                    <label>Số trang</label>
                    <input type="number" name="numberOfPages" value="<%= numberOfPages %>">

                    <label>Định dạng</label>
                    <select name="format">
                        <option value="Hardcover" <%= "Hardcover".equals(format) ? "selected" : "" %>>Hardcover</option>
                        <option value="Paperback" <%= "Paperback".equals(format) ? "selected" : "" %>>Paperback</option>
                        <option value="Ebook" <%= "Ebook".equals(format) ? "selected" : "" %>>Ebook</option>
                    </select>

                    <label>Số lượng</label>
                    <input type="number" name="quantity" value="<%= quantity %>">
                </div>
            </div>

            <!-- Phần mô tả sách -->
            <label>Mô tả sách</label>
            <textarea name="description" rows="4"><%= description %></textarea>

            <button type="submit" class="btn-save">Lưu thay đổi</button>
        </form>
    </div>

</body>
</html>
