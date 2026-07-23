# Multi-stage Dockerfile for Aurion
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY . ./
RUN dotnet restore "Aurion/Aurion.csproj"

# Publish
RUN dotnet publish "Aurion/Aurion.csproj" -c Release -r linux-x64 -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app
COPY --from=build /app/publish ./

ENTRYPOINT ["dotnet", "Aurion.dll"]
