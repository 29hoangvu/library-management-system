<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="Data.Users" %>
<%
    request.setAttribute("pageTitle", "Quản lý sách - Admin");
%>
<%
    // Đặt biến pagination vào request (sẽ được sử dụng trong searchBook.jspf)
    int dashboardCurrentPage = 1;
    if (request.getParameter("page") != null) {
        try {
            dashboardCurrentPage = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            dashboardCurrentPage = 1;
        }
    }
    int dashboardBooksPerPage = 20;
    request.setAttribute("currentPage", dashboardCurrentPage);
    request.setAttribute("booksPerPage", dashboardBooksPerPage);
%>
<%@ include file="../includes/header.jsp" %>
<%
    // Lấy dữ liệu sau khi searchBook.jspf đã xử lý
    @SuppressWarnings(
    
    "unchecked")
    List<Map<String, Object>> books = (List<Map<String, Object>>) request.getAttribute("books");
    if (books == null) {
        books = new ArrayList<>();
    }

    Integer totalBooksAttr = (Integer) request.getAttribute("totalBooks");
    int totalBooks = (totalBooksAttr != null) ? totalBooksAttr : 0;
    int totalPages = (int) Math.ceil((double) totalBooks / dashboardBooksPerPage);
%>
<main class="transition-all duration-300 pt-32" id="mainContent">
    <div class="container mx-auto px-4 py-6">
        <!-- Table Container -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ISBN</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tên sách</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tác giả</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Kệ sách</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Số lượng</th>
                        <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% for (Map<String, Object> book : books) {%>
                        <tr class="hover:bg-gray-50 transition-colors duration-200">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                            <%= book.get("isbn")%>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= book.get("title")%>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <%= book.get("author")%>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <%= book.get("rack")%>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                            <%= book.get("quantity")%>
                        </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-center text-sm font-medium">
                            <div class="flex justify-center space-x-2">
                                <a href="editBook.jsp?isbn=<%= book.get("isbn")%>" 
                                   class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200">
                                    <i class="fas fa-edit mr-1"></i>
                                    Sửa
                                </a>
                                <a href="DeleteBookServlet?isbn=<%= book.get("isbn")%>" 
                                   class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors duration-200"
                                   onclick="return confirm('Bạn có chắc muốn xóa sách này không?');">
                                    <i class="fas fa-trash-alt mr-1"></i>
                                    Xóa
                                </a>
                            </div>
                        </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Empty State -->
            <% if (books.isEmpty()) { %>
            <div class="text-center py-12">
                <div class="text-gray-400 mb-4">
                    <i class="fas fa-book-open text-6xl"></i>
                </div>
                <h3 class="text-lg font-medium text-gray-900 mb-2">Không có sách nào</h3>
                <p class="text-gray-500">Chưa có sách nào trong hệ thống hoặc không tìm thấy kết quả phù hợp.</p>
            </div>
            <% } %>
        </div>

        <!-- Pagination -->
        <% if (totalPages > 1) { %>
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6 mt-4 rounded-lg shadow">
            <div class="flex-1 flex justify-between sm:hidden">
                <% if (dashboardCurrentPage > 1) {%>
                <a href="adminDashboard.jsp?page=<%= dashboardCurrentPage - 1%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                   class="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                    Trước
                </a>
                <% } %>
                <% if (dashboardCurrentPage < totalPages) {%>
                <a href="adminDashboard.jsp?page=<%= dashboardCurrentPage + 1%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                   class="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                    Tiếp
                </a>
                <% }%>
            </div>

            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700">
                        Hiển thị 
                    <span class="font-medium"><%= ((dashboardCurrentPage - 1) * dashboardBooksPerPage) + 1%></span>
                    đến 
                    <span class="font-medium"><%= Math.min(dashboardCurrentPage * dashboardBooksPerPage, totalBooks)%></span>
                    trong tổng số 
                    <span class="font-medium"><%= totalBooks%></span>
                    kết quả
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                        <!-- Previous Page Link -->
                        <% if (dashboardCurrentPage > 1) {%>
                        <a href="adminDashboard.jsp?page=<%= dashboardCurrentPage - 1%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                           class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Trang trước</span>
                            <i class="fas fa-chevron-left h-5 w-5" aria-hidden="true"></i>
                        </a>
                        <% } else { %>
                        <span class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-gray-100 text-sm font-medium text-gray-400 cursor-not-allowed">
                            <i class="fas fa-chevron-left h-5 w-5" aria-hidden="true"></i>
                        </span>
                        <% } %>

                        <!-- Page Numbers -->
                        <%
                            int startPage = Math.max(1, dashboardCurrentPage - 2);
                            int endPage = Math.min(totalPages, dashboardCurrentPage + 2);

                            if (startPage > 1) {%>
                        <a href="adminDashboard.jsp?page=1&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                           class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                            1
                        </a>
                        <% if (startPage > 2) { %>
                        <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">...</span>
                        <% } %>
                        <% } %>

                        <% for (int i = startPage; i <= endPage; i++) { %>
                        <% if (i == dashboardCurrentPage) {%>
                        <span class="z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium">
                            <%= i%>
                        </span>
                        <% } else {%>
                        <a href="adminDashboard.jsp?page=<%= i%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                           class="bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium">
                            <%= i%>
                        </a>
                        <% } %>
                        <% } %>

                        <% if (endPage < totalPages) { %>
                        <% if (endPage < totalPages - 1) { %>
                        <span class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">...</span>
                        <% }%>
                        <a href="adminDashboard.jsp?page=<%= totalPages%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                           class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50">
                            <%= totalPages%>
                        </a>
                        <% } %>

                        <!-- Next Page Link -->
                        <% if (dashboardCurrentPage < totalPages) {%>
                        <a href="adminDashboard.jsp?page=<%= dashboardCurrentPage + 1%>&search=<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>" 
                           class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Trang sau</span>
                            <i class="fas fa-chevron-right h-5 w-5" aria-hidden="true"></i>
                        </a>
                        <% } else { %>
                        <span class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-gray-100 text-sm font-medium text-gray-400 cursor-not-allowed">
                            <i class="fas fa-chevron-right h-5 w-5" aria-hidden="true"></i>
                        </span>
                        <% } %>
                    </nav>
                </div>
            </div>
        </div>
        <% }%>
    </div>
</main>
</body>
</html>