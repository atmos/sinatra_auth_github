require 'pp'

module Example
  class App < Sinatra::Base
    enable :sessions

    set  :github_options, {
                            # GitHub Provided secrets
                            :secret       => ENV['GITHUB_CLIENT_SECRET'],
                            :client_id    => ENV['GITHUB_CLIENT_ID'],

                            # How much info you need about the user
                            :scopes       => 'user,offline_access,repo',

                            # restrict access to a members of organization named
                            :organization => "github",

                            # restrict access to specific team on an organization
                            :team         => nil # || 42
                           }

    register Sinatra::Auth::Github

    before do
      # authenticate!
      # halt([401, "Unauthorized User"]) unless github_organization_member?
    end

    helpers do
      def repos
        github_request("repos/show/#{github_user.login}")
      end
    end

    get '/' do
      authenticate!
      "Hello There, #{github_user.name}!#{github_user.token}\n#{repos.inspect}"
    end

    get '/orgs/:id' do
      github_organization_authenticate!(params['id'])
      "Hello There, #{github_user.name}! You have access to the #{params['id']} organization."
    end

    get '/orgs/:org_id/team/:id' do
      github_organization_team_authenticate!(params['org_id'], params['id'])
      "Hello There, #{github_user.name}! You have access to the #{params['id']} team under the #{params['org_id']} organization."
    end

    get '/logout' do
      logout!
      redirect '/'
    end
  end
end
