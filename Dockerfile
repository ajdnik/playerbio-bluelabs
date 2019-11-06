#===========
#Build Stage
#===========
FROM elixir:1.9-alpine as build

# Install dependencies
RUN apk add --no-cache make && \
    mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

WORKDIR /app
COPY . .

RUN make all

#===========
#Test Stage
#===========
FROM build as test
RUN make check && make test

#===========
#Release Stage
#===========
FROM build as release
RUN make release

#===========
#Deployment Stage
#=========== 
FROM alpine:3.10

# Installing dependencies based on https://github.com/bitwalker/alpine-erlang
RUN apk add --no-cache \
      ncurses-libs \
      zlib \
      openssl \
      ca-certificates && \
    mkdir -p /app && \
    adduser -s /bin/sh -u 1001 -G root -h /app -S -D default && \
    chown -R 1001:0 /app

COPY --from=release /app/_build/prod/rel/player_bio /app

RUN chown -R 1001:0 /app

WORKDIR /app

USER default

EXPOSE 8080

ENTRYPOINT ["/app/bin/player_bio"]
CMD ["foreground"]
