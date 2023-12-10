# docusearch-api

This is the backend REST API for the docusearch-app, a read-only thin wrapper around elasticsearch (gem provides library methods for writing), built using ruby, rack and elasticsearch client.

## Getting Started

### Requirements
- linux (preferably)
- ruby 3.2.2, including gem and bundler
- git

### Setup (Development)
1. clone this repository and cd into directory
2. run `bundle install` to install dependency gems
3. run `bundle exec rackup` to run development webserver with entrypoint defined in `config.ru`
