using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlutterQuest.FlutterQuestApi.Controllers;

[Authorize]
[ApiController]
[Route("chat")]
public class ChatController : ControllerBase
{
    [AllowAnonymous]
    [HttpGet("healthcheck")]
    public ActionResult GetHealthyMessage()
    {
        return Ok("I'm healthy!");
    }
}