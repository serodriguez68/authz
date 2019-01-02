module ScopableByTestCity
  extend Authz::Scopables::Base

  def self.available_keywords
    ['valid_keyword']
  end
end