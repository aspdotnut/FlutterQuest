namespace FlutterQuest.FlutterQuestApi.Models;

public class ActiveUser(string name, double x, double y)
{
    public int Id { get; set; }
    public string Name { get; set; } = name;
    public double X { get; set; } = x;
    public double Y { get; set; } = y;
}
