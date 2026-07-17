# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
ARG API_BASE_URL=http://localhost:8050

# Copiar manifesto primero para cachear dependencias.
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copiar codigo fuente completo.
COPY . .

# Build web release. API_BASE_URL se inyecta en compilacion con --dart-define.
RUN flutter build web --release --no-tree-shake-icons --pwa-strategy=none --dart-define=API_BASE_URL=${API_BASE_URL}

# Stage 2: Nginx serve
FROM nginx:1.27-alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
