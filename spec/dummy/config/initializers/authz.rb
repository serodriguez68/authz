# This allows Authz to eager_load the scopables when your application boots
# if you have eager_loading disabled.
# If you change the location of the scopables, adjust the path.
# Not loading the scopables can lead to inconsistent behaviour.
unless Rails.configuration.eager_load
  Dir[Rails.root.join('app/scopables/**/*.rb')].each{ |f| require f }
end

Authz.configure do |config|
  # The method that Authz should use to force authentication into the Authorization Admin
  config.force_authentication_method = :authenticate_user!

  # The method used to access the current user
  config.current_user_method = :current_user
end