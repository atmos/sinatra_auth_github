require 'sinatra/base'
require 'sinatra/url_for'
require 'warden-github'

module Sinatra
  module Auth
    module Github
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

        def github_oauth_proxy
          @github_oauth_proxy ||=
            Warden::Github::Oauth::Proxy.new(_github_client, _github_secret, _oauth_callback_url)
        end

        def _github_client
          options.github_options[:client_id]
        end

        def _github_secret
          options.github_options[:secret]
        end

        def _callback_url
          options.github_options[:callback_url] || '/auth/github/callback'
        end

        def _oauth_callback_url
          url_for _callback_url, :full
        end
      end

      def self.registered(app)
        app.use Warden::Manager do |manager|
          manager.default_strategies :github

          manager.failure_app           = app.github_options[:failure_app] || BadAuthentication

          manager[:github_secret]       = app.github_options[:secret]
          manager[:github_client_id]    = app.github_options[:client_id]
          manager[:github_callback_url] = app.github_options[:callback_url] || '/auth/github/callback'
        end

        app.helpers Helpers
        app.helpers Sinatra::UrlForHelper

        app.get '/auth/github/callback' do
          authenticate!
          redirect url_for '/'
        end
      end
    end
  end
end
