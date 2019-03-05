module Authz
  class YardControllerMetadataService
    def initialize
      YARD::Tags::Library.define_tag(
        "Authz controller action description",
        :authz_description
      )
    end

    def get_controller_action_description(controller_name, action_name)
      YARD.parse(controller_filename(controller_name))

      YARD::Registry.at(
        action_symbol(controller_name, action_name)
      )&.tag(:authz_description)&.text
    end

    private

    def controller_filename(controller_name)
      Rails.root.join(
        'app', 'controllers', "#{controller_name}_controller.rb"
      ).to_s
    end

    def action_symbol(controller_name, action_name)
      controller_name
        .split('/')
        .map(&:camelize)
        .join('::')
        .concat("Controller\##{action_name}")
    end
  end
end
