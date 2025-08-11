<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!-- Search Component -->
<div class="relative hidden md:flex flex-1 max-w-md mx-8">
    <form action="index.jsp" method="get" class="w-full" id="searchForm">
        <div class="relative">
            <input type="text" 
                   id="searchInput"
                   name="search" 
                   placeholder="Tìm sách theo tên hoặc tác giả..." 
                   value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>"
                   class="w-full px-4 py-2 pr-12 rounded-full border-2 border-white/20 bg-white/10 text-white placeholder-white/70 focus:outline-none focus:border-white focus:bg-white/20 transition-all duration-300"
                   autocomplete="off">
            <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 text-white hover:text-yellow-300 transition-colors">
                <i class="fas fa-search"></i>
            </button>
            
            <!-- Loading indicator -->
            <div id="searchLoading" class="absolute right-10 top-1/2 transform -translate-y-1/2 hidden">
                <i class="fas fa-spinner fa-spin text-white"></i>
            </div>
        </div>
    </form>

    <!-- Suggestions Dropdown -->
    <div id="suggestions" class="absolute top-full mt-2 w-full bg-white rounded-lg shadow-xl max-h-80 overflow-y-auto hidden z-50 border border-gray-200">
        <div id="suggestionsContent">
            <!-- Suggestions will be loaded here via AJAX -->
        </div>
        
        <!-- No results message -->
        <div id="noResults" class="px-4 py-3 text-gray-500 text-center hidden">
            <i class="fas fa-search mr-2"></i>
            Không tìm thấy kết quả phù hợp
        </div>
        
        <!-- Search tip -->
        <div class="px-4 py-2 bg-gray-50 border-t text-xs text-gray-400 flex items-center justify-between">
            <span><i class="fas fa-lightbulb mr-1"></i>Gõ ít nhất 2 ký tự để tìm kiếm</span>
            <span>ESC để đóng</span>
        </div>
    </div>
</div>

