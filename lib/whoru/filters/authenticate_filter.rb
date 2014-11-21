module Whoru
  class AuthenticateFilter
    TOKEN_KEY_IN_HEADERS = 'x-access-token'

    @default_options = @options = {
      :user_id => :user_id,
      :header_token => 'x-access-token'
    }

    class << self
      def config options
        @options = @options.merge(options)
      end

      def before(controller)
        return unless controller.params[@options[:user_id]]

        token_string = access_token(controller)
        user = User.where(:id => controller.params[@options[:user_id]]).first
        return_404(controller) and return unless user
        return_401(controller) and return unless token_string
        return_401(controller) and return unless user.has_access_token?(token_string)
      end


      def access_token controller
        controller.request.headers[@options[:header_token]] || controller.request.cookies[Whoru::Login::COOKIE_KEY]
      end
      private :access_token

      def return_401 controller
        controller.render :json => { :reason => 'user is not authenticated' },
                          :status => 401
        true
      end
      private :return_401

      def return_404 controller
        controller.render :json => { :reason => 'user not found' },
                          :status => 404
        
        true
      end
      private :return_404

    end
  end
end
