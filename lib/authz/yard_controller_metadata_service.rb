module Authz
  class YardControllerMetadataService
    def initialize
      YARD::Tags::Library.define_tag(
        "Authz controller action description",
        :authz_description
      )
    end

    def get_controller_action_description(controller_name, action_name)
      controller_filename = "#{controller_name}_controller.rb"
      controller_path = Rails.root.join(
        "app",
        "controllers",
        controller_filename
      ).to_s
      action_path = controller_name
        .split("/")
        .map(&:camelize)
        .join("::")
        .concat("Controller\##{action_name}")

      YARD::parse(controller_path)

      method_code_object = YARD::Registry.at(action_path)
      method_code_object&.tag(:authz_description)&.text
    end
  end
end