<!-- Mobile Search -->
<div id="mobileSearch" class="md:hidden mt-4 hidden">
    <form action="index.jsp" method="get" class="relative">
        <input type="text" 
               id="mobileSearchInput"
               name="search" 
               placeholder="Tìm sách theo tên hoặc tác giả..." 
               value="<%= request.getParameter("search") != null ? request.getParameter("search") : ""%>"
               class="w-full px-4 py-2 pr-12 rounded-full border-2 border-white/20 bg-white/10 text-white placeholder-white/70 focus:outline-none focus:border-white focus:bg-white/20 transition-all duration-300">
        <button type="submit" class="absolute right-2 top-1/2 transform -translate-y-1/2 text-white hover:text-yellow-300 transition-colors">
            <i class="fas fa-search"></i>
        </button>
    </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const mobileSearchInput = document.getElementById('mobileSearchInput');
    const suggestions = document.getElementById('suggestions');
    const suggestionsContent = document.getElementById('suggestionsContent');
    const noResults = document.getElementById('noResults');
    const searchLoading = document.getElementById('searchLoading');
    
    let searchTimeout;
    let currentFocus = -1;
    
    // Search input event listener for both desktop and mobile
    [searchInput, mobileSearchInput].forEach(input => {
        if (input) {
            input.addEventListener('input', function() {
                if (this === mobileSearchInput) return; // Skip mobile for suggestions
                
                const query = this.value.trim();
                
                // Clear previous timeout
                clearTimeout(searchTimeout);
                
                if (query.length < 2) {
                    hideSuggestions();
                    return;
                }
                
                // Show loading
                searchLoading.classList.remove('hidden');
                
                // Debounce search requests
                searchTimeout = setTimeout(() => {
                    fetchSuggestions(query);
                }, 300);
            });
        }
    });
    
    // Keyboard navigation
    searchInput.addEventListener('keydown', function(e) {
        const suggestionItems = suggestions.querySelectorAll('.suggestion-item');
        
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            currentFocus++;
            if (currentFocus >= suggestionItems.length) currentFocus = 0;
            setActiveSuggestion(suggestionItems);
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            currentFocus--;
            if (currentFocus < 0) currentFocus = suggestionItems.length - 1;
            setActiveSuggestion(suggestionItems);
        } else if (e.key === 'Enter') {
            if (currentFocus > -1 && suggestionItems[currentFocus]) {
                e.preventDefault();
                suggestionItems[currentFocus].click();
            }
        } else if (e.key === 'Escape') {
            hideSuggestions();
            searchInput.blur();
        }
    });
    
    // Focus events
    searchInput.addEventListener('focus', function() {
        if (this.value.length >= 2) {
            suggestions.classList.remove('hidden');
        }
    });
    
    // Click outside to close
    document.addEventListener('click', function(e) {
        if (!suggestions.contains(e.target) && e.target !== searchInput) {
            hideSuggestions();
        }
    });
    
    function fetchSuggestions(query) {
        // Make AJAX call to get suggestions
        const xhr = new XMLHttpRequest();
        xhr.open('GET', `getSuggestions.jsp?q=${encodeURIComponent(query)}`, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                searchLoading.classList.add('hidden');
                
                if (xhr.status === 200) {
                    try {
                        const suggestionsData = JSON.parse(xhr.responseText);
                        renderSuggestions(suggestionsData, query);
                    } catch (e) {
                        console.error('Error parsing suggestions:', e);
                        showNoResults();
                    }
                } else {
                    console.error('Error fetching suggestions:', xhr.status);
                    showNoResults();
                }
            }
        };
        xhr.send();
    }
    
    function renderSuggestions(suggestionsData, query) {
        suggestionsContent.innerHTML = '';
        noResults.classList.add('hidden');
        currentFocus = -1;
        
        if (suggestionsData.length === 0) {
            showNoResults();
            return;
        }
        
        suggestionsData.forEach((book, index) => {
            const item = createSuggestionItem(book, query);
            suggestionsContent.appendChild(item);
        });
        
        suggestions.classList.remove('hidden');
    }
    
    function createSuggestionItem(book, query) {
        const item = document.createElement('div');
        item.className = 'suggestion-item flex items-center gap-3 px-4 py-3 hover:bg-gray-50 cursor-pointer border-b border-gray-100 last:border-b-0 transition-colors duration-200';
        
        // Highlight matching text
        const highlightedTitle = highlightText(book.title, query);
        const highlightedAuthor = highlightText(book.author || 'Không rõ tác giả', query);
        
        item.innerHTML = `
            <div class="flex-shrink-0">
                <img src="${book.coverImage || 'images/default-cover.jpg'}" 
                     alt="${book.title}"
                     onerror="this.onerror=null; this.src='images/default-cover.jpg'"
                     class="w-12 h-16 object-cover rounded-md shadow-sm border border-gray-200">
            </div>
            <div class="flex-1 min-w-0">
                <h4 class="font-medium text-gray-900 truncate mb-1">${highlightedTitle}</h4>
                <p class="text-sm text-gray-600 truncate">
                    <i class="fas fa-user-edit mr-1"></i>${highlightedAuthor}
                </p>
                <p class="text-xs text-gray-400 mt-1">
                    <i class="fas fa-calendar mr-1"></i>${book.publicationYear || 'N/A'}
                </p>
            </div>
            <div class="flex-shrink-0">
                <i class="fas fa-arrow-right text-gray-400 text-sm"></i>
            </div>
        `;
        
        item.addEventListener('click', function() {
            // Navigate to book details
            window.location.href = `user/bookDetails.jsp?isbn=${book.isbn}`;
        });
        
        return item;
    }
    
    function highlightText(text, query) {
        if (!query || !text) return text;
        
        const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
        return text.replace(regex, '<mark class="bg-yellow-200 px-1 rounded">$1</mark>');
    }
    
    function escapeRegExp(string) {
        return string.replace(/[.*+?^\\${}()|[\]\\]/g, '\\$&');
    }

    function setActiveSuggestion(items) {
        // Remove active class from all items
        items.forEach(item => item.classList.remove('bg-blue-50', 'border-blue-200'));
        
        // Add active class to current item
        if (currentFocus >= 0 && items[currentFocus]) {
            items[currentFocus].classList.add('bg-blue-50', 'border-blue-200');
            items[currentFocus].scrollIntoView({ block: 'nearest' });
        }
    }
    
    function showNoResults() {
        suggestionsContent.innerHTML = '';
        noResults.classList.remove('hidden');
        suggestions.classList.remove('hidden');
    }
    
    function hideSuggestions() {
        suggestions.classList.add('hidden');
        currentFocus = -1;
        searchLoading.classList.add('hidden');
    }
});
</script>