class CreateAnnouncementCities < ActiveRecord::Migration[5.2]
  def change
    create_table :announcement_cities do |t|
      t.references :announcement, foreign_key: true
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
