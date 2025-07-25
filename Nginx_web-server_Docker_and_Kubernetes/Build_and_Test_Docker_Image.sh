# Build the Docker image
docker build -t my-website .

# Run the container
docker run -p 8080:80 my-website
