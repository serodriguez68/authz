module Authz
  class ScopingRule < self::ApplicationRecord
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
                      foreign_key: 'authz_role_id',
                      inverse_of: :scoping_rules,
                      touch: true

    has_many :role_grants, through: :role

    scope :for_scopables, ->(scopables) { where(scopable: scopables.map(&:to_s)) }

    def to_s
      "#{scopable}: #{keyword}##{id}"
    end

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
