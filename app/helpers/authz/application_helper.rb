module Authz
  # Contains helpers that are available for use in any of the internal engine views.
  # @api private
  module ApplicationHelper

    # @param name [String] keyword
    # @return [String] css class for flash
    def flash_class(name)
      case name
      when 'success'
        'is-success'
      when 'error'
        'is-danger'
      when 'notice'
        'is-primary'
      when 'alert'
        'is-warning'
      end
    end

  end
end
