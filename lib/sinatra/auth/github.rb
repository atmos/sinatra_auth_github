require 'sinatra/base'
require 'warden-github'
require 'rest_client'

module Sinatra
  module Auth
    module Github
      VERSION = "0.1.1"

      class AccessDenied < Sinatra::Base
        get '/_images/securocat.png' do
          send_file(File.join(File.dirname(__FILE__), "views", "securocat.png"))
        end
      end

      class BadAuthentication < Sinatra::Base
        helpers do
          def unauthorized_template
            @unauthenticated_template ||= File.read(File.join(File.dirname(__FILE__), "views", "401.html"))
          end
        end

        get '/unauthenticated' do
          status 403
          unauthorized_template
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

        # Send a V3 API GET request to path
        #
        # path - the path on api.github.com to hit
        #
        # Returns a rest client response object
        #
        # Examples
        #   github_raw_request("/user")
        #   # => RestClient::Response
        def github_raw_request(path)
          RestClient.get("https://api.github.com/#{path}", :params => { :access_token => github_user.token }, :accept => :json)
        end

        # Send a V3 API GET request to path and JSON parse the response body
        #
        # path - the path on api.github.com to hit
        #
        # Returns a parsed JSON response
        #
        # Examples
        #   github_raw_request("/user")
        #   # => { 'login' => 'atmos', ... }
        def github_request(path)
          JSON.parse(github_raw_request(path))
        end

        # See if the user is a member of the named organization
        #
        # name - the organization name
        #
        # Returns: true if the uesr has access, false otherwise
        def github_organization_access?(name)
          orgs = github_request("orgs/#{name}/members")
          orgs.map { |org| org["login"] }.include?(github_user.login)
        rescue RestClient::Unauthorized, RestClient::ResourceNotFound => e
          false
        end

        # See if the user is a member of the team id
        #
        # team_id - the team's id
        #
        # Returns: true if the uesr has access, false otherwise
        def github_team_access?(team_id)
          members = github_request("teams/#{team_id}/members")
          members.map { |user| user["login"] }.include?(github_user.login)
        rescue RestClient::Unauthorized, RestClient::ResourceNotFound => e
          false
        end

        # Auth only certain individuals
        def github_organization_authenticate!(name)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_organization_access?(name)
        end

        def github_team_authenticate!(team_id)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_team_access?(team_id)
        end

        def _relative_url_for(path)
          request.script_name + path
        end
      end

      def self.registered(app)
        app.use AccessDenied
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
