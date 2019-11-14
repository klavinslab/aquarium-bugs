ARG RUBY_VERSION=2.6.5
ARG ALPINE_VERSION=3.10
FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}

RUN gem install octokit awesome_print rainbow

RUN mkdir /script
WORKDIR /script
COPY get-gh-issues.rb ./get-gh-issues.rb
