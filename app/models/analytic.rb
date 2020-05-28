class Analytic < ApplicationRecord
  belongs_to :user, optional: true

  def self.create_analytic(user_id, device_type, device_token, analytic_type, version, app_version, start_time, end_time)
    analytic = Analytic.new(user_id: user_id, device_type: device_type, device_token: device_token, analytic_type: analytic_type, version: version, app_version: app_version, start_time: start_time, end_time: end_time)
    analytic if analytic.save
  end
end
