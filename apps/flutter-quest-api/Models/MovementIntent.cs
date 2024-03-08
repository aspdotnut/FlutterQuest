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