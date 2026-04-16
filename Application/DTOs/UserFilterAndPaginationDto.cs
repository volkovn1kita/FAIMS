
using System;
using Domain;

namespace Application.DTOs
{
    public class UserFilterAndPaginationDto
    {
        public string? SearchQuery { get; set; }
        public UserRole? Role { get; set; }
        public string? SortBy { get; set; } = "CreatedDate";
        public string? SortOrder { get; set; } = "desc";
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}