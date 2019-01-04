class Announcement < ApplicationRecord
  validates :body, presence: true
  has_many :announcement_cities
  has_many :cities, through: :announcement_cities

  include ScopableByCity
end
