<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection, Data.Users" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sách theo danh mục - Thư viện</title>

        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

        <!-- Favicon -->
        <link rel="icon" href="./images/reading-book.png" type="image/x-icon" />

        <!-- Custom CSS -->
        <style>
            * {
                font-family: 'Inter', sans-serif;
            }

            .book-card {
                transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                background: linear-gradient(135deg, rgba(255,255,255,0.9) 0%, rgba(255,255,255,0.95) 100%);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.2);
            }

            .book-card:hover {
                transform: translateY(-12px) scale(1.03);
                box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            }

            .book-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 2rem;
                margin-top: 2rem;
            }

            .book-image-container {
                position: relative;
                height: 320px;
                overflow: hidden;
                border-radius: 16px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            }

            .book-image {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .book-card:hover .book-image {
                transform: scale(1.1);
            }

            .book-overlay {
                position: absolute;
                inset: 0;
                background: linear-gradient(135deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.3) 100%);
                opacity: 0;
                transition: opacity 0.3s ease;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 16px;
            }

            .book-card:hover .book-overlay {
                opacity: 1;
            }

            .shine-effect {
                position: relative;
                overflow: hidden;
            }

            .shine-effect::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: linear-gradient(45deg, transparent, rgba(255,255,255,0.3), transparent);
                transform: rotate(45deg);
                transition: transform 0.6s;
                z-index: 1;
            }

            .shine-effect:hover::before {
                transform: rotate(45deg) translate(100%, 100%);
            }

            .page-background {
                background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f0f9ff 100%);
                min-height: 100vh;
                position: relative;
            }

            .category-header {
                background: linear-gradient(135deg, rgba(255,255,255,0.9) 0%, rgba(255,255,255,0.7) 100%);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                padding: 2rem;
                margin-bottom: 2rem;
                border: 1px solid rgba(255,255,255,0.3);
            }

            .breadcrumb {
                background: linear-gradient(135deg, rgba(255,255,255,0.8) 0%, rgba(255,255,255,0.6) 100%);
                backdrop-filter: blur(10px);
                border-radius: 15px;
                padding: 1rem 1.5rem;
                margin-bottom: 2rem;
                border: 1px solid rgba(255,255,255,0.3);
            }

            .floating-elements {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                overflow: hidden;
                z-index: -1;
            }

            .floating-book {
                position: absolute;
                opacity: 0.1;
                animation: float 8s ease-in-out infinite;
            }

            @keyframes float {
                0%, 100% {
                    transform: translateY(0px) rotate(0deg);
                }
                50% {
                    transform: translateY(-30px) rotate(10deg);
                }
            }

            .animated-gradient {
                background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
                background-size: 400% 400%;
                animation: gradientShift 15s ease infinite;
            }

            @keyframes gradientShift {
                0% {
                    background-position: 0% 50%;
                }
                50% {
                    background-position: 100% 50%;
                }
                100% {
                    background-position: 0% 50%;
                }
            }

            .book-info {
                padding: 1.5rem;
            }

            .book-title {
                font-weight: 700;
                font-size: 1.1rem;
                line-height: 1.4;
                margin-bottom: 0.75rem;
                color: #1f2937;
                transition: color 0.3s ease;
            }

            .book-meta {
                font-size: 0.875rem;
                color: #6b7280;
                margin-bottom: 0.5rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .digital-badge {
                background: linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%);
                color: white;
                padding: 0.25rem 0.75rem;
                border-radius: 20px;
                font-size: 0.75rem;
                font-weight: 600;
                display: flex;
                align-items: center;
                gap: 0.25rem;
            }

            .back-button {
                background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0.1) 100%);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.3);
                border-radius: 50px;
                padding: 0.75rem 1.5rem;
                transition: all 0.3s ease;
                color: #374151;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 0.5rem;
            }

            .back-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(0,0,0,0.15);
                text-decoration: none;
            }

            .stats-card {
                background: linear-gradient(135deg, rgba(255,255,255,0.9) 0%, rgba(255,255,255,0.7) 100%);
                backdrop-filter: blur(10px);
                border-radius: 15px;
                padding: 1.5rem;
                border: 1px solid rgba(255,255,255,0.3);
                text-align: center;
            }

            .line-clamp-2 {
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }

            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 1rem;
                margin-top: 3rem;
            }

            .pagination a, .pagination span {
                background: linear-gradient(135deg, rgba(255,255,255,0.9) 0%, rgba(255,255,255,0.7) 100%);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(255,255,255,0.3);
                border-radius: 10px;
                padding: 0.75rem 1rem;
                text-decoration: none;
                color: #374151;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .pagination a:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }

            .pagination .current {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
            }

            @media (max-width: 768px) {
                .book-grid {
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 1.5rem;
                }

                .book-image-container {
                    height: 260px;
                }

                .category-header {
                    padding: 1.5rem;
                }
            }
        </style>
    </head>
    <body class="page-background">
        <!-- Floating Background Elements -->
        <div class="floating-elements">
            <i class="fas fa-book floating-book text-8xl text-blue-500" style="top: 5%; left: 80%; animation-delay: 0s;"></i>
            <i class="fas fa-bookmark floating-book text-6xl text-purple-500" style="top: 15%; left: 5%; animation-delay: 2s;"></i>
            <i class="fas fa-feather floating-book text-7xl text-green-500" style="top: 50%; left: 85%; animation-delay: 4s;"></i>
            <i class="fas fa-scroll floating-book text-5xl text-orange-500" style="top: 75%; left: 10%; animation-delay: 6s;"></i>
            <i class="fas fa-glasses floating-book text-6xl text-pink-500" style="top: 35%; left: 90%; animation-delay: 8s;"></i>
        </div>

        <!-- Include Header -->
        <%@ include file="../user/layout/header.jsp" %>

        <!-- Main Content -->
        <main class="max-w-7xl mx-auto px-4 py-8">
            <%            String category = request.getParameter("category");
                if (category == null) {
                    category = "ALL";
                }

                String categoryDisplayName = "";
                String categoryIcon = "";
                String categoryColor = "";

                switch (category) {
                    case "HARDCOVER":
                        categoryDisplayName = "Sách Bìa Cứng";
                        categoryIcon = "fas fa-book";
                        categoryColor = "blue";
                        break;
                    case "PAPERBACK":
                        categoryDisplayName = "Sách Bìa Mềm";
                        categoryIcon = "fas fa-book-open";
                        categoryColor = "green";
                        break;
                    case "EBOOK":
                        categoryDisplayName = "Ebook";
                        categoryIcon = "fas fa-tablet-alt";
                        categoryColor = "purple";
                        break;
                    default:
                        categoryDisplayName = "Tất cả sách";
                        categoryIcon = "fas fa-books";
                        categoryColor = "gray";
                }

                Connection conn = null;
                List<Map<String, Object>> books = new ArrayList<>();
                String searchQuery = request.getParameter("search");

                // Pagination
                int currentPage = 1;
                int booksPerPage = 12;
                int totalBooks = 0;

                try {
                    String pageParam = request.getParameter("page");
                    if (pageParam != null) {
                        currentPage = Integer.parseInt(pageParam);
                    }
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }

                int offset = (currentPage - 1) * booksPerPage;

                try {
                    conn = DBConnection.getConnection();

                    // Count total books for pagination - Only ACTIVE books
                    String countSql = "SELECT COUNT(*) as total FROM book b LEFT JOIN author a ON b.authorId = a.id WHERE b.status = 'ACTIVE'";
                    if (!category.equals("ALL")) {
                        countSql += " AND b.format = ?";
                    }

                    PreparedStatement countStmt = conn.prepareStatement(countSql);
                    if (!category.equals("ALL")) {
                        countStmt.setString(1, category);
                    }
                    ResultSet countRs = countStmt.executeQuery();
                    if (countRs.next()) {
                        totalBooks = countRs.getInt("total");
                    }

                    // Get books with pagination - Only ACTIVE books
                    String sql = "SELECT b.isbn, b.title, a.name AS author, b.publicationYear, b.format, b.coverImage "
                            + "FROM book b "
                            + "LEFT JOIN author a ON b.authorId = a.id "
                            + "WHERE b.status = 'ACTIVE'";

                    if (!category.equals("ALL")) {
                        sql += " AND b.format = ?";
                    }

                    sql += " ORDER BY b.title LIMIT ? OFFSET ?";

                    PreparedStatement stmt = conn.prepareStatement(sql);
                    int paramIndex = 1;

                    if (!category.equals("ALL")) {
                        stmt.setString(paramIndex++, category);
                    }
                    stmt.setInt(paramIndex++, booksPerPage);
                    stmt.setInt(paramIndex, offset);

                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
                        Map<String, Object> book = new HashMap<>();
                        book.put("isbn", rs.getString("isbn"));
                        book.put("title", rs.getString("title"));
                        book.put("author", rs.getString("author"));
                        book.put("publishedYear", rs.getInt("publicationYear"));
                        book.put("format", rs.getString("format"));
                        book.put("coverImage", rs.getString("coverImage"));

                        books.add(book);
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }

                int totalPages = (int) Math.ceil((double) totalBooks / booksPerPage);
            %>

            <!-- Breadcrumb -->
            <div class="breadcrumb">
                <nav class="flex items-center space-x-2 text-sm font-medium">
                    <a href="index.jsp" class="text-blue-600 hover:text-blue-800 transition-colors">
                        <i class="fas fa-home mr-1"></i>Trang chủ
                    </a>
                    <i class="fas fa-chevron-right text-gray-400"></i>
                    <span class="text-gray-700">
                        <i class="<%= categoryIcon%> mr-1"></i><%= categoryDisplayName%>
                    </span>
                </nav>
            </div>

            <!-- Category Header -->
            <div class="category-header">
                <div class="flex items-center justify-between flex-wrap gap-4">
                    <div class="flex items-center space-x-4">
                        <div class="w-16 h-16 bg-gradient-to-br from-<%= categoryColor%>-500 to-<%= categoryColor%>-600 rounded-full flex items-center justify-center">
                            <i class="<%= categoryIcon%> text-2xl text-white"></i>
                        </div>
                        <div>
                            <h1 class="text-4xl font-bold text-gray-800 mb-2"><%= categoryDisplayName%></h1>
                            <p class="text-gray-600 text-lg">Khám phá bộ sưu tập <%= categoryDisplayName.toLowerCase()%> phong phú</p>
                        </div>
                    </div>

                    <div class="flex items-center space-x-4">
                        <div class="stats-card">
                            <div class="text-2xl font-bold text-<%= categoryColor%>-600"><%= totalBooks%></div>
                            <div class="text-sm text-gray-600">Tổng số sách</div>
                        </div>
                        <a href="index.jsp" class="back-button">
                            <i class="fas fa-arrow-left"></i>
                            <span>Quay lại</span>
                        </a>
                    </div>
                </div>
            </div>

            <!-- Books Grid -->
            <div class="book-grid">
                <% for (Map<String, Object> book : books) {%>
                <div class="book-card rounded-3xl shadow-lg hover:shadow-2xl group shine-effect">
                    <a href="bookDetails.jsp?isbn=<%= book.get("isbn")%>" class="block">
                        <div class="book-image-container">
                            <img src="<%= request.getContextPath() + "/" + book.get("coverImage") %>"
                                 onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                                 class="book-image" />
                            <div class="book-overlay">
                                <i class="fas fa-eye text-white text-3xl transform group-hover:scale-110 transition-transform duration-300"></i>
                            </div>
                            <% if ("EBOOK".equals(book.get("format"))) { %>
                            <div class="absolute top-3 right-3 digital-badge">
                                <i class="fas fa-download"></i>
                                <span>Digital</span>
                            </div>
                            <% }%>
                        </div>
                        <div class="book-info">
                            <h3 class="book-title group-hover:text-<%= categoryColor%>-600 transition-colors line-clamp-2">
                                <%= book.get("title")%>
                            </h3>
                            <div class="book-meta">
                                <i class="fas fa-user-edit text-<%= categoryColor%>-500"></i>
                                <span><%= book.get("author")%></span>
                            </div>
                            <div class="book-meta">
                                <i class="fas fa-calendar text-<%= categoryColor%>-500"></i>
                                <span><%= book.get("publishedYear")%></span>
                            </div>
                            <div class="book-meta">
                                <i class="fas fa-tag text-<%= categoryColor%>-500"></i>
                                <span class="text-<%= categoryColor%>-600 font-medium"><%= book.get("format")%></span>
                            </div>
                        </div>
                    </a>
                </div>
                <% } %>
            </div>

            <!-- Pagination -->
            <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (currentPage > 1) {%>
                <a href="?category=<%= category%>&page=<%= currentPage - 1%>">
                    <i class="fas fa-chevron-left mr-1"></i>Trước
                </a>
                <% } %>

                <%
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);

                    if (startPage > 1) {
                %>
                <a href="?category=<%= category%>&page=1">1</a>
                <% if (startPage > 2) { %>
                <span>...</span>
                <% } %>
                <% } %>

                <% for (int i = startPage; i <= endPage; i++) { %>
                <% if (i == currentPage) {%>
                <span class="current"><%= i%></span>
                <% } else {%>
                <a href="?category=<%= category%>&page=<%= i%>"><%= i%></a>
                <% } %>
                <% } %>

                <% if (endPage < totalPages) { %>
                <% if (endPage < totalPages - 1) { %>
                <span>...</span>
                <% }%>
                <a href="?category=<%= category%>&page=<%= totalPages%>"><%= totalPages%></a>
                <% } %>

                <% if (currentPage < totalPages) {%>
                <a href="?category=<%= category%>&page=<%= currentPage + 1%>">
                    Sau<i class="fas fa-chevron-right ml-1"></i>
                </a>
                <% } %>
            </div>
            <% } %>

            <!-- Empty State -->
            <% if (books.isEmpty()) {%>
            <div class="text-center py-16">
                <div class="w-32 h-32 mx-auto mb-6 bg-gray-100 rounded-full flex items-center justify-center">
                    <i class="fas fa-book-open text-4xl text-gray-400"></i>
                </div>
                <h3 class="text-2xl font-bold text-gray-700 mb-2">Không tìm thấy sách</h3>
                <p class="text-gray-500 mb-6">Hiện tại chưa có sách nào trong danh mục <%= categoryDisplayName.toLowerCase()%>.</p>
                <a href="library.jsp" class="back-button">
                    <i class="fas fa-arrow-left mr-2"></i>Quay lại trang chủ
                </a>
            </div>
            <% }%>
        </main>

        <!-- Enhanced Footer -->
        <footer class="animated-gradient text-white py-12 mt-20">
            <div class="max-w-7xl mx-auto px-4 text-center">
                <div class="flex items-center justify-center mb-8">
                    <div class="w-16 h-16 bg-white bg-opacity-20 rounded-full flex items-center justify-center mr-4">
                        <i class="fas fa-book-reader text-2xl"></i>
                    </div>
                    <div>
                        <h3 class="text-2xl font-bold">Thư viện Số</h3>
                        <p class="text-white text-opacity-80">Nơi tri thức không giới hạn</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
                    <div>
                        <h4 class="text-lg font-semibold mb-4">Liên hệ</h4>
                        <div class="space-y-2 text-white text-opacity-80">
                            <p><i class="fas fa-phone mr-2"></i>+84 123 456 789</p>
                            <p><i class="fas fa-envelope mr-2"></i>info@thuvienso.com</p>
                            <p><i class="fas fa-map-marker-alt mr-2"></i>Cần Thơ, Việt Nam</p>
                        </div>
                    </div>

                    <div>
                        <h4 class="text-lg font-semibold mb-4">Danh mục</h4>
                        <div class="space-y-2 text-white text-opacity-80">
                            <a href="?category=HARDCOVER" class="block hover:text-white transition-colors">
                                <i class="fas fa-book mr-2"></i>Sách Bìa Cứng
                            </a>
                            <a href="?category=PAPERBACK" class="block hover:text-white transition-colors">
                                <i class="fas fa-book-open mr-2"></i>Sách Bìa Mềm
                            </a>
                            <a href="?category=EBOOK" class="block hover:text-white transition-colors">
                                <i class="fas fa-tablet-alt mr-2"></i>Ebook
                            </a>
                        </div>
                    </div>

                    <div>
                        <h4 class="text-lg font-semibold mb-4">Theo dõi chúng tôi</h4>
                        <div class="flex justify-center space-x-4">
                            <a href="#" class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center hover:bg-opacity-30 transition-all">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                            <a href="#" class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center hover:bg-opacity-30 transition-all">
                                <i class="fab fa-twitter"></i>
                            </a>
                            <a href="#" class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center hover:bg-opacity-30 transition-all">
                                <i class="fab fa-instagram"></i>
                            </a>
                            <a href="#" class="w-10 h-10 bg-white bg-opacity-20 rounded-full flex items-center justify-center hover:bg-opacity-30 transition-all">
                                <i class="fab fa-youtube"></i>
                            </a>
                        </div>
                    </div>
                </div>

                <div class="border-t border-white border-opacity-20 pt-8">
                    <div class="flex flex-col md:flex-row justify-between items-center">
                        <p class="text-white text-opacity-80 mb-4 md:mb-0">
                            © 2024 Thư viện Số. Tất cả các quyền được bảo lưu.
                        </p>
                        <div class="flex space-x-6 text-white text-opacity-80">
                            <a href="#" class="hover:text-white transition-colors">Điều khoản sử dụng</a>
                            <a href="#" class="hover:text-white transition-colors">Chính sách bảo mật</a>
                            <a href="#" class="hover:text-white transition-colors">Hỗ trợ</a>
                        </div>
                    </div>
                </div>
            </div>
        </footer>

        <!-- Back to Top Button -->
        <button id="backToTop" class="fixed bottom-8 right-8 w-12 h-12 bg-gradient-to-r from-blue-500 to-purple-600 text-white rounded-full shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-110 opacity-0 invisible">
            <i class="fas fa-arrow-up"></i>
        </button>

        <!-- JavaScript -->
        <script>
            // Back to top functionality
            const backToTopButton = document.getElementById('backToTop');

            window.addEventListener('scroll', () => {
                if (window.pageYOffset > 300) {
                    backToTopButton.classList.remove('opacity-0', 'invisible');
                    backToTopButton.classList.add('opacity-100', 'visible');
                } else {
                    backToTopButton.classList.add('opacity-0', 'invisible');
                    backToTopButton.classList.remove('opacity-100', 'visible');
                }
            });

            backToTopButton.addEventListener('click', () => {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            });

            // Smooth scrolling for anchor links
            document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                anchor.addEventListener('click', function (e) {
                    e.preventDefault();
                    const target = document.querySelector(this.getAttribute('href'));
                    if (target) {
                        target.scrollIntoView({
                            behavior: 'smooth'
                        });
                    }
                });
            });

            // Add loading animation to book cards
            const bookCards = document.querySelectorAll('.book-card');
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, observerOptions);

            bookCards.forEach(card => {
                card.style.opacity = '0';
                card.style.transform = 'translateY(20px)';
                card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
                observer.observe(card);
            });

            // Add ripple effect to buttons
            document.querySelectorAll('a, button').forEach(button => {
                button.addEventListener('click', function (e) {
                    const ripple = document.createElement('span');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    const x = e.clientX - rect.left - size / 2;
                    const y = e.clientY - rect.top - size / 2;

                    ripple.style.width = ripple.style.height = size + 'px';
                    ripple.style.left = x + 'px';
                    ripple.style.top = y + 'px';
                    ripple.classList.add('ripple');

                    this.appendChild(ripple);

                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });

            // Enhanced floating elements animation
            const floatingElements = document.querySelectorAll('.floating-book');
            floatingElements.forEach((element, index) => {
                const randomDelay = Math.random() * 2;
                const randomDuration = 6 + Math.random() * 4;
                element.style.animationDelay = randomDelay + 's';
                element.style.animationDuration = randomDuration + 's';
            });
        </script>

        <!-- Additional CSS for animations -->
        <style>
            .ripple {
                position: absolute;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.6);
                transform: scale(0);
                animation: ripple-animation 0.6s linear;
                pointer-events: none;
            }

            @keyframes ripple-animation {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }

            .book-card {
                will-change: transform, opacity;
            }

            .book-image {
                will-change: transform;
            }

            /* Enhanced hover effects */
            .book-card:hover {
                transform: translateY(-12px) scale(1.03);
                box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            }

            .book-card:hover .book-image {
                transform: scale(1.1);
            }

            /* Improved responsive design */
            @media (max-width: 640px) {
                .book-grid {
                    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                    gap: 1rem;
                }

                .book-image-container {
                    height: 240px;
                }

                .category-header {
                    padding: 1rem;
                }

                .stats-card {
                    padding: 1rem;
                }
            }
        </style>
    </body>
</html>