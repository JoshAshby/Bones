FROM ruby

EXPOSE 3000

VOLUME /repos
VOLUME /shared

WORKDIR /code

ENV RACK_ENV production

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY ./ ./

ENTRYPOINT ["/bin/bash", "docker/ruby-entrypoint.sh"]
