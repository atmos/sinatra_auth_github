require "bundler/setup"

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra', 'auth', 'github')

require 'pp'
require 'rack/test'
require 'ruby-debug'
require 'app'

require 'warden-github/user'
require 'warden/test/helpers'

class User < Warden::Github::Oauth::User
  def self.make(attrs = {})
    default_attrs = {
       'login'   => "test_user",
       'name'    => "Test User",
       'email'   => "test@example.com",
       'company' => "GitHub",
       'gravatar_id' => 'https://a249.e.akamai.net/assets.github.com/images/gravatars/gravatar-140.png'
    }
    default_attrs.merge! attrs
    User.new(default_attrs)
  end
end


Spec::Runner.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Warden::Test::Helpers)

  def sign_in(user)
    login_as(user)
  end

  def app
    run Example::App
  end
end
