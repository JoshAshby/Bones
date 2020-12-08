FROM ruby

EXPOSE 3000

VOLUME /repos
VOLUME /shared

WORKDIR /code

ENV RACK_ENV production
COPY ./docker/ruby-entrypoint.sh ./

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY ./ ./

ENTRYPOINT ["/bin/bash", "ruby-entrypoint.sh"]
