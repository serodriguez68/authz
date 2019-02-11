class CreateAuthzScopingRules < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_scoping_rules do |t|
      t.string :scopable, index: true
      t.references :authz_role, foreign_key: true, null: false,
                   index: true
      t.string :keyword, index: true

      t.timestamps
    end
    add_index(:authz_scoping_rules,
              [:authz_role_id, :scopable],
              unique: true,
              name: 'authz_srs_role_scopable')
  end
end
