module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
 
    def connect
      auth_header = request.headers["api-authorization"] 
      self.current_user = if auth_header.present?
                            find_verified_user(auth_header)
                          else
                            find_verified_user(nil)
                          end
    end
 
    private
    
    def find_verified_user(token)
      if verified_user = User.find_by(id: cookies.encrypted[:user_id])
        verified_user
      elsif verified_user = User.find_by(jwt_token: token)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end