using FlutterQuest.FlutterQuestApi.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FlutterQuest.FlutterQuestApi.Game;
using FlutterQuest.FlutterQuestApi.Models;
using FlutterQuest.FlutterQuestApi.ViewModels;

namespace FlutterQuest.FlutterQuestApi.Controllers;

[Authorize]
[ApiController]
[Route("game")]
public class GameController : ControllerBase
{
    [HttpGet("lobby")]
    public ActionResult Lobby()
    {
        return Ok(Game.Game.GetInstance().GetUsers().Select((u) => new ActiveUserViewModel()
        {
            Id = u.Id,
            Name = u.Name,
            X = u.X,
            Y = u.Y,
            IsActive = true,
        }));
    }
}