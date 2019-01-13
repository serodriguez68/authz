module Authz
  module Helpers
    module ViewHelpers

      def authz_link_to(name, options = {}, html_options = {}, using: nil, skip_scoping: nil)
        url = url_for(options)
        method = html_options[:method] || html_options['method']
        authorized = authorized_path? url, method: method, using: using, skip_scoping: skip_scoping
        link_to(name, options, html_options) if authorized
      end

    end
  end
end

