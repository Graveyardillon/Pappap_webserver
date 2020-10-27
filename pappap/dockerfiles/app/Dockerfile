FROM elixir:1.9.4-alpine AS build

RUN apk add --no-cache build-base npm git python

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV DATABASE_URL=ecto://postgres:postgres@db/pappap
ENV SECRET_KEY_BASE=uTG/s/VxvRixaWqRdW1MrtOqGxAUL/m3VIA5HZAaMHvU/PixTV5V+vUeWhv5UEnY
ENV MIX_ENV=prod
ENV PORT=4001

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY priv priv
RUN ls priv
RUN ls priv/cert
COPY lib lib
#COPY rel rel
RUN mix compile
#RUN mix ecto.create
#RUN mix ecto.migrate
RUN mix release

FROM alpine:3.9 AS app
USER root
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/pappap ./

ENV HOME=/app

COPY ./entrypoint.sh .
RUN ls lib/pappap-0.1.0

RUN ls
RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]

