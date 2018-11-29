class CreateOpinionatedPunditRoleHasBusinessProcesses < ActiveRecord::Migration[5.2]
  def change
    create_table :opinionated_pundit_role_has_business_processes do |t|
      t.references :opinionated_pundit_business_process, foreign_key: true,
                   index: { name: 'opinionated_pundit_rhbp_business_process_index' }
      t.references :opinionated_pundit_role, foreign_key: true,
                   index: { name: 'opinionated_pundit_rhbp_role_index' }

      t.timestamps
    end
  end
end
