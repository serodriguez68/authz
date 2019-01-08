require "#{File.dirname(__FILE__)}/scopable_by_test_city"
class AmbiguousScopedClass < ApplicationRecord
  has_many :test_cities
  belongs_to :test_city

  include ScopableByTestCity
end