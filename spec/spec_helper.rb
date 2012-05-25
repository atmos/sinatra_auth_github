require "bundler/setup"

require File.join(File.dirname(__FILE__), '..', 'lib', 'sinatra', 'auth', 'github')

require 'pp'

require 'rack/test'

RSpec.configure do |config|
  config.include(Rack::Test::Methods)

  def app
    Example.app
  end
end
