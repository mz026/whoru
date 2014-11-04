require 'rails_helper'

describe Whoru::Authenticate do
  let(:controller_class) { Class.new }
  let(:user_class) { Class.new }

  before :each do
    controller_class.class_eval { include Whoru::Authenticate }
  end

  context 'when included' do
    it "adds an `authenticate` method to base controller" do
      expect(controller_class.respond_to?(:authenticate)).to eq(true)
    end
  end

  describe '::authenticate(options)' do
    let(:header_token) { 'token-key-in-header' }
    let(:user_id) { 'user-id-key-in-params' }
    let(:created_method_name) { :created_method_name }
    let(:options) do
      {
        :user_class => user_class,
        :header_token => header_token,
        :user_id => user_id,
        :with => created_method_name
      }
    end

    before :each do
      def controller_class.before_filter(method, options = {}); end
    end

    after :each do
      Whoru::AuthenticateFilter.instance_eval { @options = @default_options }
    end

    it "config Whoru::AuthenticateFilter with options" do
      expect(Whoru::AuthenticateFilter).to receive(:config).with(options)
      controller_class.authenticate options
    end

    it "defines `with` method on controller" do
      controller_class.authenticate options
      expect(controller_class.method_defined?(created_method_name)).to eq(true)
    end

    it "sets before_filter to `with` method" do
      expect(controller_class).to receive(:before_filter).with(created_method_name)
      controller_class.authenticate options
    end

    it "delegate to AuthenticateFilter.before in created `with` method" do
      controller_class.authenticate options

      controller = controller_class.new

      expect(Whoru::AuthenticateFilter).to receive(:before).with(controller)
      controller.send(created_method_name)
    end

  end
end
