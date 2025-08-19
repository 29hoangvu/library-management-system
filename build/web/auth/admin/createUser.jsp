<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="Data.Users" %>
<%
    Users user = (Users) session.getAttribute("user");
    if (user == null || user.getRoleID() != 1) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Tạo Người Dùng Mới</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 min-h-screen">
  <jsp:include page="../includes/header.jsp" />

  <div class="container mx-auto px-4 py-8">
    <!-- Nav -->
    <div class="bg-gradient-to-r from-indigo-500 to-purple-600 rounded-2xl p-6 mb-8 shadow-xl">
      <div class="flex flex-wrap justify-center gap-4">
        <a href="manageUsers.jsp" class="px-6 py-3 rounded-xl text-white hover:bg-white/20 font-semibold">📋 Quản lý người dùng</a>
        <a href="createUser.jsp" class="px-6 py-3 rounded-xl bg-white text-purple-600 font-semibold shadow-lg">➕ Tạo tài khoản</a>
        <a href="approveUsers.jsp" class="px-6 py-3 rounded-xl text-white hover:bg-white/20 font-semibold">✅ Duyệt tài khoản</a>
      </div>
    </div>

    <div class="bg-white rounded-2xl p-8 shadow-xl max-w-2xl mx-auto">
      <div class="flex items-center gap-3 mb-6">
        <span class="text-3xl">➕</span>
        <h2 class="text-2xl font-bold text-gray-800">Tạo Người Dùng Mới</h2>
      </div>

      <form action="../../AddUserServlet" method="post" class="space-y-6">
        <div class="space-y-2">
          <label class="block text-sm font-semibold text-gray-700">Tên người dùng</label>
          <input type="text" name="username" required
                 placeholder="Nhập tên đăng nhập"
                 class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-purple-500 focus:border-transparent">
        </div>

        <div class="space-y-2">
          <label class="block text-sm font-semibold text-gray-700">Mật khẩu</label>
          <input type="password" name="password" required
                 placeholder="Nhập mật khẩu"
                 class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-purple-500 focus:border-transparent">
        </div>

        <div class="space-y-2">
          <label class="block text-sm font-semibold text-gray-700">Chọn vai trò</label>
          <select name="roleID" required
                  class="w-full px-4 py-3 rounded-xl border border-gray-300 focus:ring-2 focus:ring-purple-500 focus:border-transparent">
            <option value="">-- Chọn vai trò --</option>
            <option value="1">👑 Admin</option>
            <option value="2">📚 Librarian</option>
            <option value="3">👤 Member</option>
          </select>
        </div>

        <button type="submit"
                class="w-full bg-gradient-to-r from-indigo-500 to-purple-600 text-white font-semibold py-3 px-6 rounded-xl hover:shadow-lg">
          ✨ Thêm Người Dùng
        </button>
      </form>
    </div>
  </div>
</body>
</html>
