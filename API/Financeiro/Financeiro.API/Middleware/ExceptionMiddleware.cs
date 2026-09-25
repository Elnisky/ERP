using Financeiro.API.Exceptions;
using Financeiro.Application.Exceptions;
using System.Text.Json;

namespace Financeiro.API.Middleware
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;
        private readonly IHostEnvironment _env;
        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger, IHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
        }
        public async Task InvokeAsync(HttpContext httpContext)
        {
            try
            {
                await _next(httpContext);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                int statusCode = ex switch
                {
                    BadRequestException => StatusCodes.Status400BadRequest,
                    UnauthorizedAccessException => StatusCodes.Status401Unauthorized,
                    NotFoundException => StatusCodes.Status404NotFound,
                    _ => StatusCodes.Status500InternalServerError
                };
                httpContext.Response.StatusCode = statusCode;
                httpContext.Response.ContentType = "application/json";

                ApiException response = new ApiException(statusCode.ToString(), ex.Message, _env.IsDevelopment() ? ex.StackTrace : "Internal server error.");
                var options = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                };
                var json = JsonSerializer.Serialize(response, options);
                await httpContext.Response.WriteAsJsonAsync(response);    
            }
        }
    }
}
