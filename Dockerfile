FROM docker.io/ruby:rc-alpine AS deps

RUN apk add -U gcc g++ make automake autoconf libtool

WORKDIR /nessana/

ADD ["Gemfile", "Gemfile.lock", "/nessana/"]
RUN bundle install --deployment

ADD . /nessana/

RUN gem build nessana.gemspec

RUN gem install --local nessana-*.gem

CMD bundle exec nessana
