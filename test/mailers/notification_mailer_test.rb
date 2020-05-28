require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  def user
    @user ||= users(:user_one)
  end

  def test_notification_emails
    # Create the email and store it for further assertions
    email = NotificationMailer.new_notification_email(user, "Test notification")

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ["contact@nomo-fomo.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "You Have a New Notification", email.subject
  end
end
