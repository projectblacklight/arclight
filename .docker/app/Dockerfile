ARG ALPINE_RUBY_VERSION

FROM --platform=linux/amd64 ruby:${ALPINE_RUBY_VERSION}-bookworm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && \
    apt-get install -y \
  bash \
  build-essential \
  git \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  shared-mime-info \
  sqlite3 \
  tzdata \
  yarn

RUN mkdir /app
WORKDIR /app

RUN gem update --system && \
  gem install bundler && \
  bundle config build.nokogiri --use-system-libraries

COPY . .

EXPOSE 3000

CMD [".docker/app/entrypoint.sh"]
