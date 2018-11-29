class CreateOpinionatedPunditBusinessProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :opinionated_pundit_business_processes do |t|
      t.string :code
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
