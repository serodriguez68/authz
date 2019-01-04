class AnnouncementCity < ApplicationRecord
  belongs_to :announcement
  belongs_to :city
end
