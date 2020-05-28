class Api::PasswordsController < Api::BaseController
  def create
    user = User.find_by_email(params[:password][:email])
    if user.present?
      auth_token = jwt_token(user).concat("api_url") 
      user.update_attribute(:jwt_token, auth_token)
    end
    resource = User.send_reset_password_instructions(params[:password])
    if resource.present? && resource.valid? 
      render json: { success: true, message: "Reset Password Link Send On Your Email Address" }
    else
      render json: {
        success: false,
        message: "Email Not Found"
      }
    end
  end

  def update
    user_params = { reset_password_token: params[:reset_password_token], password: params[:password], password_confirmation: params[:password_confirmation] }
    user = User.reset_password_by_token(user_params)
    if user.errors.empty?
      user.unlock_access! if unlockable?(user)
      if Devise.sign_in_after_reset_password
        flash_message = user.active_for_authentication? ? :updated : :updated_not_active
        if flash_message == :updated
          render json: {
            success: true,
            message: "Your password has been changed successfully"
          } 
        end 
      end
    else
      render json: {
        success: false,
        message: "#{user.errors.messages.first.first} #{user.errors.messages.first.last[0]}"
      } 
    end
  end

  protected

  # def after_resetting_password_path_for(resource)
  #   Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(params[:user])
  # end

  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   render "api/users/sign_in" if is_navigational_format?
  # end

  def unlockable?(resource) 
    resource.respond_to?(:unlock_access!) && resource.respond_to?(:unlock_strategy_enabled?) && resource.unlock_strategy_enabled?(:email)
  end
end