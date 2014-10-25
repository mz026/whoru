module TokenPostman
  def self.included base

    # usage:
    # class UsersController
    #   login FacebookUser, :with => :facebook_login
    # end
    #
    # # route.rb
    # post '/users/fb_login' => 'users#facebook_login'
    def base.login user_class, options
      instance_method_name = options[:with]
      define_method instance_method_name do
        begin
          user = user_class.login(params.require(:account), params.require(:validator))

          if user
            render :json => user.as_json.merge(:access_token => user.generate_access_token)
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

  end
end
