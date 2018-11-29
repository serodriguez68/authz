class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :user, foreign_key: true
      t.references :clearance, foreign_key: true
      t.references :city, foreign_key: true
      t.string :title
      t.string :body

      t.timestamps
    end
  end
end
