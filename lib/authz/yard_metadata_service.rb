module Authz
  class YardMetadataService

    def initialize
      @descriptions = {}
      @controller_action_description_tag = :authz_description

      # Register Authz tag so that YARD can parse it
      YARD::Tags::Library.define_tag(
        "Authz controller action description",
        controller_action_description_tag
      )
    end

    def get_controller_action_description(controller_name, action_name)
      controller_action_symbol = controller_action_symbol(controller_name, action_name)
      descriptions.fetch(controller_action_symbol) do |as|
        YARD.parse(controller_filename(controller_name))

        description = YARD::Registry.at(as)&.tag(controller_action_description_tag)&.text
        descriptions[as] = description
      end
    end

    private

    attr_reader :descriptions, :controller_action_description_tag

    def controller_filename(controller_name)
      Rails.root.join(
        'app', 'controllers', "#{controller_name}_controller.rb"
      ).to_s
    end

    def controller_action_symbol(controller_name, action_name)
      controller_name
        .split('/')
        .map(&:camelize)
        .join('::')
        .concat("Controller\##{action_name}")
    end

  end
end
