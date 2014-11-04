require 'whoru/filters/authenticate_filter'

module Whoru
  module Authenticate
    def self.included base
      def base.authenticate options
        AuthenticateFilter.config options
        auth_method = options[:with]

        define_method(auth_method) do
          AuthenticateFilter.before(self)
        end
        before_filter auth_method
      end
    end
  end
end
