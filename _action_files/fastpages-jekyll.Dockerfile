FROM jekyll/jekyll:4.4.1

COPY . .
RUN chmod -R 777 .
RUN bundle install
RUN bundle exec jekyll build
