var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();


app.MapHealthChecks("/healthz");
app.MapGet("/configuration",
    (IConfiguration configuration) => Results.Ok
        (configuration.GetSection("VaultSecrets")
            .AsEnumerable().ToDictionary(k => k.Key, v => v.Value)));

app.Run();
