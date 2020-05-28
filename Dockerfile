FROM ruby:2.5.1
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN gem install bundler --pre
RUN mkdir /nomofomo
WORKDIR /nomofomo
ADD Gemfile /nomofomo/Gemfile
ADD Gemfile.lock /nomofomo/Gemfile.lock
ADD package.json /nomofomo/package.json
ADD package-lock.json /nomofomo/package-lock.json
RUN bundle install
RUN npm install
ADD . /nomofomo
EXPOSE 5000
