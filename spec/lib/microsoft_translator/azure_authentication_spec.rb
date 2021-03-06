require "spec_helper"

describe MicrosoftTranslator::AzureAuthentication do

  after :all do
    Timecop.return
  end

  describe "#initialize" do
    before :each do
      stub_auth_request
    end
    it "should get auth token" do
      auth = MicrosoftTranslator::AzureAuthentication.new('id', 'secret')
      auth.token.should eq('stubbed_token')
    end
  end

  describe "#renew_token" do
    before :each do
      stub_auth_request
      @auth = MicrosoftTranslator::AzureAuthentication.new('id','secret')
    end

    it "should build send a request if to get a new token" do
      RestClient.should_receive(:post).with(MicrosoftTranslator::AzureAuthentication::AUTH_URL, auth_params('id', 'secret'))
      @auth.renew_token
    end

    it "should set the token" do
      @auth.renew_token
      @auth.token.should eq("stubbed_token")
    end

    it "should set token_expires_at" do
      Timecop.freeze
      @auth.renew_token
      @auth.token_expires_at.should eq(Time.now + 599)
    end
  end

  describe "#latest_token" do
    before :each do
      stub_auth_request('first_token')
      @auth = MicrosoftTranslator::AzureAuthentication.new('id','secret')
    end

    after :each do
      Timecop.return
    end

    it "should return the current_token if it has not expired yet" do
      @auth.should_not_receive(:renew_token)
      Timecop.travel(@auth.token_expires_at - 100)
      @auth.current_token.should eq('first_token')
    end

    it "should  get a new token if it has not expired yet" do
    pending "having trouble testing"
      @auth.should_receive(:renew_token)
      Timecop.travel(@auth.token_expires_at + 1000)
      stub_auth_request('new_token')
      token = @auth.current_token
      token.should eq('new_token')
    end
  end

end
