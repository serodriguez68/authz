class ScopedClass < ApplicationRecord
  belongs_to :test_city

  include ScopableByTestCity
end