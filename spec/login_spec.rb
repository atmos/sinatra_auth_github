require "spec_helper"

describe "Logged in users" do
  before do
    @user = User.make('login' => 'defunkt')
    sign_in @user
  end

  it "greets the user" do
    sign_in @user

    get "/"
    last_response.body.should eql("Hello there, defunkt!")
  end

  it "logs the user out" do
    get "/"

    get "/logout"
    last_response.status.should eql(302)
    last_response.headers['Location'].should eql("https://github.com")

    get "/"
    last_response.status.should eql(302)
    last_response.headers['Location'].should =~ %r{^https://github\.com/login/oauth/authorize}
  end
end
