FROM elixir:alpine AS Builder

ENV MIX_ENV=prod \
  LANG=C.UTF-8

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get && \
  mix deps.compile && \
  mix phx.digest && \
  mix release

FROM elixir:alpine as App

ENV LANG=C.UTF-8

RUN apk add --no-cache --update busybox-extras bash openssl curl

WORKDIR /app

COPY --from=Builder _build .
CMD ["/app/prod/rel/hello/bin/hello", "start"]