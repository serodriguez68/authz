module ScopableByCity
  extend Authz::Scopables::Base

  def self.available_keywords
    City.all.pluck(:name) + ['All']
  end

  def self.resolve_keyword(keyword, requester)
    City.where('LOWER(name) IS ?', keyword.downcase).pluck(:id) + [nil]
  end

end