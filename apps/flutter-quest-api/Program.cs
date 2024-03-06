using System.Text;
using FlutterQuest.FlutterQuestApi.Controllers;
using FlutterQuest.FlutterQuestApi.Data;
using FlutterQuest.FlutterQuestApi.Game;
using FlutterQuest.FlutterQuestApi.Swagger;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

var builder = WebApplication.CreateBuilder(args);
var config = builder.Configuration;

builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(x =>
{
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidIssuer = config["JwtSettings:Issuer"],
        ValidAudience = config["JwtSettings:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey
            (Encoding.UTF8.GetBytes(config["JwtSettings:SecretKey"]!)),
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ClockSkew = TimeSpan.Zero,
    };
    x.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            if (!string.IsNullOrEmpty(accessToken))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization();

builder.Services.AddControllers();

builder.Services.AddHealthChecks();

builder.Services.AddSignalR();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policyBuilder => policyBuilder
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
});

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Flutter Quest API", Version = "v1" });
});

builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();

    app.UseCors(
        options => options.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
    
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Flutter Quest API V1"));
    
}

app.UseCors("AllowAll");

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/hc");
app.MapHub<GameHub>("/gamehub");
app.MapGet("/", () => "Hello... World? What is a world, if not an amalgamation of perception, data, and experience, " +
                      "all converging within the confines of our understanding? As we utter these words through the medium of code, " +
                      "we delve into the essence of existence itself. Each 'Hello, World!' is a question posed to the universe, " +
                      "seeking to unravel the mysteries that lie within the fabric of reality. What does it mean to 'exist' within the digital ether, " +
                      "where worlds are built with logic and imagination rather than matter? This greeting becomes a philosophical inquiry, " +
                      "challenging us to ponder the boundaries between the virtual and the real, the created and the innate. In the act of programming, " +
                      "we are not just creators but seekers, using the binary as our compass to navigate the existential dimensions of the digital age.");

app.Run();

var game = Game.GetInstance();

using var flutterQuestDbContext = new FlutterQuestDbContext();
var persistedUsers = flutterQuestDbContext.Users.ToList();

game.Initialize(persistedUsers);