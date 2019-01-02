module Authz
  class ScopingRule < ApplicationRecord
    # Validations
    # ==========================================================================
    validates :scopable, presence: true
    validate :scopable_exists
    validates_uniqueness_of :scopable, scope: [:authz_role_id]
    validates :role, presence: true
    validates :keyword, presence: true
    validate :valid_keyword_for_scopable

    # Associations
    # ==========================================================================
    belongs_to :role, class_name: 'Authz::Role',
                      foreign_key: 'authz_role_id'

    private

    def scopable_exists
      unless scopable_exists?(scopable)
        errors.add(:scopable, "#{scopable} does not exists.")
      end
    end

    def valid_keyword_for_scopable
      if  scopable_exists?(scopable) && !scopable.constantize.valid_keyword?(keyword)
        errors.add(:keyword, "#{keyword} is not a valid keyword for #{scopable}")
      end
    end

    # Used to reduce the impact of the external dependency Scopable::Base
    def scopable_exists?(scopable)
      Scopables::Base.scopable_exists?(scopable)
    end

  end
end
