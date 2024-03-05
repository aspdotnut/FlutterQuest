namespace FlutterQuest.FlutterQuestApi.Models;

public class MovementIntent
{
    public double X { get; set; }
    public double Y { get; set; }
    private User user { get; set; }
    public MovementIntent(User user, string direction)
    {
        this.user = user;
        switch (direction)
        {
            case "Arrow Up":
                X = user.X;
                Y = user.Y - 4;
                break;
            case "Arrow Down":
                X = user.X;
                Y = user.Y + 4;
                break;
            case "Arrow Left":
                X = user.X - 4;
                Y = user.Y;
                break;
            case "Arrow Right":
                X = user.X + 4;
                Y = user.Y;
                break;
            default:
                throw new ArgumentException("Invalid direction. Please use Arrow Up, Arrow Down, Arrow Left, or Arrow Right.");
        }
    }

    public User Commit()
    {
        user.X = X;
        user.Y = Y;

        return user;
    }
}