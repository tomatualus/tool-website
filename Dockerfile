FROM node:10.13.0-alpine as node
WORKDIR /app
COPY ./frontend/public ./public
COPY ./frontend/src/index.js ./src/index.js
COPY ./frontend/package*.json ./
RUN npm install --progress=true --loglevel=silent
COPY ./frontend/src/client ./src/client/
RUN npm run build

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder
WORKDIR /backend
COPY . .
RUN dotnet restore
RUN dotnet publish -c Release -r linux-musl-x64 -o /app

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
WORKDIR /app
COPY --from=builder /app .
COPY --from=node /app/build ./wwwroot
CMD ASPNETCORE_URLS=http://*:$PORT ./AspNetCoreDemoApp
