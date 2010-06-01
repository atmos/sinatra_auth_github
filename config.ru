ENV['RACK_ENV'] ||= 'development'
begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require(:runtime)

$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'sinatra_auth_github'))
require File.expand_path(File.join(File.dirname(__FILE__), 'spec', 'app'))

use Rack::Static, :urls => ["/css", "/img", "/js"], :root => "public"

run Example::App

# vim:ft=ruby
