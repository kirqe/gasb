FROM ruby:2.7.2

RUN apt-get update -qq && apt-get install -y build-essential ca-certificates libpq-dev nodejs postgresql-client yarn vim -y

ENV APP_ROOT /var/www/app

RUN mkdir -p $APP_ROOT

WORKDIR $APP_ROOT
RUN mkdir tmp
RUN mkdir tmp/pids

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY public public/

RUN gem install bundler
RUN bundle install

COPY config config/
COPY . .

EXPOSE 9292
