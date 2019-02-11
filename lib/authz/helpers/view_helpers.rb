module Authz
  module Helpers
    # View Helpers that are made available to the host application
    module ViewHelpers

      # Renders a link if user is authorized or does nothing otherwise
      # @param name [String] same as Rails link_to
      # @param options [Hash] same as Rails link_to
      # @param html_options [Hash] same as Rails link_to
      # @param using [Object] instance that will be used to determine authorization
      # @param skip_scoping [Boolean] option to skip scoping validation
      def authz_link_to(name, options = {}, html_options = {}, using: nil, skip_scoping: nil)
        url = url_for(options)
        method = html_options[:method] || html_options['method']
        authorized = authorized_path? url, method: method, using: using, skip_scoping: skip_scoping
        link_to(name, options, html_options) if authorized
      end

    end
  end
end

