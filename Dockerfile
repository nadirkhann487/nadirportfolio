# syntax = docker/dockerfile:experimental
ARG RUBY_VERSION=2.7.0
ARG VARIANT=jemalloc-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

ARG NODE_VERSION=14
ARG BUNDLER_VERSION=2.3.9

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

SHELL ["/bin/bash", "-c"]

RUN curl https://get.volta.sh | bash

ENV BASH_ENV ~/.bashrc
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:/usr/local/bin:$PATH

RUN volta install node@${NODE_VERSION} && volta install yarn@1.22.19

FROM base as build_deps

ARG DEV_PACKAGES="git build-essential libpq-dev wget vim curl gzip xz-utils libsqlite3-dev"
ENV DEV_PACKAGES ${DEV_PACKAGES}

ARG DOCKER_BUILDKIT=1

RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${DEV_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM build_deps as gems

RUN gem install -N bundler -v ${BUNDLER_VERSION}

COPY Gemfile* ./
RUN bundle install &&  rm -rf vendor/bundle/ruby/*/cache

FROM build_deps as node

ARG PROD_PACKAGES="postgresql-client file vim curl gzip libsqlite3-0"
ENV PROD_PACKAGES=${PROD_PACKAGES}

RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${PROD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Python 3
RUN apt-get update && apt-get install -y python2

COPY --from=gems /app /app
COPY package*json yarn.* ./
# Manually remove node-sass package
RUN rm -rf node_modules/node-sass

# Install sass and other dependencies
RUN yarn add sass && yarn install

# NEW STAGE FOR DATABASE RESTORATION
FROM node as db_restoration

# Install PostgreSQL client
ARG PROD_PACKAGES="postgresql-client"
ENV PROD_PACKAGES=${PROD_PACKAGES}

RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${PROD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy the database dump file into the image
COPY latest.dump /app/latest.dump

# Restore the database using the latest.dump file
RUN bundle exec rake db:create && \
    bundle exec rake db:pg_restore latest.dump

# CONTINUE WITH THE REST OF THE DOCKERFILE
COPY . .

RUN bundle exec rails assets:precompile

ENV PORT 8080

ARG SERVER_COMMAND="bundle exec puma -C config/puma.rb"
ENV SERVER_COMMAND ${SERVER_COMMAND}
CMD ${SERVER_COMMAND}
