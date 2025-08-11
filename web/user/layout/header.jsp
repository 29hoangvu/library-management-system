<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="Data.Users, java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>

<header class="bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 shadow-lg sticky top-0 z-50 backdrop-blur-sm bg-opacity-95">
    <!-- Header chính -->
    <div class="container mx-auto px-4 py-3">
        <div class="flex items-center justify-between">
            <!-- Logo và Title -->
            <div class="flex items-center space-x-4">
                <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center space-x-2 group">
                    <div class="w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300">
                        <i class="fas fa-book text-indigo-600 text-xl"></i>
                    </div>
                    <h1 class="text-2xl font-bold text-white tracking-wide hover:text-yellow-300 transition-colors duration-300">
                        LIBRARY
                    </h1>
                </a>
            </div>

            <!-- Search Form -->
            <div class="relative hidden md:flex flex-1 max-w-md mx-8">
                <form action="index.jsp" method="get" class="w-full">
                    <div class="relative">
                        <input type="text" 
                               id="searchInput"
                               name="search" 
                               placeholder="Tìm sách theo tên hoặc tác giả..." 
                               value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>"
                               class="w-full px-4 py-2 pr-12 rounded-full border-2 border-white/20 bg-white/10 text-white placeholder-white/70 focus:outline-none focus:border-white focus:bg-white/20 transition-all duration-300">
                        <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 text-white hover:text-yellow-300 transition-colors">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>

                <!-- Gợi ý kết quả -->
                <div id="suggestions" class="absolute top-full mt-2 w-full bg-white text-black rounded-md shadow-lg max-h-60 overflow-y-auto hidden z-50">
                    <% 
                        List<Map<String, Object>> suggestedBooks  = (List<Map<String, Object>>) request.getAttribute("books");
                        if (suggestedBooks != null) {
                            for (Map<String, Object> book : suggestedBooks ) {
                                String name = (String) book.get("name");
                                String cover = (String) book.get("coverImage");
                    %>
                    <div class="suggestion-item flex items-center gap-3 px-4 py-2 hover:bg-gray-100 cursor-pointer"
                         onclick="document.getElementById('searchInput').value = '<%= name %>'; document.querySelector('form').submit();">
                        <img src="<%= cover %>" alt="cover" class="w-10 h-14 object-cover rounded-sm border">
                        <span><%= name %></span>
                    </div>
                    <% }} %>
                </div>
            </div>

            <!-- User Menu và Filter Button -->
            <div class="flex items-center space-x-4">
                <!-- Filter Toggle Button -->
                <button id="filterToggle" class="text-white hover:text-yellow-300 transition-colors duration-300 relative">
                    <i class="fas fa-filter text-lg"></i>
                    <span class="hidden sm:inline ml-2">Lọc</span>
                </button>

                <!-- User Menu -->
                <div class="relative">
                    <%
                        Users user = (Users) session.getAttribute("user");
                        if (user != null) {
                            String avatarUrl = "AvatarServlet?userId=" + user.getId();
                            String defaultAvatar = "./images/default-avatar.png";
                    %>
                    <div class="relative">
                        <img src="<%= avatarUrl%>" 
                             onerror="this.onerror=null; this.src='<%= defaultAvatar%>';" 
                             alt="Avatar" 
                             class="w-10 h-10 rounded-full border-2 border-white/30 hover:border-white cursor-pointer transition-all duration-300 shadow-lg"
                             onclick="toggleUserDropdown()">
                        
                        <!-- User Dropdown -->
                        <div id="userDropdown" class="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-xl py-2 hidden transform opacity-0 scale-95 transition-all duration-200 origin-top-right">
                            <div class="px-4 py-3 border-b border-gray-200">
                                <div class="flex items-center space-x-3">
                                    <img src="<%= avatarUrl%>" 
                                         onerror="this.onerror=null; this.src='<%= defaultAvatar%>';" 
                                         alt="Avatar" 
                                         class="w-12 h-12 rounded-full">
                                    <div>
                                        <p class="font-semibold text-gray-800"><%= user.getUsername()%></p>
                                        <p class="text-sm text-gray-500">Thành viên</p>
                                    </div>
                                </div>
                            </div>
                            <a href="./user/profile.jsp" class="block px-4 py-2 text-gray-700 hover:bg-gray-100 transition-colors">
                                <i class="fas fa-user mr-2"></i>Xem thông tin
                            </a>
                            <a href="./user/borrowedBooks.jsp" class="block px-4 py-2 text-gray-700 hover:bg-gray-100 transition-colors">
                                <i class="fas fa-book-reader mr-2"></i>Sách đã mượn
                            </a>
                            <a href="LogOutServlet" class="block px-4 py-2 text-gray-700 hover:bg-gray-100 transition-colors">
                                <i class="fas fa-sign-out-alt mr-2"></i>Đăng xuất
                            </a>
                        </div>
                    </div>
                    <%
                    } else {
                    %>
                    <a href="${pageContext.request.contextPath}/user/login.jsp" class="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-full transition-all duration-300 flex items-center space-x-2">
                        <i class="fas fa-sign-in-alt"></i>
                        <span class="hidden sm:inline">Đăng nhập</span>
                    </a>
                    <%
                        }
                    %>
                </div>

                <!-- Mobile menu button -->
                <button id="mobileMenuBtn" class="md:hidden text-white hover:text-yellow-300 transition-colors">
                    <i class="fas fa-bars text-xl"></i>
                </button>
            </div>
        </div>

        <!-- Mobile Search -->
        <div id="mobileSearch" class="md:hidden mt-4 hidden">
            <form action="index.jsp" method="get">
                <div class="relative">
                    <input type="text" 
                           name="search" 
                           placeholder="Tìm sách theo tên hoặc tác giả..." 
                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>"
                           class="w-full px-4 py-2 pr-12 rounded-full border-2 border-white/20 bg-white/10 text-white placeholder-white/70 focus:outline-none focus:border-white focus:bg-white/20 transition-all duration-300">
                    <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 text-white hover:text-yellow-300 transition-colors">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Filter Menu -->
    <div id="filterMenu" class="bg-white/10 backdrop-blur-sm border-t border-white/20 hidden transform transition-all duration-300">
        <div class="container mx-auto px-4 py-4">
            <div class="flex flex-wrap items-center justify-between gap-4">
                <!-- Category Filters -->
                <div class="flex flex-wrap items-center gap-2">
                    <span class="text-white/80 text-sm font-medium mr-2">Thể loại:</span>
                    <button class="filter-btn active bg-white/20 text-white px-3 py-1 rounded-full text-sm hover:bg-white/30 transition-all duration-300" 
                            data-filter="all">
                        Tất cả
                    </button>
                    <button class="filter-btn bg-white/10 text-white/80 px-3 py-1 rounded-full text-sm hover:bg-white/20 hover:text-white transition-all duration-300" 
                            data-filter="hardcover">
                        Sách Bìa Cứng
                    </button>
                    <button class="filter-btn bg-white/10 text-white/80 px-3 py-1 rounded-full text-sm hover:bg-white/20 hover:text-white transition-all duration-300" 
                            data-filter="paperback">
                        Sách Bìa Mềm
                    </button>
                    <button class="filter-btn bg-white/10 text-white/80 px-3 py-1 rounded-full text-sm hover:bg-white/20 hover:text-white transition-all duration-300" 
                            data-filter="ebook">
                        Ebook
                    </button>
                </div>

                <!-- Sort Options -->
                <div class="flex items-center gap-2">
                    <span class="text-white/80 text-sm font-medium">Sắp xếp:</span>
                    <select class="bg-white/10 text-white border border-white/20 rounded-lg px-3 py-1 text-sm focus:outline-none focus:border-white/50 transition-all duration-300">
                        <option value="title">Tên sách</option>
                        <option value="author">Tác giả</option>
                        <option value="year">Năm xuất bản</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</header>

