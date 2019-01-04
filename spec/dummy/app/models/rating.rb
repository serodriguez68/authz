class Rating < ApplicationRecord
  belongs_to :report
  belongs_to :user
  has_one :city, through: :report
  has_one :clearance, through: :report

  include ScopableByCity
  include ScopableByClearance
end