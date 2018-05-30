FROM docker.io/ruby:rc-alpine AS deps

RUN apk add -U gcc g++ make automake autoconf libtool

WORKDIR /nessana/

ADD . /nessana/

RUN bundle install

RUN gem build nessana.gemspec

RUN gem install --local nessana-*.gem

CMD nessana
