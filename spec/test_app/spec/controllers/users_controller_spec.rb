require 'rails_helper'

RSpec.describe UsersController, :type => :controller do

  describe '::login UserClass, :with => :method_name' do
    let(:account) { 'user-account' }
    let(:validator) { 'validator' }
    let(:user) { double(:user) }
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
        include TokenPostman
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
  end
end
