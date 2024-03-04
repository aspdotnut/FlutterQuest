namespace FlutterQuest.FlutterQuestApi.Models;

public class User(string name, string password)
{
    public int Id { get; set; }
    public string Name { get; set; } = name;
    public string Password { get; set; } = password;
}
