<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Sách theo thể loại</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body class="bg-gray-50 min-h-screen">
<%@ include file="layout/header.jsp" %>

<main class="container mx-auto px-4 py-10 mt-4">
<%
  request.setCharacterEncoding("UTF-8");
  String genreName = request.getParameter("name");
  if (genreName == null || genreName.trim().isEmpty()) {
%>
  <div class="bg-white rounded-2xl p-6 shadow text-red-600">Thiếu tham số <code>name</code> của thể loại.</div>
<%
  } else {
    // phân trang
    int size = 20;
    try { size = Math.max(1, Math.min(60, Integer.parseInt(request.getParameter("size")))); } catch(Exception ignore){}
    int pageNum = 1;
    try { pageNum = Math.max(1, Integer.parseInt(request.getParameter("page"))); } catch(Exception ignore){}
    int offset = (pageNum - 1) * size;


    // sắp xếp
    String sort = request.getParameter("sort"); // "newest" | "oldest" | "title" | "year"
    String orderBy = "b.id DESC";
    if ("oldest".equalsIgnoreCase(sort))      orderBy = "b.id ASC";
    else if ("title".equalsIgnoreCase(sort))  orderBy = "b.title ASC";
    else if ("year".equalsIgnoreCase(sort))   orderBy = "b.publicationYear DESC";

    int total = 0;
    int totalPages = 1;
    List<Map<String,Object>> books = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
      Integer gid = null;
      try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM genre WHERE name=?")) {
        ps.setString(1, genreName);
        try (ResultSet rs = ps.executeQuery()) { if (rs.next()) gid = rs.getInt(1); }
      }

      if (gid == null) {
%>
      <div class="bg-white rounded-2xl p-6 shadow text-red-600">Không tìm thấy thể loại: <strong><%= genreName %></strong></div>
<%
      } else {
        // Đếm tổng
        try (PreparedStatement ps = conn.prepareStatement(
          "SELECT COUNT(*) " +
          "FROM book b JOIN book_genre bg ON bg.book_id=b.id " +
          "WHERE bg.genre_id=?"
        )) {
          ps.setInt(1, gid);
          try (ResultSet rs = ps.executeQuery()) { if (rs.next()) total = rs.getInt(1); }
        }
        totalPages = Math.max(1, (total + size - 1) / size);

        // Lấy trang
        String sql =
          "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format, b.coverImage " +
          "FROM book b " +
          "JOIN book_genre bg ON bg.book_id = b.id " +
          "LEFT JOIN author a ON a.id = b.authorId " +
          "WHERE bg.genre_id = ? " +
          "ORDER BY " + orderBy + " " +
          "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
          ps.setInt(1, gid);
          ps.setInt(2, size);
          ps.setInt(3, offset);
          try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
              Map<String,Object> m = new HashMap<>();
              m.put("isbn", rs.getString("isbn"));
              m.put("title", rs.getString("title"));
              m.put("author", rs.getString("author"));
              m.put("year", rs.getInt("publicationYear"));
              m.put("format", rs.getString("format"));
              m.put("cover", rs.getString("coverImage"));
              books.add(m);
            }
          }
        }
%>

  <!-- Header -->
  <div class="mb-6 flex items-center justify-between">
    <div>
      <h1 class="text-3xl font-bold">Thể loại: <span class="text-emerald-600"><%= genreName %></span></h1>
      <p class="text-gray-500 mt-1">Tổng cộng <%= total %> tựa sách</p>
    </div>

    <form class="flex items-center gap-3" method="get" action="booksByGenre.jsp">
      <input type="hidden" name="name" value="<%= genreName %>">
      <input type="hidden" name="page" value="1">
      <label class="text-sm text-gray-600">Sắp xếp</label>
      <select name="sort" class="border rounded-lg px-3 py-2">
        <option value="newest" <%= "newest".equalsIgnoreCase(sort) || sort==null ? "selected":"" %>>Mới nhất</option>
        <option value="oldest" <%= "oldest".equalsIgnoreCase(sort) ? "selected":"" %>>Cũ nhất</option>
        <option value="title"  <%= "title".equalsIgnoreCase(sort)  ? "selected":"" %>>Theo tên</option>
        <option value="year"   <%= "year".equalsIgnoreCase(sort)   ? "selected":"" %>>Theo năm XB</option>
      </select>
      <label class="text-sm text-gray-600">Mỗi trang</label>
      <select name="size" class="border rounded-lg px-3 py-2">
        <option <%= size==12?"selected":"" %>>12</option>
        <option <%= size==20?"selected":"" %>>20</option>
        <option <%= size==40?"selected":"" %>>40</option>
        <option <%= size==60?"selected":"" %>>60</option>
      </select>
      <button class="bg-emerald-600 text-white px-4 py-2 rounded-lg">Áp dụng</button>
    </form>
  </div>

  <!-- List -->
  <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
    <% for (Map<String,Object> b : books) { %>
      <div class="rounded-3xl shadow hover:shadow-2xl bg-white overflow-hidden">
        <a class="block" href="./bookDetails.jsp?isbn=<%= b.get("isbn") %>">
          <div class="relative">
            <img src="<%= b.get("cover")==null?"images/default-cover.jpg":b.get("cover") %>"
                 onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                 class="w-full h-60 object-cover">
          </div>
          <div class="p-4">
            <h3 class="font-semibold line-clamp-2 mb-2"><%= b.get("title") %></h3>
            <div class="text-sm text-gray-600 flex items-center gap-2">
              <i class="fas fa-user-edit text-emerald-500"></i><span><%= b.get("author") %></span>
            </div>
            <div class="text-sm text-gray-600 flex items-center gap-2">
              <i class="fas fa-calendar text-emerald-500"></i><span><%= b.get("year") %></span>
            </div>
          </div>
        </a>
      </div>
    <% } %>
  </div>

  <!-- Pagination -->
  <div class="mt-8 flex items-center justify-center gap-2">
    <%
        String base = "booksByGenre.jsp?name="+java.net.URLEncoder.encode(genreName,"UTF-8")+"&sort="+(sort==null?"newest":sort)+"&size="+size+"&page=";
        int prev = Math.max(1, pageNum - 1);
        int next = Math.min(totalPages, pageNum + 1);

    %>
    <a class="px-3 py-2 rounded border <%= pageNum==1?"opacity-50 pointer-events-none":"" %>"
       href="<%= base + prev %>"><i class="fas fa-chevron-left"></i></a>
    <span class="px-3 py-2">Trang <strong><%= page %></strong>/<%= totalPages %></span>
    <a class="px-3 py-2 rounded border <%= pageNum==totalPages?"opacity-50 pointer-events-none":"" %>"
       href="<%= base + next %>"><i class="fas fa-chevron-right"></i></a>
  </div>

<%
      } // end gid found
    } catch (SQLException e) {
%>
  <div class="bg-white rounded-2xl p-6 shadow text-red-600">Lỗi: <%= e.getMessage() %></div>
<%
    }
  } // end else valid name
%>
</main>

<%@ include file="layout/footer.jsp" %>
</body>
</html>
