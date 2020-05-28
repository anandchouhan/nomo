module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-error"
    when :alert
      "alert-block"
    when :notice
      "alert-info"
    else
      flash_type.to_s
    end
  end

  def user_name_from_id(user_id)
    User.find(user_id).name
  end

  def user_circle_image_tag(user, _height = 70, _width = 70)
    user_photo(user, class: "rounded-circle", height: 100, width: 100)
  end

  def user_photo_from_id(user_id, _options = {})
    user_photo User.find user_id if user_id.present?
  end

  def user_photo_url_from_id(user_id, _options = {})
    if user_id.present?
      user = User.find(user_id)
      user.profile_image
    end
  end

  def user_photo(user, options = {})
    image_tag user_photo_url(user), options
  end

  def user_photo_url(user)
    if user.fb_image.present?
      # image_url = if user.fb_image.include? "?"
      #               "#{user.fb_image}&"
      #             else
      #               "#{user.fb_image}?"
      #             end
      image_url = user.fb_image
      image_url + "type=large&type=square"
      new_url = URI.parse(image_url)
      new_url.scheme = "https"
      new_url.to_s
    else 
      "user.png"
    end
  end

  def feedback_url
    "http://support.nomo-fomo.com/"
  end

  def sso_token(user)
    # =begin
    #     Ruby UserEcho Single Sign-On code example v2.0
    #     Date: 2016-05-03

    #     Using:
    #     Add your sso_key. Fill out data_json. Generate sso_token.
    #     Then use in your URL:
    #         http://[your_alias].userecho.com/?sso_token=sso_token
    #     OR in the JS widget:
    #     var _ues = {
    #         ... ,
    #     params:{sso_token:sso_token}
    #     };
    # =end

    # your sso_key
    sso_key = "6XQPzXSoXEu1Vh3TuaFyDOhxCVwxoK1H"
    # prepare json data
    data_json = {
      expires: Time.now.to_i + 3600,
      guid: user.id,
      display_name: (user.name || user.username || user.email),
      email: user.email,
      locale: "en",
      avatar_url: user.picture
    }
    # dump json to string
    raw = JSON.dump(data_json)
    # create cipher for encryption
    cipher = OpenSSL::Cipher.new("AES-256-CBC")
    cipher.encrypt
    cipher.key = sso_key
    # generate random iv
    iv = cipher.random_iv
    # generate token
    sso_token = cipher.update(raw) + cipher.final
    # prepend iv and apply base64encode
    sso_token = Base64.strict_encode64(iv + sso_token)
    # escape characters for url
    CGI.escape(sso_token)
  end

  def current_trip
    @current_trip ||= Trip.find(session[:trip_id]) if !session[:trip_id].blank?
  end

  def active_class(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
