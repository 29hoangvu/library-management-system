<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thư viện Sách</title>

        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

        <!-- Favicon -->
        <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />

        <!-- Custom CSS -->
        <link rel="stylesheet" href="user/home.css"/>
    </head>
    
    <body class="page-background">
        <!-- Floating Background Elements -->
        <div class="floating-elements">
            <i class="fas fa-book floating-book text-6xl text-blue-500" style="top: 10%; left: 85%; animation-delay: 0s;"></i>
            <i class="fas fa-bookmark floating-book text-4xl text-purple-500" style="top: 20%; left: 10%; animation-delay: 2s;"></i>
            <i class="fas fa-feather floating-book text-5xl text-green-500" style="top: 60%; left: 90%; animation-delay: 4s;"></i>
            <i class="fas fa-scroll floating-book text-4xl text-orange-500" style="top: 80%; left: 5%; animation-delay: 6s;"></i>
        </div>

        <!-- Include Header với Search Component -->
        <%@ include file="user/layout/header.jsp" %>
        <!-- Main Content -->
        <main class="container-enhanced py-12">
            <%            
                Connection conn = null;
                List<Map<String, Object>> allBooks = new ArrayList<>();
                List<Map<String, Object>> searchResults = new ArrayList<>();
                String searchQuery = request.getParameter("search");
                boolean isSearching = (searchQuery != null && !searchQuery.trim().isEmpty());

                try {
                    conn = DBConnection.getConnection();               
                    String sql = "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format, b.coverImage "
                            + "FROM book b "
                            + "LEFT JOIN author a ON b.authorId = a.id";

                    // Lấy tất cả sách trước
                    PreparedStatement allBooksStmt = conn.prepareStatement(sql);
                    ResultSet allBooksRs = allBooksStmt.executeQuery();

                    while (allBooksRs.next()) {
                        Map<String, Object> book = new HashMap<>();
                        book.put("isbn", allBooksRs.getString("isbn"));
                        book.put("title", allBooksRs.getString("title"));
                        book.put("author", allBooksRs.getString("author"));
                        book.put("publishedYear", allBooksRs.getInt("publicationYear"));
                        book.put("format", allBooksRs.getString("format"));
                        book.put("coverImage", allBooksRs.getString("coverImage"));

                        allBooks.add(book);
                    }

                    // Nếu có tìm kiếm, thực hiện query tìm kiếm
                    if (isSearching) {
                        String[] keywords = searchQuery.trim().toLowerCase().split("\\s+");
                        StringBuilder sqlCondition = new StringBuilder(" WHERE ");

                        for (int i = 0; i < keywords.length; i++) {
                            if (i > 0) {
                                sqlCondition.append(" AND ");
                            }
                            sqlCondition.append("(LOWER(b.title) LIKE ? OR LOWER(a.name) LIKE ?)");
                        }

                        String searchSql = sql + sqlCondition.toString();
                        PreparedStatement searchStmt = conn.prepareStatement(searchSql);

                        int index = 1;
                        for (String keyword : keywords) {
                            String param = "%" + keyword + "%";
                            searchStmt.setString(index++, param);
                            searchStmt.setString(index++, param);
                        }

                        ResultSet searchRs = searchStmt.executeQuery();

                        while (searchRs.next()) {
                            Map<String, Object> book = new HashMap<>();
                            book.put("isbn", searchRs.getString("isbn"));
                            book.put("title", searchRs.getString("title"));
                            book.put("author", searchRs.getString("author"));
                            book.put("publishedYear", searchRs.getInt("publicationYear"));
                            book.put("format", searchRs.getString("format"));
                            book.put("coverImage", searchRs.getString("coverImage"));

                            searchResults.add(book);
                        }
                    }

                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<div class='glass-effect border border-red-300 text-red-800 px-6 py-4 rounded-2xl mb-6'>");
                    out.println("<p class='flex items-center'><i class='fas fa-exclamation-triangle mr-3 text-xl'></i>Lỗi khi lấy dữ liệu sách: " + e.getMessage() + "</p>");
                    out.println("</div>");
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            %>

            <!-- Search Results Info -->
            <% if (isSearching) {%>
            <div class="mb-10 p-6 glass-effect border border-blue-300 rounded-2xl">
                <div class="flex items-center justify-center">
                    <i class="fas fa-search text-blue-600 mr-4 text-xl"></i>
                    <p class="text-blue-900 text-lg font-medium">
                        Kết quả tìm kiếm cho: <strong>"<%= searchQuery%>"</strong> 
                        (<%= searchResults.size()%> kết quả được tìm thấy)
                    </p>
                </div>
            </div>
            <% } %>

            <!-- Search Results Section -->
            <% if (isSearching) { %>
            <section id="search-results" class="category-section mb-16">
                <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                    <% for (Map<String, Object> book : searchResults) { %>
                    <div class="book-card rounded-3xl shadow-lg hover:shadow-2xl group shine-effect">
                        <a href="./user/bookDetails.jsp?isbn=<%= book.get("isbn")%>" class="block">
                            <div class="book-image-container">
                                <img src="<%= book.get("coverImage") %>" alt="<%= book.get("title") %>"
                                     onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                                     class="book-image" />
                                <div class="book-overlay">
                                    <i class="fas fa-eye text-white text-3xl transform group-hover:scale-110 transition-transform duration-300"></i>
                                </div>
                            </div>
                            <div class="book-info">
                                <h3 class="book-title group-hover:text-blue-600 transition-colors line-clamp-2">
                                    <%= book.get("title") %>
                                </h3>
                                <div class="book-meta">
                                    <i class="fas fa-user-edit text-blue-500"></i>
                                    <span><%= book.get("author") %></span>
                                </div>
                                <div class="book-meta">
                                    <i class="fas fa-calendar text-blue-500"></i>
                                    <span><%= book.get("publishedYear") %></span>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>
                </div>
            </section>
            <% } %>

            <!-- Books Categories (hiển thị khi không tìm kiếm HOẶC khi không có dữ liệu) -->
            <% if (!isSearching) { %>
            
            <!-- Sách Bìa Cứng -->
            <section id="hardcover-section" class="category-section mb-16">
                <div class="category-header">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4">
                            <div class="w-2 h-12 bg-gradient-to-b from-blue-500 to-purple-600 rounded-full"></div>
                            <h2 class="text-4xl font-bold category-title">Sách Bìa Cứng</h2>
                            <span class="count-badge text-blue-800 text-sm font-semibold px-4 py-2 rounded-full">
                                <%
                                    int hardcoverCount = 0;
                                    for (Map<String, Object> book : allBooks) {
                                        if ("HARDCOVER".equals(book.get("format"))) {
                                            hardcoverCount++;
                                        }
                                    }
                                %>
                                <%= hardcoverCount%> cuốn sách
                            </span>
                        </div>
                        <a href="./user/booksByCategory.jsp?category=HARDCOVER" class="expand-button text-blue-700 hover:text-blue-900 font-semibold transition-all duration-300 flex items-center space-x-3 no-underline">
                            <span>Xem thêm</span>
                            <i class="fas fa-arrow-right transition-transform duration-300 group-hover:translate-x-1"></i>
                        </a>
                    </div>
                </div>

                <div id="hardcover-books" class="book-grid max-h-[600px] overflow-hidden grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                    <%
                        int hardcoverDisplayed = 0;
                        for (Map<String, Object> book : allBooks) {
                            if ("HARDCOVER".equals(book.get("format")) && hardcoverDisplayed < 5) {
                                hardcoverDisplayed++;
                    %>
                    <div class="book-card rounded-3xl shadow-lg hover:shadow-2xl group shine-effect">
                        <a href="./user/bookDetails.jsp?isbn=<%= book.get("isbn")%>" class="block">
                            <div class="book-image-container">
                                <img src="<%= book.get("coverImage")%>"
                                     alt="<%= book.get("title")%>"
                                     onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                                     class="book-image" />
                                <div class="book-overlay">
                                    <i class="fas fa-eye text-white text-3xl transform group-hover:scale-110 transition-transform duration-300"></i>
                                </div>
                            </div>
                            <div class="book-info">
                                <h3 class="book-title group-hover:text-blue-600 transition-colors line-clamp-2">
                                    <%= book.get("title")%>
                                </h3>
                                <div class="book-meta">
                                    <i class="fas fa-user-edit text-blue-500"></i>
                                    <span><%= book.get("author")%></span>
                                </div>
                                <div class="book-meta">
                                    <i class="fas fa-calendar text-blue-500"></i>
                                    <span><%= book.get("publishedYear")%></span>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </section>

            <!-- Sách Bìa Mềm -->
            <section id="paperback-section" class="category-section mb-16">
                <div class="category-header">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4">
                            <div class="w-2 h-12 bg-gradient-to-b from-green-500 to-teal-600 rounded-full"></div>
                            <h2 class="text-4xl font-bold category-title">Sách Bìa Mềm</h2>
                            <span class="count-badge text-green-800 text-sm font-semibold px-4 py-2 rounded-full">
                                <%
                                    int paperbackCount = 0;
                                    for (Map<String, Object> book : allBooks) {
                                        if ("PAPERBACK".equals(book.get("format"))) {
                                            paperbackCount++;
                                        }
                                    }
                                %>
                                <%= paperbackCount%> cuốn sách
                            </span>
                        </div>
                        <a href="./user/booksByCategory.jsp?category=PAPERBACK" class="expand-button text-green-700 hover:text-green-900 font-semibold transition-all duration-300 flex items-center space-x-3 no-underline">
                            <span>Xem thêm</span>
                            <i class="fas fa-arrow-right transition-transform duration-300 group-hover:translate-x-1"></i>
                        </a>
                    </div>
                </div>

                <div id="paperback-books" class="book-grid max-h-[600px] overflow-hidden grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                    <%
                        int paperbackDisplayed = 0;
                        for (Map<String, Object> book : allBooks) {
                            if ("PAPERBACK".equals(book.get("format")) && paperbackDisplayed < 6) {
                                paperbackDisplayed++;
                    %>
                    <div class="book-card rounded-3xl shadow-lg hover:shadow-2xl group shine-effect">
                        <a href="./user/bookDetails.jsp?isbn=<%= book.get("isbn")%>" class="block">
                            <div class="book-image-container">
                                <img src="<%= book.get("coverImage")%>"
                                     alt="<%= book.get("title")%>"
                                     onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                                     class="book-image" />
                                <div class="book-overlay">
                                    <i class="fas fa-eye text-white text-3xl transform group-hover:scale-110 transition-transform duration-300"></i>
                                </div>
                            </div>
                            <div class="book-info">
                                <h3 class="book-title group-hover:text-green-600 transition-colors line-clamp-2">
                                    <%= book.get("title")%>
                                </h3>
                                <div class="book-meta">
                                    <i class="fas fa-user-edit text-green-500"></i>
                                    <span><%= book.get("author")%></span>
                                </div>
                                <div class="book-meta">
                                    <i class="fas fa-calendar text-green-500"></i>
                                    <span><%= book.get("publishedYear")%></span>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </section>

            <!-- Ebook -->
            <section id="ebook-section" class="category-section mb-16">
                <div class="category-header">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-4">
                            <div class="w-2 h-12 bg-gradient-to-b from-purple-500 to-pink-600 rounded-full"></div>
                            <h2 class="text-4xl font-bold category-title">Ebook</h2>
                            <span class="count-badge text-purple-800 text-sm font-semibold px-4 py-2 rounded-full">
                                <%
                                    int ebookCount = 0;
                                    for (Map<String, Object> book : allBooks) {
                                        if ("EBOOK".equals(book.get("format"))) {
                                            ebookCount++;
                                        }
                                    }
                                %>
                                <%= ebookCount%> cuốn sách
                            </span>
                        </div>
                        <a href="./user/booksByCategory.jsp?category=EBOOK" class="expand-button text-purple-700 hover:text-purple-900 font-semibold transition-all duration-300 flex items-center space-x-3 no-underline">
                            <span>Xem thêm</span>
                            <i class="fas fa-arrow-right transition-transform duration-300 group-hover:translate-x-1"></i>
                        </a>
                    </div>
                </div>

                <div id="ebook-books" class="book-grid max-h-[600px] overflow-hidden grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-6">
                    <%
                        int ebookDisplayed = 0;
                        for (Map<String, Object> book : allBooks) {
                            if ("EBOOK".equals(book.get("format")) && ebookDisplayed < 6) {
                                ebookDisplayed++;
                    %>
                    <div class="book-card rounded-3xl shadow-lg hover:shadow-2xl group shine-effect">
                        <a href="./user/bookDetails.jsp?isbn=<%= book.get("isbn")%>" class="block">
                            <div class="book-image-container">
                                <img src="<%= book.get("coverImage")%>"
                                 alt="<%= book.get("title")%>"
                                 onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                                 class="book-image" />
                                <div class="book-overlay">
                                    <i class="fas fa-eye text-white text-3xl transform group-hover:scale-110 transition-transform duration-300"></i>
                                </div>
                                <div class="absolute top-3 right-3 digital-badge">
                                    <i class="fas fa-download"></i>
                                    <span>Digital</span>
                                </div>
                            </div>
                            <div class="book-info">
                                <h3 class="book-title group-hover:text-purple-600 transition-colors line-clamp-2">
                                    <%= book.get("title")%>
                                </h3>
                                <div class="book-meta">
                                    <i class="fas fa-user-edit text-purple-500"></i>
                                    <span><%= book.get("author")%></span>
                                </div>
                                <div class="book-meta">
                                    <i class="fas fa-calendar text-purple-500"></i>
                                    <span><%= book.get("publishedYear")%></span>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>
                    <% }%>
                </div>
            </section>
            <% } %>
        </main>

        <!-- Enhanced Footer -->
        <%@ include file="user/layout/footer.jsp" %>

        <!-- Enhanced JavaScript -->
        <script>
            // Toggle category expansion with smooth animations
            function toggleCategory(categoryId, button) {
                const container = document.getElementById(categoryId);
                const icon = button.querySelector('i');
                const buttonText = button.querySelector('span');

                container.style.transition = 'max-height 0.6s cubic-bezier(0.4, 0, 0.2, 1)';

                if (container.classList.contains('max-h-[600px]')) {
                    container.classList.remove('max-h-[600px]', 'overflow-hidden');
                    container.style.maxHeight = 'none';
                    icon.classList.add('rotate-180');
                    buttonText.textContent = 'Thu gọn';
                } else {
                    container.classList.add('max-h-[600px]', 'overflow-hidden');
                    container.style.maxHeight = '600px';
                    icon.classList.remove('rotate-180');
                    buttonText.textContent = 'Xem thêm';
                }
            }

            // Enhanced smooth scroll functionality
            document.addEventListener('DOMContentLoaded', function () {
                const bookImages = document.querySelectorAll('.book-image');

                bookImages.forEach(img => {
                    // Đảm bảo image luôn hiển thị
                    img.style.opacity = '1';
                    img.style.visibility = 'visible';

                    // Chỉ thêm hiệu ứng khi hover
                    img.addEventListener('load', function () {
                        this.style.transition = 'transform 0.6s ease';
                    });
                });
            });

                // Add intersection observer for animation on scroll
                const observerOptions = {
                    threshold: 0.1,
                    rootMargin: '0px 0px -100px 0px'
                };

                const observer = new IntersectionObserver((entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            entry.target.style.animation = 'fadeInUp 0.8s ease-out';
                        }
                    });
                }, observerOptions);

                document.querySelectorAll('.category-section').forEach(section => {
                    observer.observe(section);
                });
            });

            // Enhanced filter functionality with animations
            function filterBooks(category) {
                const sections = document.querySelectorAll('.category-section');

                sections.forEach(section => {
                    section.style.transition = 'all 0.5s ease';
                });

                if (category === 'all') {
                    sections.forEach(section => {
                        section.style.display = 'block';
                        section.style.opacity = '1';
                        section.style.transform = 'translateY(0)';
                    });
                } else {
                    sections.forEach(section => {
                        if (section.id === category + '-section') {
                            section.style.display = 'block';
                            section.style.opacity = '1';
                            section.style.transform = 'translateY(0)';
                            setTimeout(() => {
                                section.scrollIntoView({
                                    behavior: 'smooth',
                                    block: 'start'
                                });
                            }, 200);
                        } else {
                            section.style.opacity = '0.3';
                            section.style.transform = 'translateY(20px)';
                            setTimeout(() => {
                                section.style.display = 'none';
                            }, 500);
                        }
                    });
                }
            }

            // Enhanced image loading with fade-in effect
            document.addEventListener('DOMContentLoaded', function () {
                const bookImages = document.querySelectorAll('.book-image');

                bookImages.forEach(img => {
                    img.style.opacity = '0';
                    img.addEventListener('load', function () {
                        this.style.transition = 'opacity 0.6s ease';
                        this.style.opacity = '1';
                    });
                });
            });

            // Add custom animations
            const customStyles = `
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(30px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            
                @keyframes pulse {
                    0%, 100% { transform: scale(1); }
                    50% { transform: scale(1.05); }
                }
            
                .line-clamp-2 {
                    display: -webkit-box;
                    -webkit-line-clamp: 2;
                    -webkit-box-orient: vertical;
                    overflow: hidden;
                }
            
                .rotate-180 {
                    transform: rotate(180deg);
                }
            
                .book-card:hover {
                    animation: pulse 2s infinite;
                }
            `;

            const styleSheet = document.createElement('style');
            styleSheet.textContent = customStyles;
            document.head.appendChild(styleSheet);

            // Add parallax effect to floating elements
            window.addEventListener('scroll', function () {
                const scrolled = window.pageYOffset;
                const parallaxElements = document.querySelectorAll('.floating-book');

                parallaxElements.forEach((element, index) => {
                    const speed = 0.5 + (index * 0.1);
                    element.style.transform = `translateY(${scrolled * speed}px) rotate(${scrolled * 0.1}deg)`;
                });
            });
        </script>
    </body>
</html>