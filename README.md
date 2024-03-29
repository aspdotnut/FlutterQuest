# FlutterQuest

FlutterQuest is a full-stack application developed with Flutter and .NET Core. It is a simple game where users can create an account, login, and join a lobby. In the lobby they can walk around and chat with other users.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- .NET Core 8.x
- MySQL Server
- Flutter SDK

### Installation

1. Clone the repository
2. Navigate to the .NET API directory
3. Run `dotnet restore` to install the dependencies for the API
4. Update the database connection string in `FlutterQuestDbContext.cs` if necessary
5. Run `dotnet ef database update` to create the database
6. Run `dotnet run` to start the API
7. Navigate to the Flutter client directory
8. Run `flutter pub get` to install the dependencies for the Flutter client
9. Run `flutter run` to start the Flutter client

## API

The API is a backend service developed in C# using .NET Core and Entity Framework. It provides endpoints for user account management and lobby interactions. For more details, refer to the [API documentation](apps/flutter-quest-api/README.md).

## Flutter Client

The Flutter client is a frontend service developed in Dart using Flutter. It provides a user interface for account management and lobby interactions. For more details, refer to the [client documentation](apps/flutter_quest_client/README.md).

## Built With

- [.NET Core](https://dotnet.microsoft.com/download) - The web framework used for the API
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/) - Object-Relational Mapping (ORM) framework used for the API
- [MySQL](https://www.mysql.com/) - Database used for the API
- [Flutter](https://flutter.dev/) - The UI toolkit used for the client

## Authors

- aspdotnut

## License

FlutterQuest  
A simple chatroom with certain game elements.  
Copyright (C) 2024 aspdotnut

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received [a copy of the GNU Affero General Public License](LICENSE.md)
along with this program.  If not, see <https://www.gnu.org/licenses/>.
