# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def youre_invited_email_preview
    UserMailer.youre_invited_email(User.first.email)
  end

  def add_to_waitlist_email_preview
    UserMailer.add_to_waitlist_email(User.first.email)
  end

  def referral_signed_up_email_preview
    UserMailer.referral_signed_up_email(User.last.email)
  end

  def welcome_email_preview
    UserMailer.welcome_email(User.first)
  end

  def feedback_email_preview
    UserMailer.feedback_email(User.first.email)
  end

  def location_not_found_email_preview
    UserMailer.location_not_found_email(User.first.email)
  end

  def email_not_found_preview
    UserMailer.email_not_found(User.first.email)
  end

  def trip_created_email_preview
    UserMailer.trip_created_email(User.first.email)
  end

  def user_position_zero_email_preview
    UserMailer.user_position_zero_email("contact@nomo-fomo.com", User.first.email)
  end
end
