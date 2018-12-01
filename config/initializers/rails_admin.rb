RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  ## == Opinionated-Pundit Configuration ==
  config.main_app_name = ["Authorization", "Admin"]
  config.included_models = ['OpinionatedPundit::ControllerAction',
                            'OpinionatedPundit::BusinessProcess',
                            'OpinionatedPundit::Role']

  config.model 'OpinionatedPundit::ControllerAction' do
    object_label_method { :to_s }
    list { exclude_fields :created_at, :updated_at }
  end

  config.model 'OpinionatedPundit::BusinessProcess' do
    list { exclude_fields :created_at, :updated_at }
  end

  config.model 'OpinionatedPundit::Role' do
    list { exclude_fields :created_at, :updated_at }
  end

end
