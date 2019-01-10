module AnnouncementsHelper

  def available_cities_name(ann)
    ann.cities.pluck(:name).join(', ')
  end
end
