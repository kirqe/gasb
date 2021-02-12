FROM ruby:2.7.2

RUN apt-get update -qq && apt-get install -y build-essential ca-certificates libpq-dev nodejs postgresql-client yarn

ENV APP_ROOT /var/www/app
RUN mkdir -p $APP_ROOT

WORKDIR $APP_ROOT

ENV RACK_ENV="development"
ENV SECRET_KEY_BASE="1214801aa2617460e0065a399496c7fed9bb9751783a81798ebdfb58caa2d45673453c40a1cc53cfb710b26342253f813c644049e2c9e261e01cdab967ad71b3"


COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
COPY . .

# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh

# ENTRYPOINT ["sh", "./entrypoint.sh"]
EXPOSE 9292


CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
  