<!-- JavaScript for interactions -->
<script>
    // Toggle filter menu
    document.getElementById('filterToggle').addEventListener('click', function() {
        const filterMenu = document.getElementById('filterMenu');
        const icon = this.querySelector('i');
        
        if (filterMenu.classList.contains('hidden')) {
            filterMenu.classList.remove('hidden');
            icon.classList.remove('fa-filter');
            icon.classList.add('fa-times');
        } else {
            filterMenu.classList.add('hidden');
            icon.classList.remove('fa-times');
            icon.classList.add('fa-filter');
        }
    });

    // Toggle mobile menu
    document.getElementById('mobileMenuBtn').addEventListener('click', function() {
        const mobileSearch = document.getElementById('mobileSearch');
        mobileSearch.classList.toggle('hidden');
    });

    // Toggle user dropdown
    function toggleUserDropdown() {
        const dropdown = document.getElementById('userDropdown');
        if (dropdown.classList.contains('hidden')) {
            dropdown.classList.remove('hidden');
            setTimeout(() => {
                dropdown.classList.remove('opacity-0', 'scale-95');
                dropdown.classList.add('opacity-100', 'scale-100');
            }, 10);
        } else {
            dropdown.classList.remove('opacity-100', 'scale-100');
            dropdown.classList.add('opacity-0', 'scale-95');
            setTimeout(() => {
                dropdown.classList.add('hidden');
            }, 200);
        }
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(event) {
        const userDropdown = document.getElementById('userDropdown');
        const avatar = event.target.closest('img[onclick="toggleUserDropdown()"]');
        
        if (!avatar && !userDropdown.contains(event.target)) {
            userDropdown.classList.remove('opacity-100', 'scale-100');
            userDropdown.classList.add('opacity-0', 'scale-95');
            setTimeout(() => {
                userDropdown.classList.add('hidden');
            }, 200);
        }
    });

    // Filter functionality
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons
            document.querySelectorAll('.filter-btn').forEach(b => {
                b.classList.remove('active', 'bg-white/20', 'text-white');
                b.classList.add('bg-white/10', 'text-white/80');
            });
            
            // Add active class to clicked button
            this.classList.add('active', 'bg-white/20', 'text-white');
            this.classList.remove('bg-white/10', 'text-white/80');
            
            // Filter logic here
            const filter = this.getAttribute('data-filter');
            filterBooks(filter);
        });
    });

    function filterBooks(category) {
        const bookCards = document.querySelectorAll('.book-card');
        const categories = document.querySelectorAll('.category-section');
        
        if (category === 'all') {
            categories.forEach(cat => cat.style.display = 'block');
            bookCards.forEach(card => card.style.display = 'block');
        } else {
            categories.forEach(cat => {
                if (cat.id === category + '-section') {
                    cat.style.display = 'block';
                } else {
                    cat.style.display = 'none';
                }
            });
        }
    }
    const input = document.getElementById('searchInput');
    const suggestions = document.getElementById('suggestions');

    input.addEventListener('input', () => {
        const value = input.value.toLowerCase();
        const items = suggestions.querySelectorAll('.suggestion-item');
        let hasVisible = false;

        items.forEach(item => {
            const text = item.innerText.toLowerCase();
            const match = text.includes(value);
            item.style.display = match ? 'flex' : 'none';
            if (match) hasVisible = true;
        });

        suggestions.style.display = (value && hasVisible) ? 'block' : 'none';
    });

    document.addEventListener('click', (e) => {
        if (!suggestions.contains(e.target) && e.target !== input) {
            suggestions.style.display = 'none';
        }
    });
</script>