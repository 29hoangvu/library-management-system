<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="Servlet.DBConnection, Data.Users" %>

<%
    request.setAttribute("pageTitle", "Quản lý sách - Admin");
%>
<%@ include file="../includes/header.jsp" %>

<!-- Content của trang admin -->
<main class="transition-all duration-300 pt-32" id="mainContent">
<section class="bg-gray-100 py-10 px-6">
    <div class="max-w-4xl mx-auto bg-white p-8 rounded-lg shadow-md">
        <h2 class="text-2xl font-bold mb-6 text-center text-gray-800">Thêm sách mới</h2>
        <form action="AdminServlet" method="post" enctype="multipart/form-data" class="space-y-6">

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">ISBN</label>
                    <input type="text" name="isbn"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Tên sách</label>
                    <input type="text" name="title"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Thể loại</label>
                    <input type="text" name="subject"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Nhà xuất bản</label>
                    <input type="text" name="publisher"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Năm xuất bản</label>
                    <input type="number" name="publicationYear" min="1000" max="9999"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Ngôn ngữ</label>
                    <input type="text" name="language"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Số trang</label>
                    <input type="number" name="numberOfPages" min="1"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Định dạng</label>
                    <select name="format"
                            class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="HARDCOVER">Bìa cứng</option>
                        <option value="PAPERBACK">Bìa mềm</option>
                        <option value="EBOOK">Ebook</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Tác giả</label>
                    <input type="text" name="authorName" id="authorName" list="authorList"
                           placeholder="Nhập hoặc chọn tác giả"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                    <datalist id="authorList">
                        <%
                            Connection con = DBConnection.getConnection();
                            Statement stmt = con.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT id, name FROM Author");
                            while (rs.next()) {
                        %>
                        <option value="<%= rs.getString("name")%>" data-id="<%= rs.getInt("id")%>"></option>
                        <% }%>
                    </datalist>
                    <input type="hidden" name="authorId" id="authorId">
                    <input type="hidden" name="isNewAuthor" id="isNewAuthor" value="false">
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Số lượng</label>
                    <input type="number" name="quantity" min="1"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Giá sách</label>
                    <input type="number" name="price" step="0.01" min="0"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
                <div>
                    <label class="block mb-1 text-sm font-medium text-gray-700">Ngày nhập</label>
                    <input type="date" name="dateOfPurchase"
                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500" required>
                </div>
            </div>

            <div>
                <label class="block mb-1 text-sm font-medium text-gray-700">Hình ảnh</label>
                <input type="file" name="coverImage" accept="image/*"
                       class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4
                       file:rounded file:border-0
                       file:text-sm file:font-semibold
                       file:bg-blue-50 file:text-blue-700
                       hover:file:bg-blue-100" />
            </div>

            <div class="text-center pt-4">
                <button type="submit"
                        class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-6 rounded-lg transition duration-200">
                    Thêm sách
                </button>
            </div>
        </form>
    </div>
</section>
</main>
                    <script>
document.addEventListener("DOMContentLoaded", () => {
    const authorInput = document.getElementById("authorName");
    const authorIdField = document.getElementById("authorId");
    const isNewAuthorField = document.getElementById("isNewAuthor");
    const dataList = document.getElementById("authorList");

    authorInput.addEventListener("input", () => {
        const inputVal = authorInput.value.trim().toLowerCase();
        let found = false;

        for (let option of dataList.options) {
            if (option.value.trim().toLowerCase() === inputVal) {
                authorIdField.value = option.dataset.id;
                isNewAuthorField.value = "false";
                found = true;
                break;
            }
        }

        if (!found) {
            authorIdField.value = "";
            isNewAuthorField.value = "true";
        }
    });
});
</script>

</div>
