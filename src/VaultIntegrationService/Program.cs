var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();


app.MapGet("/configuration",
    (IConfiguration configuration) => Results.Ok
        (configuration.GetSection("VaultSecrets")
            .AsEnumerable().ToDictionary(k => k.Key, v => v.Value)));

app.Run();
