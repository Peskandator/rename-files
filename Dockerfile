FROM php:8.3-cli-alpine
WORKDIR /app
COPY rename.php .
ENTRYPOINT ["php", "rename.php"]
