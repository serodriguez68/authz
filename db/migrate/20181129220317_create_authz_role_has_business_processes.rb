class CreateAuthzRoleHasBusinessProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_role_has_business_processes do |t|
      t.references :authz_business_process, foreign_key: true,
                   index: { name: 'authz_rhbp_business_process_index' }
      t.references :authz_role, foreign_key: true,
                   index: { name: 'authz_rhbp_role_index' }

      t.timestamps
    end
  end
end
