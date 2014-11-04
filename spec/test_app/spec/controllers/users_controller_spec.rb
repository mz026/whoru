require 'rails_helper'

RSpec.describe UsersController, :type => :controller do

  describe '::login UserClass, :with => :method_name' do
    let(:account) { 'user-account' }
    let(:validator) { 'validator' }
    let(:access_token) { 'the-token' }
    let(:user) { double(:user, :generate_access_token => access_token) }
    let(:user_class) { double(:user_class, :login => user) }

    let(:params) do
      {
        :account => account,
        :validator => validator
      }
    end
    before :each do
      user_klass = user_class
      UsersController.class_eval do
        include Whoru::Login
        login user_klass, :with => :login_method
      end
    end

    it "add method `method_name` in :with options to controller" do
      post :login_method, params
      expect(controller.respond_to?(:login_method)).to eq(true)
    end

    it "invokes `login` method with `account` and `validator`, which should return an user instance" do
      expect(user_class).to receive(:login).with(account, validator)
      post :login_method, params
    end

    it "returns 400 if no `account` in params" do
      params.delete :account
      post :login_method, params

      expect(response.status).to eq(400)
    end

    it "returns 400 if no `validator` in params" do
      params.delete :validator
      post :login_method, params

      expect(response.status).to eq(400)
    end

    it "returns 409 if UserClass::login returns nil" do
      allow(user_class).to receive(:login).and_return(nil)
      post :login_method, params

      expect(response.status).to eq(409)
    end

    it "attach `access_token`, generated by UserClass#generate_access_token in response" do
      post :login_method, params

      expect(JSON.parse(response.body)['access_token']).to eq(access_token)
    end

    it "makes sure `UserClass::login` exists" do
      user_klass = double(:user_class_without_login)
      expect {
        UsersController.login user_klass, :with => :login_method
      }.to raise_error(Whoru::MethodNotImplementedException)
    end

    it "makes sure `UserClass#generate_access_token` exists" do
      allow(user_class).to receive(:login).and_return(double(:user_without_generate_token))
      expect {
        post :login_method, params
      }.to raise_error(Whoru::MethodNotImplementedException)
    end

    context "if `cookie` exists in params" do
      let(:web_access_token) { 'the-web-access-token' }
      before :each do
        params[:cookie] = 1
        expect(user).not_to receive(:generate_access_token)
      end

      it "generate web_access_token and put it into `TOKEN_POSTMAN` in cookie" do
        allow(user).to receive(:generate_web_access_token)
                          .and_return(web_access_token)

        post :login_method, params

        expect(controller.send(:cookies)['TOKEN_POSTMAN']).to eq(web_access_token)
      end

      it "ensure UserClass#generate_web_access_token exists" do
        allow(user_class).to receive(:login).and_return(double(:user))
        expect {
          post :login_method, params
        }.to raise_error(Whoru::MethodNotImplementedException)
      end
    end

  end
end
