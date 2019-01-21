Authz.configure do |config|
  # The method that Authz should use to force authentication into the Authorization Admin
  config.force_authentication_method = :authenticate_user!

  # The method used to access the current user
  config.current_user_method = :current_user
end