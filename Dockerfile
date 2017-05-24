FROM ruby:2.4.0
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
RUN gem install bundler
RUN bundle install
ADD . /app
