FROM ruby:alpine3.19

# build-base and openssl-dev are required to install gems
RUN apk add build-base git openssl-dev

WORKDIR /docusearch
COPY Gemfile Gemfile.lock docusearch.gemspec ./

# install gems
RUN bundle install --without development test

COPY . .

# startup falcon webserver (entrypoint: config.ru)
CMD bundle exec falcon host
