FROM elixir:1.10-alpine
ARG app_name=pappap
ARG phoenix_subdir=.
ARG build_env=prod
ENV MIX_ENV=${build_env} TERM=xterm

WORKDIR /opt/app
RUN apk update \
  && apk --no-cache --update add nodejs \
  && apk add npm \
  && apk add libc6-compat libstdc++ \
  && mix local.rebar --force \
  && mix local.hex --force

COPY . .
COPY priv priv
RUN mix do deps.get, compile
RUN echo y|mix ua_inspector.download
RUN mix release ${app_name} \
  && mv _build/${build_env}/rel/${app_name} /opt/release \
  && mv /opt/release/bin/${app_name} /opt/release/bin/start_server

RUN mkdir -p /opt/release/static/image/tmp
COPY ./static /opt/release/static
RUN chmod 777 /opt/release/static
RUN ls /opt/release

FROM alpine:latest
ARG project_id
RUN apk update \
  && apk add libc6-compat libstdc++ \
  && apk --no-cache --update add bash ca-certificates openssl-dev \
  && mkdir -p /usr/local/bin \
  && wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 \
  -O /usr/local/bin/cloud_sql_proxy \
  && chmod +x /usr/local/bin/cloud_sql_proxy \
  && mkdir -p /tmp/cloudsql

#ENV PORT=8080 GCLOUD_PROJECT_ID=${project_id} REPLACE_OS_VARS=true
ENV PORT=8080 GCLOUD_PROJECT_ID=e-players6814 REPLACE_OS_VARS=true
ENV MIX_ENV=prod
EXPOSE ${PORT}
WORKDIR /opt/app
COPY --from=0 /opt/release .
#RUN mix ua_inspector.download
CMD (/usr/local/bin/cloud_sql_proxy \
  -projects=${GCLOUD_PROJECT_ID} -dir=/tmp/cloudsql &); \
  exec /opt/app/bin/start_server start

