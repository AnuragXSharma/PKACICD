FROM nginx:alpine
# Create a simple HTML file for Nginx to serve
RUN echo "<h1>Hello from PKACICD Pipeline</h1><p>Status: Running on EKS</p>" > /usr/share/nginx/html/index.html
# The nginx:alpine image already has the correct CMD to stay running
