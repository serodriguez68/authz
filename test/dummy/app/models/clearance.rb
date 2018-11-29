class Clearance < ApplicationRecord
  validates :level, presence: true,
                    numericality: { only_integer: true,
                                    greater_than_or_equal_to: 1,
                                    less_than_or_equal_to: 2 },
                    uniqueness: true
  validates :name, presence: true, uniqueness: true

  has_many :reports
end
