class CreateAuthzRoleGrants < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_role_grants do |t|
      t.references :authz_role, foreign_key: true, null: false,
                   index: { name: 'authz_role_grants_role_index' }
      t.references :rolable, polymorphic: true, null: false,
                   index: { name: 'authz_role_grants_rolable_index' }

      t.timestamps
    end
  end
end
