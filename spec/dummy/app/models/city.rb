class City < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :reports
  has_many :announcements

  include ScopableByCity
end
