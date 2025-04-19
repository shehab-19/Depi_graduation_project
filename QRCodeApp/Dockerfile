# First stage: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /source

# Copy and restore dependencies
COPY *.csproj .
RUN dotnet restore

# Copy the rest of the application and build
COPY . .
RUN dotnet publish -c Release -o /app

# Final stage: Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install only necessary libraries for SkiaSharp package
RUN apt-get update && apt-get install -y \
    libfontconfig1 \
    libfreetype6 \
    libc6 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy the built application
COPY --from=build /app .

ENTRYPOINT ["dotnet", "QRCodeApp.dll"]
