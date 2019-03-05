module Authz
  class YardControllerMetadataService


    def initialize
      @descriptions = {}

      # Register Authz tag so that YARD can parse it
      YARD::Tags::Library.define_tag(
        "Authz controller action description",
        :authz_description
      )
    end

    def get_controller_action_description(controller_name, action_name)
      descriptions.fetch(action_symbol(controller_name, action_name)) do |as|
        YARD.parse(controller_filename(controller_name))

        description = YARD::Registry.at(as)&.tag(:authz_description)&.text

        descriptions[as] = description
      end
    end

    private

    attr_reader :descriptions

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
