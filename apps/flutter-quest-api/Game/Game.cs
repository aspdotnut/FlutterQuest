// FlutterQuest
// A simple chatroom with certain game elements.
// Copyright (C) 2024 aspdotnut
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

using FlutterQuest.FlutterQuestApi.Models;

namespace FlutterQuest.FlutterQuestApi.Game;

public class Game
{
    private List<User> _users;
    private const int Width = 9001;
    private const int Height = 9001;
    private Game()
    {
        _users = new List<User>();
    }
    
    public void Initialize(List<User> persistedUsers)
    {
        _users = persistedUsers;
    }
    
    public void AddUser(User user)
    {
        if (_users.Any(u => u.Name == user.Name))
        {
            return;
        }
        _users.Add(user);
    }
    
    public User? GetUser(int id)
    {
        return _users.FirstOrDefault(u => u.Id == id);
    }

    public void UpdateUser(User user)
    {
        var existingUser = _users.FirstOrDefault(u => u.Id == user.Id);
        if (existingUser == null)
        {
            return;
        }
        
        existingUser.X = user.X;
        existingUser.Y = user.Y;
        existingUser.LegMovement = user.LegMovement;
    }
    
    public void RemoveUser(int id)
    {
        if (_users.All(u => u.Id != id)) return;
        
        _users.RemoveAll(u => u.Id == id);
    }
    
    public static bool CheckMovement(MovementIntent movementIntent)
    {
        return !(movementIntent.X < 0 || movementIntent.X > Width || movementIntent.Y < 0 || movementIntent.Y > Height);
    }
    
    public List<User> GetUsers()
    {
        return _users;
    }
    
    private static Game? _instance;
    public static Game GetInstance()
    {
        if (_instance != null)
        {
            return _instance;
        }
        
        _instance = new Game();
        return _instance;
    }
}
