FROM mcr.microsoft.com/dotnet/aspnet:10.0
EXPOSE 80

WORKDIR /app
COPY ./publish/app .

ENTRYPOINT ["dotnet", "VaultApplication.dll"]
