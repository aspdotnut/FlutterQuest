using FlutterQuest.FlutterQuestApi.Data;
using FlutterQuest.FlutterQuestApi.Models;
using FlutterQuest.FlutterQuestApi.ViewModels;
using Microsoft.AspNetCore.SignalR;

namespace FlutterQuest.FlutterQuestApi.Controllers;

public class GameHub : Hub
{
    /// <summary>
    /// postman json:
    /// { "protocol": "json", "version": 1 }
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        await Clients.All.SendAsync("ReceiveMessage", $"{Context.ConnectionId} joined");
    }
    
    /// <summary>
    /// postman json:
    /// { "arguments": [], "target": "JoinLobby", "type": 1 }
    /// </summary>
    public async Task JoinLobby()
    {
        var flutterQuestDbContext = new FlutterQuestDbContext();
        
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            return;
        }

        var user = flutterQuestDbContext.Users.FirstOrDefault(u => u.Id == userId);
        
        if (user == null)
        {
            return;
        }

        Game.Game.GetInstance().AddUser(user);
        
        await Clients.All.SendAsync("ReceiveMessage", new ActiveUserViewModel() { Id = user.Id, Name = user.Name, X = user.X, Y = user.Y });
    }
    
    /// <summary>
    /// postman json:
    /// { "arguments": ["Arrow Down"], "target": "Move", "type": 1 }
    /// </summary>
    public async Task Move(string direction)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            return;
        }

        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            return;
        }

        var intent = new MovementIntent(user, direction);

        if (!Game.Game.CheckMovement(intent)) return;
        
        var updatedUser = intent.Commit();
        Game.Game.GetInstance().UpdateUser(updatedUser);

        await Clients.All.SendAsync("ReceiveMessage", new ActiveUserViewModel() { Id = updatedUser.Id, Name = updatedUser.Name, X = updatedUser.X, Y = updatedUser.Y });
    }
}