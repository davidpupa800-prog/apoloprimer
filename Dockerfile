FROM nginxinc/nginx-unprivileged:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
COPY apoloprimer-intro.mp4 /usr/share/nginx/html/apoloprimer-intro.mp4
