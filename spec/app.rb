require 'pp'
require 'rest_client'

module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, {:client_id => ENV['GITHUB_CLIENT_ID'], :secret => ENV['GITHUB_SECRET'], :scopes => 'user,offline_access,repo' }

    register Sinatra::Auth::Github

    before do
      authenticate!
    end

    helpers do
      def repos
        github_request("repos/show/#{github_user.attribs['login']}")
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
