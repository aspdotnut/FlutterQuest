using System.Net.Http.Headers;
using FlutterQuest.FlutterQuestApi.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlutterQuest.FlutterQuestApi.Controllers;

[Authorize]
[ApiController]
[Route("movement")]
public class MovementController : ControllerBase
{
    [AllowAnonymous]
    [HttpGet("healthcheck")]
    public ActionResult GetHealthyMessage()
    {
        return Ok("I'm healthy!");
    }
    
    [HttpPost("move")]
    public ActionResult Move([FromBody] DirectionViewModel directionViewModel)
    {
        var direction = directionViewModel.Direction;
        
        switch (direction)
        {
            case "Arrow Up":
                return Ok( new { message = "Moved up" });
            case "Arrow Down":
                return Ok( new { message = "Moved down" });
            case "Arrow Left":
                return Ok( new { message = "Moved left" });
            case "Arrow Right":
                return Ok( new { message = "Moved right" });
            default:
                return BadRequest(new
                    { message = "Invalid direction. Please use Arrow Up, Arrow Down, Arrow Left, or Arrow Right." });
        }
    }
}

