require "bundler/setup"

$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'pp'
require 'rack/test'
require 'ruby-debug'

require 'sinatra/auth/github'
require 'sinatra/auth/github/test/test_helper'

require 'app'

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Sinatra::Auth::Github::Test::Helper)

  def app
    Example::App
  end
end
