require 'sinatra/base'
require 'warden-github'
require 'rest_client'

module Sinatra
  module Auth
    module Github
      VERSION = "0.0.14"

      class BadAuthentication < Sinatra::Base
        get '/unauthenticated' do
          status 403
          "Unable to authenticate, sorry bud."
        end
      end

      module Helpers
        def warden
          env['warden']
        end

        def authenticate!(*args)
          warden.authenticate!(*args)
        end

        def authenticated?(*args)
          warden.authenticated?(*args)
        end

        def logout!
          warden.logout
        end

        def github_user
          warden.user
        end

        # API Requests
        def github_request(path)
          response = RestClient.get "https://github.com/api/v2/json/#{path}", :params => { :access_token => github_user.token }, :accept => :json
          JSON.parse(response.body)
        end

        # Access Inquiries
        def github_organization_access?(name)
          orgs = github_request("user/show/#{github_user.login}/organizations")["organizations"]
          orgs.map { |org| org["login"] }.include?(name)
        end

        def github_organization_team_access?(name, team)
          members = github_request("teams/#{team}/members")["users"]
          members.map { |user| user["login"] }.include?(github_user.login)
        rescue RestClient::Unauthorized => e
          false
        end

        # Auth only certain individuals
        def github_organization_authenticate!(name)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_organization_access?(name)
        end

        def github_organization_team_authenticate!(name, team)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_organization_team_access?(name, team)
        end

        def _relative_url_for(path)
          request.script_name + path
        end
      end

      def self.registered(app)
        app.use Warden::Manager do |manager|
          manager.default_strategies :github

          manager.failure_app           = app.github_options[:failure_app] || BadAuthentication

          manager[:github_secret]       = app.github_options[:secret]
          manager[:github_scopes]       = app.github_options[:scopes] || 'email,offline_access'
          manager[:github_client_id]    = app.github_options[:client_id]
          manager[:github_organization] = app.github_options[:organization] || nil
          manager[:github_callback_url] = app.github_options[:callback_url] || '/auth/github/callback'
        end

        app.helpers Helpers

        app.get '/auth/github/callback' do
          authenticate!
          redirect _relative_url_for('/')
        end
      end
    end
  end
end
