module Authz
  module ApplicationHelper
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
