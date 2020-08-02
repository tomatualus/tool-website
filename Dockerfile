FROM node:10.22.0-alpine as node
WORKDIR /app
COPY ./assets ./assets
COPY ./package*.json ./
COPY ./app.json ./
COPY ./App.tsx ./
COPY ./babel.config.js ./
COPY ./.expo-shared ./.expo-shared
RUN yarn
RUN yarn global add expo-cli
COPY ./frontend ./frontend
RUN yarn run build

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS builder
WORKDIR /backend
COPY ./backend .
RUN dotnet restore
RUN dotnet publish -c Release -r linux-musl-x64 -o /app

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
WORKDIR /app
COPY --from=builder ./app .
COPY --from=node ./app/web-build ./wwwroot
CMD ASPNETCORE_URLS=http://*:$PORT ./AspNetCoreDemoApp