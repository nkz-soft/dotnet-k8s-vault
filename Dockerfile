FROM mcr.microsoft.com/dotnet/aspnet:7.0
EXPOSE 80
EXPOSE 81

WORKDIR /app
COPY ./publish/app .

ENTRYPOINT ["dotnet", "VaultApplication.dll"]
