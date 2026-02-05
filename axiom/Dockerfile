# Flutter Web Dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$PATH:$FLUTTER_HOME/bin"
RUN wget -qO- https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz | tar -xJ -C /opt
RUN flutter channel stable && flutter upgrade

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml ./
COPY pubspec.lock ./

# Install Flutter dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build for web
RUN flutter build web --release

# Use nginx to serve the web app
FROM nginx:alpine
COPY --from=0 /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
