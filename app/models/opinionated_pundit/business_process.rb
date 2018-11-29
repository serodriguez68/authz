module OpinionatedPundit
  class BusinessProcess < ApplicationRecord
    # Validations
    # ==========================================================================
    validates :code, presence: true, uniqueness: true,
                     format: { with: /\A[a-z]+(_[a-z]+)*\z/,
                               message: 'only snake_case allowed' }
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true

    # Callbacks
    # ==========================================================================
    before_validation :extract_code_from_name, on: [:create]


    private

    def extract_code_from_name
      self.code = name.parameterize(separator: '_') if name.present?
    end

  end
end
