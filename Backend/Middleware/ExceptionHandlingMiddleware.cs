using System.Net;
using System.Text.Json;
using Domain.Exceptions;

namespace Backend.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    public ExceptionHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext httpContext)
    {
        try
        {
            await _next(httpContext);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(httpContext, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";
        var statusCode = HttpStatusCode.InternalServerError;
        
        switch (exception)
        {
            case NotFoundException:
                statusCode = HttpStatusCode.NotFound; // 404
                break;
            case ValidationException:
                statusCode = HttpStatusCode.BadRequest; // 400
                break;
            case ForbiddenException:
                statusCode = HttpStatusCode.Forbidden; //403
                break;
        }
        
        context.Response.StatusCode = (int)statusCode;

        var response = new 
        {
            Status = (int)statusCode,
            Message = exception.Message 
        };

        return context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }

}
