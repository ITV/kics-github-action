ARG DOCKERHUB_REGISTRY=docker.io
FROM ${DOCKERHUB_REGISTRY}/checkmarx/kics:v2.1.13 as kics-env

FROM cgr.dev/chainguard/wolfi-base:latest

# Install Node.js and npm
RUN apk add --update nodejs npm

COPY --from=kics-env /app /app

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Copy package files first for better Docker layer caching
COPY package*.json /app/

# Set working directory and install dependencies
WORKDIR /app
RUN npm ci

# Copy rest of the application files
COPY ./ /app/

# Build the application
RUN npm run build --if-present

ENTRYPOINT ["/entrypoint.sh"]