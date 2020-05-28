# Preview all emails at http://localhost:3000/rails/mailers/password_mailer
class PasswordMailerPreview < ActionMailer::Preview
  def reset_password_instructions_preview
    PasswordMailer.reset_password_instructions(User.first, User.first.password_reset_token, {})
  end
end
