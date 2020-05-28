class PasswordMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"

  def reset_password_instructions(record, token, opts = {})
    opts[:from] = "Nomo FOMO <contact@nomo-fomo.com>"
    super
  end
end
