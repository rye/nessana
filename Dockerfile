FROM docker.io/ruby:rc-alpine AS deps

RUN apk add -U gcc g++ make automake autoconf libtool

WORKDIR /nessana/

ADD . /nessana/

RUN bundle install --deployment

RUN bundle exec gem build nessana.gemspec

RUN bundle exec gem install --local nessana-*.gem

CMD bundle exec nessana
