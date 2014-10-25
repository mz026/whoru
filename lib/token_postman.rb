module TokenPostman
  class MethodNotImplementedException < Exception; end
  def self.included base

    base.class_eval do

      def _postman_login user
        if params[:cookie]
          ensure_method_exists(user, :generate_web_access_token)
          cookies['TOKEN_POSTMAN'] = user.generate_web_access_token
          render :json => user
        else
          ensure_method_exists(user, :generate_access_token)
          user_hash = user.as_json.merge(
                        :access_token => user.generate_access_token)
          render :json => user_hash
        end
      end
      private :_postman_login

      def ensure_method_exists(user, method_name)
        unless user.respond_to?(method_name)
          raise MethodNotImplementedException, 
                "#{user.class} should have `##{method_name}` method"
        end
      end
      private :ensure_method_exists

      def _postman_conflict
        render :json => { :reason => 'login failed' },
               :status => 409
      end
      private :_postman_conflict

      def _postman_bad_request e
        render :json => { :reason => e.message },
               :status => 400
      end
      private :_postman_bad_request

    end

    class << base
      # usage:
      # class UsersController
      #   login FacebookUser, :with => :facebook_login
      # end
      #
      # # route.rb
      # post '/users/fb_login' => 'users#facebook_login'
      def login user_class, options
        ensure_login_method_exists(user_class)

        instance_method_name = options[:with]

        define_method instance_method_name do
          begin
            user = user_class.login(params.require(:account), params.require(:validator))

            if user
              _postman_login(user)
            else
              _postman_conflict
            end
          rescue ActionController::ParameterMissing => e
            _postman_bad_request(e)
          end
        end
      end

      def ensure_login_method_exists user_class
        unless user_class.respond_to?(:login)
          raise MethodNotImplementedException, 
                "#{user_class} should have `::login` method"
        end
      end
      private :ensure_login_method_exists

    end

  end
end
