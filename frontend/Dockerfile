
# Build stage
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci && npm cache clean --force

COPY . .

RUN npm run build

# Production stage
FROM nginx:stable-alpine AS production

RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run \
    && touch /var/run/nginx.pid \
    && chown -R 10001:10001 \
       /usr/share/nginx/html \
       /var/cache/nginx \
       /var/log/nginx \
       /var/run/nginx.pid

USER 10001:10001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
