require "#{File.dirname(__FILE__)}/scopable_by_test_city"
class ScopedClass < ApplicationRecord
  belongs_to :test_city

  include ScopableByTestCity
end