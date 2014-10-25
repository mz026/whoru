module TokenPostman
  class MethodNotImplementedException < Exception; end
  def self.included base

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
              unless user.respond_to?(:generate_access_token)
                raise MethodNotImplementedException, 
                      "#{user_class} should have `#generate_access_token` method"
              end
              user_hash = user.as_json.merge(
                            :access_token => user.generate_access_token)
              render :json => user_hash
            else
              render :json => { :reason => 'login failed' },
                     :status => 409
            end

          rescue ActionController::ParameterMissing => e
            render :json => { :reason => e.message },
                   :status => 400
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
