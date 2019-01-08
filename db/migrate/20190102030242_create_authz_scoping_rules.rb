class CreateAuthzScopingRules < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_scoping_rules do |t|
      t.string :scopable, index: true
      t.references :authz_role, foreign_key: true, null: false,
                   index: true
      t.string :keyword, index: true

      t.timestamps
    end
  end
end
