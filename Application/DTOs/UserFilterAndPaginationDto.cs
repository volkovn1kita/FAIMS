
using System;
using Domain; // Для UserRole

namespace Application.DTOs
{
    public class UserFilterAndPaginationDto
    {
        public string? SearchQuery { get; set; } // Для пошуку за іменем, прізвищем, email
        public UserRole? Role { get; set; } // Для фільтрації за роллю

        public string? SortBy { get; set; } = "CreatedDate"; // Поле для сортування (наприклад, "FirstName", "LastName", "Email", "CreatedDate")
        public string? SortOrder { get; set; } = "desc"; // Порядок сортування ("asc" або "desc")

        public int PageNumber { get; set; } = 1; // Номер сторінки
        public int PageSize { get; set; } = 10; // Розмір сторінки
    }
}