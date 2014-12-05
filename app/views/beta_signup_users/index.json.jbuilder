json.array!(@beta_signup_users) do |beta_signup_user|
  json.extract! beta_signup_user, :id, :email, :city, :phone_model, :phone_type
  json.url beta_signup_user_url(beta_signup_user, format: :json)
end
