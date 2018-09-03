FROM golang:1.10.3-alpine as builder

RUN apk update && \
    apk add ca-certificates git build-base 

RUN go get -u github.com/golang/dep/cmd/dep

ENV GOPATH /opt/project

ADD Gopkg.* /opt/project/src/github.com/tweakmy/docker-registry-ui/

ADD events /opt/project/src/github.com/tweakmy/docker-registry-ui/events
ADD registry /opt/project/src/github.com/tweakmy/docker-registry-ui/registry
ADD *.go /opt/project/src/github.com/tweakmy/docker-registry-ui/
WORKDIR /opt/project/src/github.com/tweakmy/docker-registry-ui  
RUN dep ensure -v
RUN go test -v ./registry 
RUN go build -o /opt/docker-registry-ui github.com/tweakmy/docker-registry-ui


FROM alpine:3.8

WORKDIR /opt
RUN apk add --no-cache ca-certificates && \
    mkdir /opt/data

ADD templates /opt/templates
ADD static /opt/static
COPY --from=builder /opt/docker-registry-ui /opt/

USER nobody
ENTRYPOINT ["/opt/docker-registry-ui"]
