var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

builder.Configuration
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
    .AddJsonFile("/vault/secrets/appsettings.json", optional: true, reloadOnChange: true);

var app = builder.Build();

app.MapHealthChecks("/healthz");
app.MapGet("/config",
    (IConfiguration configuration) => Results.Ok
        (configuration.GetSection("VaultSecrets")
            .AsEnumerable().ToDictionary(k => k.Key, v => v.Value)));

app.Run();
