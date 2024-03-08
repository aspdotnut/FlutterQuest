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

using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FlutterQuest.FlutterQuestApi.Data;
using FlutterQuest.FlutterQuestApi.Models;
using FlutterQuest.FlutterQuestApi.ViewModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace FlutterQuest.FlutterQuestApi.Controllers;

[ApiController]
[Route("account")]
public class AccountController(IConfiguration config) : ControllerBase
{
    
    private readonly string _tokenSecret = config["JwtSettings:SecretKey"]!;
    private readonly TimeSpan _accessTokenLifetime = TimeSpan.FromMinutes(15);
    private readonly TimeSpan _refreshTokenLifetime = TimeSpan.FromHours(6);
    
    [Authorize]
    [HttpGet("authcheck")]
    public ActionResult GetAuthMessage()
    {
        return Ok( new { message = "I'm authenticated!" });
    }
    
    [HttpPost("login")]
    public ActionResult Login([FromBody] UserViewModel userViewModel)
    {
        var flutterQuestDbContext = new FlutterQuestDbContext();
        var user = flutterQuestDbContext.Users.FirstOrDefault(u => u.Name == userViewModel.Name && u.Password == userViewModel.Password);
        
        if (user == null)
        {
            return Unauthorized( new { Message = "User not found" });
        }
        
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_tokenSecret);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Sub, user.Name),
            new(JwtRegisteredClaimNames.Name, user.Name),
            new("userId", user.Id.ToString())
        };
        
        var accessTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_accessTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var refreshTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_refreshTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var accessToken = tokenHandler.CreateToken(accessTokenDescriptor);
        var refreshToken = tokenHandler.CreateToken(refreshTokenDescriptor);
        
        var accessJwt = tokenHandler.WriteToken(accessToken);
        var refreshJwt = tokenHandler.WriteToken(refreshToken);
        
        return Ok( new { AccessToken = accessJwt , RefreshToken = refreshJwt });
    }
    
    [HttpPost("register")]
    public ActionResult Register([FromBody] UserViewModel userViewModel)
    {
        var flutterQuestDbContext = new FlutterQuestDbContext();
        var existingUser = flutterQuestDbContext.Users.FirstOrDefault(u => u.Name == userViewModel.Name);
        
        if (existingUser != null)
        {
            return Conflict(new { Message = "User with name " + userViewModel.Name + " already exists" });
        }
        
        var user = new User(userViewModel.Name, userViewModel.Password);
        
        flutterQuestDbContext.Add(user);
        flutterQuestDbContext.SaveChanges();
        
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_tokenSecret);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Sub, user.Name),
            new(JwtRegisteredClaimNames.Name, user.Name),
            new("userId", user.Id.ToString())
        };
        
        var accessTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_accessTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var refreshTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_refreshTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var accessToken = tokenHandler.CreateToken(accessTokenDescriptor);
        var refreshToken = tokenHandler.CreateToken(refreshTokenDescriptor);
        
        var accessJwt = tokenHandler.WriteToken(accessToken);
        var refreshJwt = tokenHandler.WriteToken(refreshToken);
        
        return Ok( new { AccessToken = accessJwt , RefreshToken = refreshJwt });
    }
    
    [Authorize]
    [HttpPost("refresh")]
    public ActionResult Refresh()
    {
        var flutterQuestDbContext = new FlutterQuestDbContext();

        if (!int.TryParse(User.Claims.FirstOrDefault(c => c.Type == "userId")?.Value, out int userId))
        {
            return Unauthorized( new { Message = "User not found" });
        }

        var user = flutterQuestDbContext.Users.FirstOrDefault(a => a.Id == userId);
        
        if (user == null)
        {
            return Unauthorized(new { Message = "User not found" });
        }
        
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_tokenSecret);
        
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(JwtRegisteredClaimNames.Sub, user.Name),
            new(JwtRegisteredClaimNames.Name, user.Name),
            new("userId", userId.ToString())
        };
        
        var accessTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_accessTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var refreshTokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.Add(_refreshTokenLifetime),
            Issuer = "FlutterQuestApi",
            Audience = "FlutterQuestClient",
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        
        var accessToken = tokenHandler.CreateToken(accessTokenDescriptor);
        var refreshToken = tokenHandler.CreateToken(refreshTokenDescriptor);
        
        var accessJwt = tokenHandler.WriteToken(accessToken);
        var refreshJwt = tokenHandler.WriteToken(refreshToken);
        
        return Ok( new { AccessToken = accessJwt , RefreshToken = refreshJwt });
    }
}