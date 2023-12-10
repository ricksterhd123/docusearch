FROM ruby:alpine3.19

# build-base and openssl-dev are required to install gems
RUN apk add build-base git openssl-dev

WORKDIR /docusearch
COPY Gemfile Gemfile.lock docusearch.gemspec ./

# install gems
RUN bundle install

COPY . .

# fill elasticsearch with dummy data (for demo purposes)
# startup falcon webserver (entrypoint: config.ru)
CMD bundle && bundle exec docusearch && bundle exec falcon host
