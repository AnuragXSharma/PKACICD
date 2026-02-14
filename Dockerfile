FROM alpine:latest
RUN echo "Hello from PKACICD Pipeline" > /hello.txt
CMD ["cat", "/hello.txt"]
