<%@ page contentType="application/json; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, Servlet.DBConnection" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    String searchQuery = request.getParameter("q");
    List<Map<String, Object>> suggestions = new ArrayList<>();

    if (searchQuery == null || searchQuery.trim().length() < 2) {
        // Load sách mặc định (mới nhất)
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT DISTINCT b.isbn, b.title, a.name AS author, b.coverImage, b.publicationYear "
                    + "FROM book b "
                    + "LEFT JOIN author a ON b.authorId = a.id "
                    + "ORDER BY b.publicationYear DESC LIMIT 8";

            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> book = new HashMap<>();
                book.put("isbn", rs.getString("isbn"));
                book.put("title", rs.getString("title"));
                book.put("author", rs.getString("author"));
                book.put("coverImage", rs.getString("coverImage"));
                book.put("publicationYear", rs.getInt("publicationYear"));
                suggestions.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT DISTINCT b.isbn, b.title, a.name AS author, b.coverImage, b.publicationYear "
                    + "FROM book b "
                    + "LEFT JOIN author a ON b.authorId = a.id "
                    + "WHERE (LOWER(b.title) LIKE ? OR LOWER(a.name) LIKE ?) "
                    + "ORDER BY "
                    + "  CASE "
                    + "    WHEN LOWER(b.title) LIKE ? THEN 1 "
                    + "    WHEN LOWER(a.name) LIKE ? THEN 2 "
                    + "    ELSE 3 "
                    + "  END, "
                    + "  b.title "
                    + "LIMIT 8";

            PreparedStatement stmt = conn.prepareStatement(sql);
            String param = "%" + searchQuery.toLowerCase() + "%";
            String exactParam = searchQuery.toLowerCase() + "%";

            stmt.setString(1, param);
            stmt.setString(2, param);
            stmt.setString(3, exactParam);
            stmt.setString(4, exactParam);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> book = new HashMap<>();
                book.put("isbn", rs.getString("isbn"));
                book.put("title", rs.getString("title"));
                book.put("author", rs.getString("author"));
                book.put("coverImage", rs.getString("coverImage"));
                book.put("publicationYear", rs.getInt("publicationYear"));
                suggestions.add(book);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Log error but don't break JSON response
            System.err.println("Error in getSuggestions: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // Build JSON manually without Gson
    StringBuilder json = new StringBuilder();
    json.append("[");

    for (int i = 0; i < suggestions.size(); i++) {
        Map<String, Object> book = suggestions.get(i);

        if (i > 0) {
            json.append(",");
        }

        json.append("{");
        json.append("\"isbn\":\"").append(escapeJson(String.valueOf(book.get("isbn")))).append("\",");
        json.append("\"title\":\"").append(escapeJson(String.valueOf(book.get("title")))).append("\",");
        json.append("\"author\":\"").append(escapeJson(String.valueOf(book.get("author")))).append("\",");
        json.append("\"coverImage\":\"").append(escapeJson(String.valueOf(book.get("coverImage")))).append("\",");
        json.append("\"publicationYear\":").append(book.get("publicationYear"));
        json.append("}");
    }

    json.append("]");

    out.print(json.toString());
    out.flush();
%>
<%!
    private String escapeJson(String str) {
        if (str == null || str.equals("null")) {
            return "";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
%>