FROM node:10.22.0-alpine as node
WORKDIR /app
COPY . .
RUN yarn
RUN yarn global add expo-cli
RUN yarn run build

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder
WORKDIR /source
COPY .backend .
RUN dotnet restore
RUN dotnet publish -c Release -r linux-musl-x64 -o /app

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
WORKDIR /app
COPY --from=builder /app .
COPY --from=node /app/web-build ./wwwroot
CMD ASPNETCORE_URLS=http://*:$PORT ./ToolBackend