class Report < ApplicationRecord
  belongs_to :user
  belongs_to :clearance
  belongs_to :city

  validates :title, presence: true
  validates :body, presence: true
end
