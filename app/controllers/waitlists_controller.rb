class WaitlistsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def landing
    if params[:email_confirmation]
      @email_confirmation = true
      flash[:success] = "You have successfully subscribed to our newsletter!"
    end
  end

  def new; end

  def create
    waitlist = Waitlist.new(email: params[:email], name: params[:name], uid: params[:id])
    waitlist.email.downcase!
    respond_to do |format|
      if waitlist.save
        check_for_referral(waitlist)
        UserMailer.add_to_waitlist_email(waitlist.email).deliver_now
        waitlist.update_attributes(referral_link: "https://www.nomo-fomo.com/referral/#{waitlist.id}", position: Waitlist.last_position + 1)
        @waitlist = waitlist
        flash[:success] = "You have successfully been added to the waitlist!"
        format.html { render :landing }
        format.js { render @waitlist = waitlist.reload }
      elsif Waitlist.find_by(uid: waitlist.uid)
        @waitlist = Waitlist.find_by(uid: waitlist.uid)
        @waitlist.email = waitlist.email
        @waitlist.save
        flash[:error] = "You have already been added to the waitlist."
        format.html { render :landing }
        format.js { render @waitlist = @waitlist.reload }
      elsif Waitlist.find_by(email: waitlist.email) && Waitlist.find_by(email: waitlist.email).uid == nil
        @waitlist = Waitlist.find_by(email: waitlist.email)
        @waitlist.uid = waitlist.uid
        @waitlist.save
        flash[:error] = "You have already been added to the waitlist."
        format.html { render :landing }
        format.js { render @waitlist = @waitlist.reload }
      else
        @waitlist = Waitlist.find_by(email: waitlist.email)
        flash[:error] = "You have already been added to the waitlist."
        format.html { render :landing }
        format.js { render @waitlist = @waitlist.reload }
      end
    end

    # waitlist = Waitlist.new(waitlist_params)
    # waitlist.email.downcase!
    # respond_to do |format|
    #   if waitlist.save
    #     check_for_referral(waitlist)
    #     UserMailer.add_to_waitlist_email(waitlist.email).deliver_now
    #     waitlist.update_attributes(referral_link: "https://www.nomo-fomo.com/referral/#{waitlist.id}", position: Waitlist.last_position + 1)
    #     format.html { redirect_to root_path, notice: "Successfully added to waitlist." }
    #     format.js { render @waitlist = waitlist.reload }
    #   else
    #     downcase_email = waitlist_params["email"].downcase!
    #     existing_waitlist = Waitlist.find_by(email: downcase_email)
    #     format.html { redirect_to root_path, notice: "You have already been added to the waitlist." }
    #     format.js { render @waitlist = existing_waitlist.reload }
    #   end
    # end
  end

  def check_waitlist_position
    if params[:search]
      @waitlist = Waitlist.search(params[:search]).first
    elsif Waitlist.find_by(uid: params[:id])
      waitlist = Waitlist.find_by(uid: params[:id])
      if waitlist.email != params[:email]
        waitlist.email = params[:email]
        waitlist.save
      end
      @waitlist = waitlist
    elsif Waitlist.find_by(email: params[:email]) && Waitlist.find_by(email: params[:email]).uid == nil
      waitlist = Waitlist.find_by(email: params[:email])
      waitlist.uid = params[:uid]
      waitlist.save
      @waitlist = waitlist
    elsif Waitlist.find_by(email: params[:email]) && !Waitlist.find_by(email: params[:email]).uid.nil?
      @waitlist = Waitlist.find_by(email: params[:email])
    end
    render :landing
  end

  def index
    if params[:search]
      waitlist = Waitlist.search(params[:search]).first
      respond_to do |format|
        format.html { @waitlist = waitlist }
        format.js { @waitlist = waitlist }
      end
    end
  end

  def check_position; end

  def create_appsecret_proof
    hmac = OpenSSL::HMAC.new(ENV["FACEBOOK_SECRET"], OpenSSL::Digest::SHA256.new)
    hmac << params[:access_token]
    render plain: hmac.hexdigest
  end

  private

  def check_for_referral(waitlist)
    if Waitlist.find_by(id: params["referred_by"])
      referrer = Waitlist.find(params["referred_by"])
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

  def waitlist_params
    params.require(:waitlist).permit(:email, :name, :referred_by)
  end
end
