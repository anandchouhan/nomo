class Waitlist < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :uid, uniqueness: true, allow_blank: true
  after_update :send_invite_email, if: :activated?
  after_create :send_invite_email, if: :activated?

  def self.search(search)
    where("email ILIKE ? ", "%#{search}%")
  end

  def send_invite_email
    mailer = UserMailer.youre_invited_email(email)
    mailer.deliver_now
    # TODO: remove the following once we are ready for users to be
    # activated from the waitlist, this is for us to make sure we aren't
    # accepting more than we can handle to start
    if Rails.env.production?
      activated_email = UserMailer.user_position_zero_email("contact@nomo-fomo.com", email)
      activated_email.deliver_now
    end
  end

  def update_referrals
    update_attributes(position: position - 5)
  end

  def activated?
    position && (position + 5 <= 5) && (position + 5).positive?
  end

  def ready_sign_in?
    position && position <= 0
  end

  def user_account
    User.find_by(email: email)
  end

  def self.last_position
    waitlists = where.not(position: nil)
    if waitlists.blank? 
      0
    else
      waitlists.max_by(&:position).position
    end
  end
end
