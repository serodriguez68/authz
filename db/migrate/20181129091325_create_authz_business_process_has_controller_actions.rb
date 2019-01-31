class CreateAuthzBusinessProcessHasControllerActions < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_business_process_has_controller_actions do |t|
      t.references :authz_controller_action,
                   index: { name: 'authz_bphca_controller_action_index' },
                   foreign_key: true

      t.references :authz_business_process,
                   index: { name: 'authz_bphca_business_process_index' },
                   foreign_key: true

      t.timestamps
    end
  end
end
