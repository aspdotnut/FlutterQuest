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
        var flutterQuestDbContext = new FlutterQuestDbContext();
        
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = flutterQuestDbContext.Users.FirstOrDefault(u => u.Id == userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        Game.Game.GetInstance().AddUser(user);
        
        await Clients.All.SendAsync("ReceiveMessage", 2, new ActiveUserViewModel { Id = user.Id, Name = user.Name, X = user.X, Y = user.Y, IsActive = true });
    }
    
    /// <summary>
    /// postman json:
    /// { "arguments": ["Arrow Down"], "target": "Move", "type": 1 }
    /// </summary>
    public async Task Move(string direction)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var intent = new MovementIntent(user, direction);

        if (!Game.Game.CheckMovement(intent)) return;
        
        var updatedUser = intent.Commit();
        Game.Game.GetInstance().UpdateUser(updatedUser);

        await Clients.All.SendAsync("ReceiveMessage", 2, new ActiveUserViewModel { Id = updatedUser.Id, Name = updatedUser.Name, X = updatedUser.X, Y = updatedUser.Y, IsActive = true });
    }
    
    public override async Task OnDisconnectedAsync(Exception exception)
    {
        if (!int.TryParse(Context.User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }

        var user = Game.Game.GetInstance().GetUser(userId);
        
        if (user == null)
        {
            await Clients.Caller.SendAsync("ReceiveMessage", 1, new ErrorMessageViewModel { Message = "User not found" });
            return;
        }
        
        var flutterQuestDbContext = new FlutterQuestDbContext();
        
        var dbUser = flutterQuestDbContext.Users.FirstOrDefault(u => u.Id == userId);
        
        if (dbUser != null)
        {
            dbUser.X = user.X;
            dbUser.Y = user.Y;
        
            await flutterQuestDbContext.SaveChangesAsync();
        }
        
        Game.Game.GetInstance().RemoveUser(user.Id);
        
        await Clients.All.SendAsync("ReceiveMessage", 2, new ActiveUserViewModel { Id = user.Id, Name = user.Name, X = user.X, Y = user.Y, IsActive = false });
    }
}