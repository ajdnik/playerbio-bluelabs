FROM elixir:1.9-alpine as build

# Install missing make binary
RUN apk add --no-cache make

# Setup non interactive install
RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

WORKDIR /app

ADD . .

RUN make all


FROM build as test

RUN make check && make test


FROM build as release

RUN make release


FROM alpine:3.10

RUN apk add --no-cache \
      ncurses-libs \
      zlib \
      openssl \
      ca-certificates

COPY --from=release /app/_build/prod/rel/player_bio /app

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["/app/bin/player_bio"]
CMD ["foreground"]
