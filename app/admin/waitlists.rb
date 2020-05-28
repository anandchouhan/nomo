ActiveAdmin.register Waitlist do
  permit_params :email, :referred_by, :referral_link, :position, :name
end
