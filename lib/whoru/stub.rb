module Whoru
  module Stub
    def stub_authenticate
      allow(Whoru::AuthenticateFilter).to receive(:before)
    end
  end
end
