class UserMailer < ApplicationMailer
  default from: "Nomo FOMO Team <contact@nomo-fomo.com>"

  add_template_helper ApplicationHelper

  def youre_invited_email(email)
    # headers['X-MJ-CustomID'] = 'custom value'
    # headers['X-MJ-EventPayload'] = 'custom payload'
    mail(
      to: email,
      subject: "You’ve Been Invited to Join Nomo FOMO!"
    )
  end

  def add_to_waitlist_email(email)
    @waitlist = Waitlist.find_by(email: email)
    mail(
      to: email,
      subject: "You have been added to the waitlist to join Nomo FOMO"
    )
  end

  def referral_signed_up_email(email)
    @waitlist = Waitlist.find_by(email: email)
    mail(
      to: email,
      subject: "One of your friends has joined the waitlist"
    )
  end

  def welcome_email(user_params)
    # headers['X-MJ-CustomID'] = 'custom value'
    # headers['X-MJ-EventPayload'] = 'custom payload'
    # @user = User.find_by email: user_params[:email]
    @user = user_params
    @waitlist_info = Waitlist.find_by(email: @user.email)
    mail(
      to: @user.email,
      subject: "Welcome to Nomo FOMO!"
    )
  end

  def feedback_email(email)
    # headers['X-MJ-CustomID'] = 'custom value'
    # headers['X-MJ-EventPayload'] = 'custom payload'
    @user = User.find_by email: email
    mail(
      to: email,
      subject: "How are we doing?"
    )
  end

  def email_not_found(email)
    mail(
      to: email,
      subject: "Trip was not imported"
    )
  end

  def location_not_found_email(email)
    mail(
      to: email,
      subject: "An error occured when importing your trip"
    )
  end

  def trip_created_email(email)
    @user = User.find_by email: email
    mail(
      to: email,
      subject: "Your trip was imported successfully!"
    )
  end

  def user_position_zero_email(email, waitlist_email)
    @waitlist = waitlist_email
    mail(
      to: email,
      subject: "A user on the waitlist has moved up to position 0"
    )
  end

  def periodic_notification_email(email_address, user_name, headings)
    attachments.inline["logo.png"] = File.read("app/assets/images/nomofomo-logo-black.png")

    @user_name = user_name
    @headings = headings

    mail(
      to: email_address,
      subject: "Nomo FOMO Weekly Notifications"
    )
  end
end
