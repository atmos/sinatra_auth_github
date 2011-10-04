require 'sinatra/base'
require 'warden-github'
require 'rest_client'

module Sinatra
  module Auth
    module Github
      VERSION = "0.1.2"

      # Simple way to serve an image early in the stack and not get blocked by
      # application level before filters
      class AccessDenied < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions

        get '/_images/securocat.png' do
          send_file(File.join(File.dirname(__FILE__), "views", "securocat.png"))
        end
      end

      # The default failure application, this is overridable from the extension config
      class BadAuthentication < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions

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

        # The authenticated user object
        #
        # Supports a variety of methods, name, full_name, email, etc
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
        #   github_request("/user")
        #   # => { 'login' => 'atmos', ... }
        def github_request(path)
          JSON.parse(github_raw_request(path))
        end

        # See if the user is a public member of the named organization
        #
        # name - the organization name
        #
        # Returns: true if the user is public access, false otherwise
        def github_public_organization_access?(name)
          orgs = github_request("orgs/#{name}/public_members")
          orgs.map { |org| org["login"] }.include?(github_user.login)
        rescue RestClient::Forbidden, RestClient::Unauthorized, RestClient::ResourceNotFound => e
          false
        end

        # See if the user is a member of the named organization
        #
        # name - the organization name
        #
        # Returns: true if the user has access, false otherwise
        def github_organization_access?(name)
          orgs = github_request("orgs/#{name}/members")
          orgs.map { |org| org["login"] }.include?(github_user.login)
        rescue RestClient::Forbidden, RestClient::Unauthorized, RestClient::ResourceNotFound => e
          false
        end

        # See if the user is a member of the team id
        #
        # team_id - the team's id
        #
        # Returns: true if the user has access, false otherwise
        def github_team_access?(team_id)
          members = github_request("teams/#{team_id}/members")
          members.map { |user| user["login"] }.include?(github_user.login)
        rescue RestClient::Forbidden, RestClient::Unauthorized, RestClient::ResourceNotFound => e
          false
        end

        # Enforce user membership to the named organization
        #
        # name - the organization to test membership against
        #
        # Returns an execution halt if the user is not a member of the named org
        def github_public_organization_authenticate!(name)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_public_organization_access?(name)
        end

        # Enforce user membership to the named organization if membership is publicized
        #
        # name - the organization to test membership against
        #
        # Returns an execution halt if the user is not a member of the named org
        def github_organization_authenticate!(name)
          authenticate!
          halt([401, "Unauthorized User"]) unless github_organization_access?(name)
        end

        # Enforce user membership to the team id
        #
        # team_id - the team_id to test membership against
        #
        # Returns an execution halt if the user is not a member of the team
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

          manager[:github_secret]       = app.github_options[:secret]       || ENV['GITHUB_CLIENT_SECRET']
          manager[:github_scopes]       = app.github_options[:scopes]       || 'email,offline_access'
          manager[:github_client_id]    = app.github_options[:client_id]    || ENV['GITHUB_CLIENT_ID']
          manager[:github_callback_url] = app.github_options[:callback_url] || '/auth/github/callback'
        end

        app.helpers Helpers

        app.get '/auth/github/callback' do
          authenticate!
          return_to = session.delete('return_to') || _relative_url_for('/')
          redirect return_to
        end
      end
    end
  end
end
