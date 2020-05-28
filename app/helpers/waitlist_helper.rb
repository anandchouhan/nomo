module WaitlistHelper
  def tweet_url(waitlist)
    waitlist_url = waitlist.referral_link
    tweet_url_query = {
      status: "I just signed up for Nomo FOMO, a social travel platform, join me! #{waitlist_url}"
    }.to_query
    base_tweet_url = "https://twitter.com/home"
    "#{base_tweet_url}?#{tweet_url_query}"
  end

  def facebook_url(waitlist)
    waitlist_url = waitlist.referral_link
    facebook_url_query = {
      app_id: 660780480720000,
      link: waitlist_url,
      redirect_uri: "http://facebook.com/"
    }.to_query
    base_facebook_url = "https://www.facebook.com/dialog/feed"
    "#{base_facebook_url}?#{facebook_url_query}"
  end
end
