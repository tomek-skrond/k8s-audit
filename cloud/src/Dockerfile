FROM golang:1.21.6 AS build-stage

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY home.html ./
COPY *.go ./

RUN ls -la

RUN CGO_ENABLED=0 GOOS=linux go build -o /fruitapp


EXPOSE 1323

ENTRYPOINT ["/fruitapp"]