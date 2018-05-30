FROM docker.io/ruby:rc-alpine AS deps

RUN apk add -U gcc g++ make automake autoconf libtool

WORKDIR /nessana/

ADD ["Gemfile", "Gemfile.lock", "/nessana/"]
RUN bundle install --deployment

ADD . /nessana/

CMD bundle exec ruby process.rb
