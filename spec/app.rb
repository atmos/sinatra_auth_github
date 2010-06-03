require 'pp'

module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, {:client_id => ENV['GH_CLIENT_ID'], :secret => ENV['GH_SECRET'] }

    register Sinatra::Auth::Github

    before do
      authenticate!
    end

    helpers do
      def repos
        JSON.parse(access_token.get("/api/v2/json/repos/show/#{github_user.attribs['login']}"))
      end

      def access_token
        @access_token ||= github_oauth_proxy.access_token_for(github_user.token)
      end
    end

    get '/' do
      "Hello There, #{github_user.name}!\n#{repos.inspect}"
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
