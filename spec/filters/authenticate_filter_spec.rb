require 'rails_helper'

describe Whoru::AuthenticateFilter do

  describe '::before(controller)' do
    class User; end
    def User.where(options); end

    let(:params) { {} }
    let(:request) { double(:request, :headers => {}, :cookies => {}) }
    let(:controller) do
      double(:controller, :params => params,
                          :request => request)
    end
    subject { Whoru::AuthenticateFilter }

    def expect_response_tobe(status)
      expect(controller).to receive(:render) do |options|
        expect(options[:status]).to eq(status)
      end
      subject.before(controller)
    end

    context "when `user_id` in params" do
      let!(:user) { double(:user, :has_access_token? => true, :id => 1234) }
      let(:token_header_key) { 'x-custom-token-key' }
      before :each do
        params[:user_id] = user.id
        allow(User).to receive(:where).with(:id => user.id).and_return([ user ])
      end

      before :each do
        subject.config(:user_class => User,
                       :header_token => token_header_key)
      end

      it "returns 404 if user not found" do
        allow(User).to receive(:where).and_return([])
        expect_response_tobe(404)
      end

      context "and if key `token_header` not in headers" do
        context "and if cookies['WHORU'] exists" do
          let(:access_token) { 'the-token' }
          before :each do
            controller.request.cookies['WHORU'] = access_token
          end
          it "passes if matched" do
            expect(user).to receive(:has_access_token?).with(access_token).and_return(true)
            subject.before(controller)
          end

          it "returns 401 if not matched" do
            expect(user).to receive(:has_access_token?).with(access_token).and_return(false)
            expect_response_tobe(401)
          end
        end
        it "returns 401" do
          expect_response_tobe(401)
        end
      end

      context "and if key `token_header` is in headers" do
        let(:access_token) { 'the-token' }
        before :each do
          controller.request.headers[token_header_key] = access_token
        end

        it "returns 401 if user does not have the token" do
          expect(user).to receive(:has_access_token?).with(access_token).and_return(false)
          expect_response_tobe(401)
        end
      end
    end

    context "when `user_id` not in params" do
      it "does nothing and passes" do
        subject.before(controller)
      end
    end

  end
end
