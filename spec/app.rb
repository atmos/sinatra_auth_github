module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, {:client_id => ENV['GH_CLIENT_ID'],
                           :secret    => ENV['GH_SECRET'] }

    register Sinatra::Auth::Github

    before do
      authenticate!
    end

    get '/' do
      "Hello There, #{github_user.name}!"
    end

    get '/another_route' do
      "Hello There, #{github_user.name}!"
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
