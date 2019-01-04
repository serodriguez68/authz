class Report < ApplicationRecord
  belongs_to :user
  belongs_to :clearance
  belongs_to :city
  has_many :ratings

  validates :title, presence: true
  validates :body, presence: true

  include ScopableByCity
  include ScopableByClearance
end
