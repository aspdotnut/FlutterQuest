using FlutterQuest.FlutterQuestApi.Models;

namespace FlutterQuest.FlutterQuestApi.Game;

public class Game
{
    private List<User> users;
    private const double Width = 200;
    private const double Height = 200;
    private Game()
    {
        users = new List<User>();
    }
    
    public void Initialize(List<User> persistedUsers)
    {
        users = persistedUsers;
    }
    
    public void AddUser(User user)
    {
        if (users.Any(u => u.Name == user.Name))
        {
            return;
        }
        users.Add(user);
    }
    
    public User? GetUser(int id)
    {
        return users.FirstOrDefault(u => u.Id == id);
    }

    public void UpdateUser(User user)
    {
        var existingUser = users.FirstOrDefault(u => u.Id == user.Id);
        if (existingUser == null)
        {
            return;
        }
        
        existingUser.X = user.X;
        existingUser.Y = user.Y;
    }
    
    public void RemoveUser(int id)
    {
        if (users.All(u => u.Id != id)) return;
        
        users.RemoveAll(u => u.Id == id);
    }
    
    public static bool CheckMovement(MovementIntent movementIntent)
    {
        return !(movementIntent.X < 0 || movementIntent.X > Width || movementIntent.Y < 0 || movementIntent.Y > Height);
    }
    
    public List<User> GetUsers()
    {
        return users;
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
