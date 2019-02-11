class CreateAuthzRoleGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_role_grants do |t|
      t.references :authz_role, foreign_key: true, null: false,
                   index: { name: 'authz_role_grants_role_index' }
      t.references :rolable, polymorphic: true, null: false,
                   index: { name: 'authz_role_grants_rolable_index' }

      t.timestamps
    end
    add_index(:authz_role_grants,
              [:rolable_type, :rolable_id, :authz_role_id],
              unique: true,
              name: 'authz_rgs_rolable_role')
  end
end
