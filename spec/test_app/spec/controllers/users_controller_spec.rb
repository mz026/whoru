require 'rails_helper'

RSpec.describe UsersController, :type => :controller do

  describe '::login UserClass, :with => :method_name' do
    before :all do
      @user_class = double(:user_class)
      UsersController.class_eval do
        include TokenPostman
        login @user_class, :with => :login_method
      end
    end

    it "add method `method_name` in :with options to controller" do
      post :login_method
      expect(controller.respond_to?(:login_method)).to eq(true)
    end
  end
end
