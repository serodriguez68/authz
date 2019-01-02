module ScopableByClearance
  extend Authz::Scopables::Base

  def self.available_keywords
    Clearance.all.pluck(:name) + ['All']
  end

  def self.resolve_keyword(keyword, requester)
    Clearance.where('LOWER(name) IS ?', keyword.downcase).pluck(:id)
  end

end