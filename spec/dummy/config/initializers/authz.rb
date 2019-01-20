Authz.configure do |config|
  config.force_authentication_method = :authenticate_user!
  config.current_user_method = :current_user
end