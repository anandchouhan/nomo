class Api::SessionsController < Api::BaseController
  # skip_before_action :authenticate_user_from_token!
  before_action :ensure_params_exist, except: [:destroy]
  before_action :user_params, except: [:destroy]

  def create
    @user = User.find_for_database_authentication(email: user_params[:email])
    return invalid_login_attempt unless @user
    return invalid_login_attempt unless @user.valid_password?(user_params[:password])
    @google_place_id = @user.location.try(:google_place_id)
    Analytic.create_analytic(@user.id, params[:device_type], nil, "email_login", params[:vs], params[:app_version], nil, nil)
    @message = "User Sign in Successfully"
    update_api_token
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
 
  def ensure_params_exist
    if user_params[:email].blank? || user_params[:password].blank?
      render json: {
        success: false,
        message: "Blank Email or Password"
      }
    end
  end
 
  def invalid_login_attempt
    render json: {
      success: false,
      message: "Invalid Email or Password"
    }
  end
end