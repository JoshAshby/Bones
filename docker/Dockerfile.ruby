FROM ruby

EXPOSE 3000

VOLUME /repos
VOLUME /shared

WORKDIR /code

ENV RACK_ENV production
COPY ./docker/ruby-entrypoint.sh ./

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY env.rb config.ru Rakefile ./
COPY app app/
COPY bin bin/
COPY config config/
COPY lib lib/
COPY migrations migrations/
COPY public public/

ENTRYPOINT ["/bin/bash", "ruby-entrypoint.sh"]
