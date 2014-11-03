class AuthenticateFilter
  TOKEN_KEY_IN_HEADERS = 'x-access-token'

  attr_accessor :controller
  def initialize controller
    @controller = controller
  end

  def before 
    user = User.find(controller.params[:user_id])
    return_401 and return unless access_token
    return_401 and return unless user.has_access_token?(access_token)
  rescue ActiveRecord::RecordNotFound => e
    controller.render :json => { :reason => e.message },
                      :status => 404
  end


  def access_token
    controller.request.headers[TOKEN_KEY_IN_HEADERS]
  end
  private :access_token

  def return_401
    controller.render :json => { :reason => 'user is not authenticated' },
                      :status => 401
    true
  end
  private :return_401
end
