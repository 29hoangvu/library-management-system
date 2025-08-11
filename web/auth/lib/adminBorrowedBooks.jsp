<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, Servlet.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Data.Users" %>
<%
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat inputDateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<%
    request.setAttribute("pageTitle", "Quản lý sách - Admin");
%>
<%@ include file="../includes/header.jsp" %>
<main class="transition-all duration-300 pt-32" id="mainContent">
    <div class="min-h-screen bg-gray-50 p-6">
        <div class="max-w-7xl mx-auto">
            <!-- Header with Search -->
            <div class="mb-8">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900 mb-2">Quản lý Mượn/Trả Sách</h1>
                        <p class="text-gray-600">Theo dõi và quản lý tình trạng mượn/trả sách của người dùng</p>
                    </div>

                    <!-- Search Box moved to header -->
                    <div class="lg:max-w-md w-full lg:w-80">
                        <label for="searchInput" class="block text-sm font-medium text-gray-700 mb-2">
                            Tìm kiếm
                        </label>
                        <div class="relative">
                            <input type="text" 
                                   id="searchInput" 
                                   placeholder="Tìm theo tên người dùng hoặc tên sách..."
                                   class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Enhanced Filter Section -->
            <div class="bg-white rounded-xl shadow-lg p-6 mb-6 border border-gray-100">
                <!-- Date Filters -->
                <div class="mb-6">
                    <h4 class="text-sm font-medium text-gray-700 mb-3 flex items-center">
                        <svg class="w-4 h-4 mr-1 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                        Lọc theo ngày
                    </h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <!-- Borrowed Date Filter -->
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-gray-700">Ngày mượn từ</label>
                            <div class="relative">
                                <input type="date" 
                                       id="borrowedDateFrom" 
                                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 bg-white">
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-gray-700">Ngày mượn đến</label>
                            <div class="relative">
                                <input type="date" 
                                       id="borrowedDateTo" 
                                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 bg-white">
                            </div>
                        </div>

                        <!-- Due Date Filter -->
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-gray-700">Hạn trả từ</label>
                            <div class="relative">
                                <input type="date" 
                                       id="dueDateFrom" 
                                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 bg-white">
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-gray-700">Hạn trả đến</label>
                            <div class="relative">
                                <input type="date" 
                                       id="dueDateTo" 
                                       class="w-full px-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 bg-white">
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Status Filter and Action Buttons -->
                <div class="border-t border-gray-100 pt-6">
                    <div class="flex flex-col sm:flex-row gap-4 items-end">
                        <div class="flex-1 max-w-xs">
                            <label class="block text-sm font-medium text-gray-700 mb-2 flex items-center">
                                <svg class="w-4 h-4 mr-1 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                Trạng thái
                            </label>
                            <select id="statusFilter" class="w-full px-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition duration-200 bg-white">
                                <option value="">Tất cả trạng thái</option>
                                <option value="Borrowed">Đang mượn</option>
                                <option value="Overdue">Trễ hạn</option>
                                <option value="Returned">Đã trả</option>
                                <option value="Lost">Mất sách</option>
                            </select>
                        </div>

                        <div class="flex gap-3">
                            <button onclick="applyFilters()" 
                                    class="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-6 py-2.5 rounded-lg font-medium transition duration-200 shadow-sm hover:shadow-md transform hover:-translate-y-0.5 flex items-center gap-2">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                </svg>
                                Áp dụng
                            </button>
                            <button onclick="clearFilters()" 
                                    class="bg-gradient-to-r from-gray-500 to-gray-600 hover:from-gray-600 hover:to-gray-700 text-white px-6 py-2.5 rounded-lg font-medium transition duration-200 shadow-sm hover:shadow-md transform hover:-translate-y-0.5 flex items-center gap-2">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                </svg>
                                Xóa bộ lọc
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Books Table -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead class="bg-gradient-to-r from-gray-50 to-gray-100 border-b border-gray-200">
                            <tr>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Người Mượn</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sách</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ISBN</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ngày Mượn</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Hạn Trả</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ngày Trả</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trạng Thái</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tiền Phạt</th>
                            <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="bg-white divide-y divide-gray-200">
                            <%
                                Connection conn = null;
                                Statement stmt = null;
                                ResultSet rs = null;

                                try {
                                    conn = DBConnection.getConnection();
                                    stmt = conn.createStatement();
                                    String sql = "SELECT b.borrow_id, u.username, bk.title, bk.isbn, "
                                            + "b.borrowed_date, b.due_date, b.return_date, "
                                            + "b.status, b.fine_amount, b.book_item_id "
                                            + "FROM borrow b "
                                            + "JOIN users u ON b.user_id = u.id "
                                            + "JOIN bookitem bi ON b.book_item_id = bi.book_item_id "
                                            + "JOIN book bk ON bi.book_isbn = bk.isbn "
                                            + "WHERE b.status != 'Pending Approval' "
                                            + "ORDER BY b.borrow_id DESC";

                                    rs = stmt.executeQuery(sql);
                                    boolean hasData = false;

                                    while (rs.next()) {
                                        hasData = true;
                                        String status = rs.getString("status");
                                        String statusText = "";
                                        String statusClass = "";

                                        // Improved status mapping with CSS classes
                                        switch (status) {
                                            case "Borrowed":
                                                statusText = "Đang mượn";
                                                statusClass = "bg-blue-100 text-blue-800";
                                                break;
                                            case "Overdue":
                                                statusText = "Trễ hạn";
                                                statusClass = "bg-red-100 text-red-800";
                                                break;
                                            case "Returned":
                                                statusText = "Đã trả";
                                                statusClass = "bg-green-100 text-green-800";
                                                break;
                                            case "Lost":
                                                statusText = "Mất sách";
                                                statusClass = "bg-gray-100 text-gray-800";
                                                break;
                                            default:
                                                statusText = status;
                                                statusClass = "bg-gray-100 text-gray-800";
                                        }

                                        // Date formatting with null checks
                                        java.sql.Date borrowedDate = rs.getDate("borrowed_date");
                                        java.sql.Date dueDate = rs.getDate("due_date");
                                        java.sql.Date returnDate = rs.getDate("return_date");

                                        String borrowedDateStr = (borrowedDate != null) ? dateFormat.format(borrowedDate) : "N/A";
                                        String dueDateStr = (dueDate != null) ? dateFormat.format(dueDate) : "N/A";
                                        String returnDateStr = (returnDate != null) ? dateFormat.format(returnDate) : "Chưa trả";

                                        // ISO format for filtering
                                        String borrowedDateISO = (borrowedDate != null) ? borrowedDate.toString() : "";
                                        String dueDateISO = (dueDate != null) ? dueDate.toString() : "";
                                        String returnDateISO = (returnDate != null) ? returnDate.toString() : "";

                                        // Fine amount handling
                                        double fineAmount = 0;
                                        if (rs.getObject("fine_amount") != null) {
                                            fineAmount = rs.getDouble("fine_amount");
                                        }
                            %>
                            <tr class="hover:bg-gray-50 transition duration-150 table-row" 
                                data-username="<%= rs.getString("username").toLowerCase()%>"
                                data-title="<%= rs.getString("title").toLowerCase()%>"
                                data-status="<%= status%>"
                                data-borrowed-date="<%= borrowedDateISO%>"
                                data-due-date="<%= dueDateISO%>"
                                data-return-date="<%= returnDateISO%>">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <%= rs.getString("username")%>
                            </td>
                            <td class="px-6 py-4 text-sm text-gray-900 max-w-xs truncate" title="<%= rs.getString("title")%>">
                                <%= rs.getString("title")%>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 font-mono">
                                <%= rs.getString("isbn")%>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <%= borrowedDateStr%>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <%= dueDateStr%>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <%= returnDateStr%>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap">
                            <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full <%= statusClass%>">
                                <%= statusText%>
                            </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm">
                                <% if (fineAmount > 0) {%>
                            <span class="text-red-600 font-semibold">
                                <%= String.format("%,.0f", fineAmount)%> VNĐ
                            </span>
                            <% } else { %>
                            <span class="text-gray-400">0 VNĐ</span>
                            <% } %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <% if (status.equals("Borrowed") || status.equals("Overdue")) {%>
                            <button onclick="confirmReturn(<%= rs.getInt("borrow_id")%>)" 
                                    class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition duration-200 shadow-sm hover:shadow-md transform hover:-translate-y-0.5">
                                Xác nhận Trả
                            </button>
                            <% } else if (status.equals("Returned")) { %>
                            <span class="text-green-600 text-sm font-medium">Đã hoàn thành</span>
                            <% } else { %>
                            <span class="text-gray-400 text-sm">Không có thao tác</span>
                            <% } %>
                            </td>
                            </tr>
                            <%
                                }

                                if (!hasData) {
                            %>
                            <tr id="noDataRow">
                            <td colspan="10" class="px-6 py-12 text-center text-gray-500">
                                <div class="flex flex-col items-center">
                                    <svg class="w-12 h-12 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253z"></path>
                                    </svg>
                                    <p class="text-lg font-medium">Không có dữ liệu mượn/trả sách</p>
                                    <p class="text-sm">Chưa có giao dịch mượn/trả sách nào được ghi nhận</p>
                                </div>
                            </td>
                            </tr>
                            <%
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            %>
                            <tr>
                            <td colspan="10" class="px-6 py-12 text-center text-red-500">
                                <div class="flex flex-col items-center">
                                    <svg class="w-12 h-12 text-red-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                    <p class="text-lg font-medium">Lỗi kết nối cơ sở dữ liệu</p>
                                    <p class="text-sm">Không thể tải dữ liệu. Vui lòng thử lại sau.</p>
                                </div>
                            </td>
                            </tr>
                            <%
                                } finally {
                                    // Proper resource cleanup
                                    if (rs != null) try {
                                        rs.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                    if (stmt != null) try {
                                        stmt.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                    if (conn != null) try {
                                        conn.close();
                                    } catch (SQLException e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- No Results Message (Hidden by default) -->
            <div id="noResultsMessage" class="bg-white rounded-xl shadow-lg p-12 text-center text-gray-500 hidden border border-gray-100">
                <svg class="w-12 h-12 text-gray-300 mb-4 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
                <p class="text-lg font-medium">Không tìm thấy kết quả</p>
                <p class="text-sm">Thử điều chỉnh từ khóa tìm kiếm hoặc bộ lọc</p>
            </div>
        </div>
    </div>

    <script>
        // Store original rows for filtering
        let originalRows = [];

        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function () {
            // Store original table rows
            const rows = document.querySelectorAll('.table-row');
            originalRows = Array.from(rows);

            // Add event listeners
            document.getElementById('searchInput').addEventListener('input', applyFilters);
            document.getElementById('statusFilter').addEventListener('change', applyFilters);

            // Add event listeners for date filters
            ['borrowedDateFrom', 'borrowedDateTo', 'dueDateFrom', 'dueDateTo'].forEach(id => {
                document.getElementById(id).addEventListener('change', applyFilters);
            });
        });

        function applyFilters() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const statusFilter = document.getElementById('statusFilter').value;
            const borrowedDateFrom = document.getElementById('borrowedDateFrom').value;
            const borrowedDateTo = document.getElementById('borrowedDateTo').value;
            const dueDateFrom = document.getElementById('dueDateFrom').value;
            const dueDateTo = document.getElementById('dueDateTo').value;

            let visibleCount = 0;

            originalRows.forEach(row => {
                let showRow = true;

                // Search filter
                if (searchTerm) {
                    const username = row.dataset.username || '';
                    const title = row.dataset.title || '';
                    if (!username.includes(searchTerm) && !title.includes(searchTerm)) {
                        showRow = false;
                    }
                }

                // Status filter
                if (statusFilter && row.dataset.status !== statusFilter) {
                    showRow = false;
                }

                // Borrowed date filter
                if (borrowedDateFrom && row.dataset.borrowedDate) {
                    if (row.dataset.borrowedDate < borrowedDateFrom) {
                        showRow = false;
                    }
                }
                if (borrowedDateTo && row.dataset.borrowedDate) {
                    if (row.dataset.borrowedDate > borrowedDateTo) {
                        showRow = false;
                    }
                }

                // Due date filter
                if (dueDateFrom && row.dataset.dueDate) {
                    if (row.dataset.dueDate < dueDateFrom) {
                        showRow = false;
                    }
                }
                if (dueDateTo && row.dataset.dueDate) {
                    if (row.dataset.dueDate > dueDateTo) {
                        showRow = false;
                    }
                }

                // Show/hide row
                if (showRow) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            // Show/hide no results message
            const noResultsMessage = document.getElementById('noResultsMessage');
            const tableContainer = document.querySelector('.bg-white.rounded-xl.shadow-lg.overflow-hidden');

            if (visibleCount === 0 && originalRows.length > 0) {
                tableContainer.style.display = 'none';
                noResultsMessage.classList.remove('hidden');
            } else {
                tableContainer.style.display = '';
                noResultsMessage.classList.add('hidden');
            }
        }

        function clearFilters() {
            // Clear all filter inputs
            document.getElementById('searchInput').value = '';
            document.getElementById('statusFilter').value = '';
            document.getElementById('borrowedDateFrom').value = '';
            document.getElementById('borrowedDateTo').value = '';
            document.getElementById('dueDateFrom').value = '';
            document.getElementById('dueDateTo').value = '';

            // Show all rows
            originalRows.forEach(row => {
                row.style.display = '';
            });

            // Hide no results message
            const noResultsMessage = document.getElementById('noResultsMessage');
            const tableContainer = document.querySelector('.bg-white.rounded-xl.shadow-lg.overflow-hidden');
            tableContainer.style.display = '';
            noResultsMessage.classList.add('hidden');
        }

        function confirmReturn(borrowId) {
            if (confirm("Bạn có chắc muốn xác nhận trả sách không?")) {
                fetch('ReturnBookServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'id=' + borrowId
                })
                        .then(response => response.json())
                        .then(data => {
                            alert(data.message);
                            window.location.href = data.redirect;
                        })
                        .catch(err => {
                            alert("Lỗi khi xác nhận trả sách.");
                            console.error(err);
                        });
            }
        }
    </script>                  
</body>
</html>