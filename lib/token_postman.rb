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
        render :text => 'hi'
      end
    end

  end
end
