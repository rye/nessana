FROM docker.io/ruby:rc-alpine AS deps

RUN apk add -U gcc g++ make automake autoconf libtool

RUN mkdir /v
WORKDIR /v

ADD ["Gemfile", "Gemfile.lock", "/v/"]
RUN bundle install

FROM docker.io/ruby:rc-alpine

# COPY --from=deps /root/.gem/ruby/2.6.0/ /root/.gem/ruby/
COPY --from=deps /usr/local/lib/ruby/gems/2.6.0/ /usr/local/lib/ruby/gems/2.6.0/
COPY --from=deps /usr/local/bundle/ /usr/local/bundle/

COPY --from=deps /v/ /
WORKDIR /v

ADD . /v/

CMD bundle exec ruby process.rb
