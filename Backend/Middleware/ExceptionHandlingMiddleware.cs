using System.Net;
using System.Text.Json;
using Domain.Exceptions;
using Microsoft.Extensions.Logging;

namespace Backend.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
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

    private Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        _logger.LogError("EXCEPTION TYPE: {Type}, MESSAGE: {Message}, STACK: {Stack}",
        exception.GetType().FullName, exception.Message, exception.StackTrace);
        
        context.Response.ContentType = "application/json";
        var statusCode = HttpStatusCode.InternalServerError;

        switch (exception)
        {
            case NotFoundException:
                statusCode = HttpStatusCode.NotFound;
                _logger.LogWarning(exception, "Not found: {Message}", exception.Message);
                break;
            case ValidationException:
                statusCode = HttpStatusCode.BadRequest;
                _logger.LogWarning(exception, "Validation error: {Message}", exception.Message);
                break;
            case ForbiddenException:
                statusCode = HttpStatusCode.Forbidden;
                _logger.LogWarning(exception, "Forbidden: {Message}", exception.Message);
                break;
            case ConflictException:
                statusCode = HttpStatusCode.Conflict;
                _logger.LogWarning(exception, "Conflict: {Message}", exception.Message);
                break;
            default:
                _logger.LogError(exception, "Unhandled exception occurred.");
                break;
        }

        context.Response.StatusCode = (int)statusCode;

        var response = new
        {
            status = (int)statusCode,
            message = exception.Message
        };

        return context.Response.WriteAsync(JsonSerializer.Serialize(response));
    }
}
