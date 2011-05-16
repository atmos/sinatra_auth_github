sinatra_auth_github
===================

A sinatra extension that provides oauth authentication to github.  Find out more about enabling your application at github's [oauth quickstart](http://gist.github.com/419219).

To test it out on localhost set your callback url to 'http://localhost:9292/auth/github/callback'

There's an example app in [spec/app.rb](/atmos/sinatra_auth_github/blob/master/spec/app.rb).

There's a slightly more deployment friendly version [href](http://gist.github.com/421704).

The Extension in Action
=======================
    % gem install bundler
    % bundle install
    % GITHUB_CLIENT_ID="<from GH>" GITHUB_CLIENT_SECRET="<from GH>" bundle exec shotgun

```ruby
module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, {
                            # GitHub Provided secrets
                            :secret       => ENV['GITHUB_CLIENT_SECRET'],
                            :client_id    => ENV['GITHUB_CLIENT_ID'],

                            # How much info you need about the user
                            :scopes       => 'user,offline_access',

                            # restrict access to a members of organization named
                            :organization => "github",

                            # restrict access to specific team on an organization
                            :team         => nil # || 42
                          }

    register Sinatra::Auth::Github

    before do
      authenticate!
    end

    helpers do
      def repos
        github_request("repos/show/#{github_user.login}")
      end
    end

    get '/' do
      "Hello There, #{github_user.name}!#{github_user.token}\n#{repos.inspect}"
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
```
