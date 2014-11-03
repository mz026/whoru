require 'rails_helper'

describe AuthenticateFilter do
  describe '::before(controller)' do
    let(:params) { {} }
    let(:request) { double(:request, :headers => {}) }
    let(:controller) do
      double(:controller, :params => params,
                          :request => request)
    end
    let(:filter) { AuthenticateFilter.new(controller) }

    def expect_response_tobe(status)
      expect(controller).to receive(:render) do |options|
        expect(options[:status]).to eq(status)
      end
      filter.before
    end

    context "when `user_id` in params" do
      let!(:user) { double(:user, :has_access_token? => true, :id => 1234) }
      before :each do
        params[:user_id] = user.id
        allow(User).to receive(:find).and_return(user)
      end

      it "returns 404 if user not found" do
        allow(User).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        expect_response_tobe(404)
      end

      context "and if `#{AuthenticateFilter::TOKEN_KEY_IN_HEADERS}` not in headers" do
        it "returns 401" do
          expect_response_tobe(401)
        end
      end

      context "and if `#{AuthenticateFilter::TOKEN_KEY_IN_HEADERS} is in headers`" do
        let(:access_token) { 'the-token' }
        before :each do
          controller.request.headers[AuthenticateFilter::TOKEN_KEY_IN_HEADERS] = access_token
        end

        it "returns 401 if user does not have the token" do
          expect(user).to receive(:has_access_token?).with(access_token).and_return(false)
          expect_response_tobe(401)
        end
      end

    end
  end
end
