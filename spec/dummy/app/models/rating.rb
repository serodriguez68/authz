class Rating < ApplicationRecord
  validates :score, presence: true,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 5 }

  belongs_to :report
  delegate :title, to: :report, prefix: true

  belongs_to :user
  delegate :email, to: :user, prefix: true

  has_one :city, through: :report
  delegate :name, to: :city, prefix: true, allow_nil: true

  has_one :clearance, through: :report
  delegate :name, to: :clearance, prefix: true

  include ScopableByCity
  include ScopableByClearance
end