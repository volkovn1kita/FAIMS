using System;

public interface ICurrentUserService
{
    Guid GetUserId();
    string? GetUserRole(); 
}