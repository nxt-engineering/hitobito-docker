FROM ruby:2.3 as base

RUN apt-get update && apt-get install -y \
    graphviz \
    imagemagick \
 && rm -rf /var/lib/apt/lists/*

RUN ln -s /app/.docker/entrypoint /bin/entrypoint; \
    ln -s /app/.docker/waitfortcp /bin/waitfortcp

WORKDIR /app/hitobito/
COPY hitobito/Wagonfile.ci ./Wagonfile
COPY hitobito/Gemfile hitobito/Gemfile.lock ./
RUN bundle install

ENV HITOBITO_WAGONS ""
COPY .docker/Wagonfile ./

WORKDIR /app/
COPY ./ ./

WORKDIR /app/hitobito/
RUN bundle install

####################################################################
FROM base as dev

ENV RAILS_ENV=development

ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "rails", "server", "-b", "0.0.0.0" ]

####################################################################
FROM dev as test

ENV RAILS_ENV=test

ENTRYPOINT [ "/bin/entrypoint" ]
CMD [ "rspec" ]

####################################################################
FROM ruby:2.6-alpine3.9 as prod

WORKDIR /app/hitobito
COPY hitobito/Gemfile hitobito/Gemfile.lock ./
RUN bundle install \
      --deployment \
      --frozen \
      --without=test \
      --without=development \
      --without=concolse \
      --without=metrics

COPY .docker/entrypoint .docker/waitfortcp /bin/

COPY hitobito/ ./

ENV RAILS_ENV=production

ENTRYPOINT [ "bundle", "exec" ]
CMD [ "rails", "serve" ]
