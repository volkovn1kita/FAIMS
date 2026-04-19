using Application.DTOs;
using Application.Interfaces;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace Backend.Controllers;

[ApiController]
[Route("api/kit-templates")]
[EnableRateLimiting("ApiPolicy")]
[Authorize(Roles = nameof(UserRole.Administrator))]
public class KitTemplateController : ControllerBase
{
    private readonly IKitTemplateService _templateService;

    public KitTemplateController(IKitTemplateService templateService)
    {
        _templateService = templateService;
    }

    /// <summary>GET /api/kit-templates — всі шаблони (системні + власні організації)</summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var templates = await _templateService.GetAllTemplatesAsync();
        return Ok(templates);
    }

    /// <summary>GET /api/kit-templates/{id} — один шаблон з позиціями</summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        try
        {
            var template = await _templateService.GetTemplateByIdAsync(id);
            return Ok(template);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
    }

    /// <summary>POST /api/kit-templates — створити власний шаблон</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateKitTemplateDto dto)
    {
        var id = await _templateService.CreateTemplateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id }, id);
    }

    /// <summary>PUT /api/kit-templates/{id} — оновити власний шаблон (системні не можна)</summary>
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateKitTemplateDto dto)
    {
        try
        {
            await _templateService.UpdateTemplateAsync(id, dto);
            return NoContent();
        }
        catch (KeyNotFoundException ex) { return NotFound(ex.Message); }
        catch (InvalidOperationException ex) { return BadRequest(ex.Message); }
    }

    /// <summary>DELETE /api/kit-templates/{id} — видалити власний шаблон</summary>
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            await _templateService.DeleteTemplateAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException ex) { return NotFound(ex.Message); }
        catch (InvalidOperationException ex) { return BadRequest(ex.Message); }
    }

    /// <summary>
    /// POST /api/kit-templates/apply/{kitId}/{templateId}
    /// Застосувати шаблон до аптечки — створює медикаменти з мінімальними кількостями.
    /// </summary>
    [HttpPost("apply/{kitId:guid}/{templateId:guid}")]
    public async Task<IActionResult> ApplyToKit(Guid kitId, Guid templateId)
    {
        try
        {
            await _templateService.ApplyTemplateToKitAsync(kitId, templateId);
            return Ok(new { message = "Шаблон успішно застосовано до аптечки." });
        }
        catch (KeyNotFoundException ex) { return NotFound(ex.Message); }
    }
}
