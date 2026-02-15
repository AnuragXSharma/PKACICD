FROM nginx:alpine
# Copy our custom HTML to the default Nginx directory
COPY src/index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
