class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    auth = request.env["omniauth.auth"]
    if auth.info&.email.present?
      waitlist = Waitlist.find_by(email: auth.info.email.downcase) || Waitlist.find_by(uid: auth.uid)

      if waitlist.present?
        existing_user = User.find_by(uid: auth[:uid]) || User.find_by(email: auth[:info][:email].downcase)
        if auth[:extra][:raw_info] && auth[:extra][:raw_info][:age_range] && auth[:extra][:raw_info][:age_range][:min] <= 18
          flash[:error] = %[ You must be 18 years or older. ].html_safe
        elsif waitlist&.ready_sign_in?
          fb_user = facebook_authenticate(auth, current_user)
          sign_in fb_user
          flash[:success] = "Signed in successfully."
        end
        if !waitlist.ready_sign_in?
          redirect_to waitlists_path(search: auth.info.email.downcase)
        elsif existing_user && (existing_user.current_sign_in_at >= (Time.now - 2.month).to_datetime)
          redirect_to activities_path
        else
          redirect_to welcome_onboardings_path
        end
      else
        add_user_to_waitlist(auth)
      end
    else
      redirect_to root_path, notice: "Please update the email in your facebook account"
    end
  end

  private

  def facebook_authenticate(auth, existing_user)
    if existing_user
      user = existing_user
    elsif User.find_by(uid: auth[:uid]) || User.find_by(email: auth[:info][:email].downcase)
      user = User.find_by(uid: auth[:uid]) || User.find_by(email: auth[:info][:email].downcase)
    else
      user = User.new(email: auth[:info][:email].downcase)
      user.current_step = "step1"
    end
    user.provider         = auth[:provider]
    user.uid              = auth[:uid]
    user.name             = "#{auth[:info][:first_name]} #{auth[:info][:last_name]}" if user.new_record?
    user.oauth_token      = auth[:credentials][:token]
    user.oauth_expires_at = Time.at(auth[:credentials][:expires_at])
    user.password         = SecureRandom.hex(3) if user.new_record?
    user.fb_image         = auth[:info][:image]
    # has_birthday = auth[:extra].present? && auth[:extra][:raw_info].present? && auth[:extra][:raw_info][:birthday].present?
    # user.date_of_birth = has_birthday ? auth[:extra][:raw_info][:birthday] : "1/1/1990"
    user.date_of_birth = "1/1/1990"
    user.username = user.name.gsub(" ", "_").downcase if user.new_record?
    if user.new_record? && user.username.present?
      unless user.save
        duplicate_name = user.errors.messages.keys.map { |msg| msg if msg == :username }.compact
        unless duplicate_name.blank?
          username_position = User.all.map { |_user| _user if _user.username.include?(user.username) }.compact.last.username.split("_").last.to_i + 1
          user.username.concat("_#{username_position}")
        end
      end
    end
    user.save!
    user
  end

  def add_user_to_waitlist(auth)
    user_name = "#{auth[:info][:first_name]} #{auth[:info][:last_name]}"
    waitlist = Waitlist.new(email: auth.info.email.downcase, name: user_name, uid: auth.uid)
    waitlist.email.downcase!
    respond_to do |format|
      if waitlist.save
        check_for_referral(waitlist)
        UserMailer.add_to_waitlist_email(waitlist.email).deliver_now
        waitlist.update_attributes(referral_link: "https://www.nomo-fomo.com/referral/#{waitlist.id}", position: Waitlist.last_position + 1)
        @waitlist = waitlist
        flash[:success] = "You have successfully been added to the waitlist!"
        format.html { render "waitlists/landing" }
        format.js { render @waitlist = waitlist.reload }
      elsif Waitlist.find_by(uid: waitlist.uid)
        @waitlist = Waitlist.find_by(uid: waitlist.uid)
        @waitlist.email = waitlist.email
        @waitlist.save
        flash[:error] = "You have already been added to the waitlist."
        format.html { render "waitlists/landing" }
        format.js { render @waitlist = @waitlist.reload }
      elsif Waitlist.find_by(email: waitlist.email) && Waitlist.find_by(email: waitlist.email).uid == nil
        @waitlist = Waitlist.find_by(email: waitlist.email)
        @waitlist.uid = waitlist.uid
        @waitlist.save
        flash[:error] = "You have already been added to the waitlist."
        format.html { render "waitlists/landing" }
        format.js { render @waitlist = @waitlist.reload }
      else
        @waitlist = Waitlist.find_by(email: waitlist.email)
        flash[:error] = "You have already been added to the waitlist."
        format.html { render "waitlists/landing" }
        format.js { render @waitlist = @waitlist.reload }
      end
    end
  end

  def check_for_referral(waitlist)
    if Waitlist.find_by(id: request.env["omniauth.params"]["referred_by"])
      referrer = Waitlist.find(request.env["omniauth.params"]["referred_by"])
      waitlist.update_attributes(referred_by: referrer.id)
      update_referrer(referrer)
    end
  end

  def update_referrer(referrer)
    referrer.update_referrals
    if referrer.activated? && !referrer.user_account
      UserMailer.youre_invited_email(referrer.email).deliver_later
    else
      UserMailer.referral_signed_up_email(referrer.email).deliver_later
    end
  end
end
