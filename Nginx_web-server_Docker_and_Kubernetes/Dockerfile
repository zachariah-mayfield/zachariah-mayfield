# Building an Nginx Image from Scratch

# Nginx image
FROM nginx:latest

# Copy website files into the container
COPY ./your-website /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
