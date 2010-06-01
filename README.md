sinatra_auth_github
===================

A sinatra extension that provides oauth authentication to github.  Find out more about enabling your application at github's [oauth quickstart](http://gist.github.com/419219).

To test it out on localhost set your callback url to 'http://localhost:9292/auth/github/callback'

There's an example app in [spec/app.rb](/spec/app.rb).

The Extension in Action
=======================
    % gem install bundler
    % bundle install
    % GH_CLIENT_ID="<from GH>" GH_SECRET="<from GH>" bundle exec rackup
