require "opinionated_pundit/engine"
require 'opinionated_pundit/authorizable'

module OpinionatedPundit

  class MultileRolablesNotPermitted < StandardError; end

  mattr_reader :rolables
  @@rolables = [] # Contains the classes of all Rolables
  def self.register_rolable(rolable)
    if @@rolables.size > 0
      #  TODO: When support for multiple rolables is implemented, lift this exception
      raise MultileRolablesNotPermitted,
            "Only the Authorization of one model (like a User) is currently supported"
    end
    @@rolables << rolable
  end

end

