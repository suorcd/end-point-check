FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache bash curl drill coreutils


# Copy the script into the container
COPY epc.sh /usr/local/bin/epc.sh

# Make the script executable
RUN chmod +x /usr/local/bin/epc.sh

# Set the entry point to the script
ENTRYPOINT ["/usr/local/bin/epc.sh"]