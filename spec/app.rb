require 'pp'
require 'ruby-debug'

module Example
  class App < Sinatra::Base
    enable :sessions

    set :github_options, {
      :secret    => ENV['GITHUB_CLIENT_SECRET'],
      :client_id => ENV['GITHUB_CLIENT_ID'],
    }

    register Sinatra::Auth::Github

    helpers do
      def repos
        github_request("user/repos")
      end
    end

    get '/' do
      authenticate!
      "Hello There, #{github_user.name}!#{github_user.token}\n#{repos.inspect}"
    end

    get '/orgs/:id' do
      github_public_organization_authenticate!(params['id'])
      "Hello There, #{github_user.name}! You have access to the #{params['id']} organization."
    end

    # the scopes above need to include repo for team access :(
    # get '/teams/:id' do
    #   github_team_authenticate!(params['id'])
    #   "Hello There, #{github_user.name}! You have access to the #{params['id']} team."
    # end

    get '/logout' do
      logout!
      redirect 'https://github.com'
    end
  end
end
