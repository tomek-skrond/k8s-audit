FROM golang:1.21.6 AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY home.html ./
COPY *.go ./

RUN ls -la

RUN CGO_ENABLED=0 GOOS=linux go build -o /fruitapp

# # Deploy the application binary into a lean image
# # FROM gcr.io/distroless/base-debian11 AS build-release-stage
# FROM golang:1.21.6 AS build-release-stage

# WORKDIR /

# COPY --from=build-stage /app/home.html ./
# COPY --from=build-stage /fruitapp /fruitapp

EXPOSE 1323

# USER nonroot:nonroot

ENTRYPOINT ["/fruitapp"]