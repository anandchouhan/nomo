class AddMentionsCircleToMentionables < ActiveRecord::Migration
  def change
    Poll.all.each do |poll|
      poll.set_mentions_circle if poll.mentions_circle.nil?
      poll.set_privacy_circle if poll.audience.nil?
    end
    Post.all.each do |post|
      post.set_mentions_circle if post.mentions_circle.nil?
      post.set_privacy_circle if post.audience.nil?
    end
    Comment.all.each do |comment|
      comment.set_mentions_circle if comment.mentions_circle.nil?
    end
  end
end
