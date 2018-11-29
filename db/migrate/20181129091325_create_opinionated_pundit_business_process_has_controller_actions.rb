class CreateOpinionatedPunditBusinessProcessHasControllerActions < ActiveRecord::Migration[5.2]
  def change
    # create_table :opinionated_pundit_business_process_has_controller_actions do |t|
    #   t.integer :controller_action_id, index: { name: 'opinionated_pundit_bphca_controller_action_index' }
    #   t.integer :business_process_id,  index: { name: 'opinionated_pundit_bphca_business_process_index' }
    #
    #   t.timestamps
    # end
    #
    # add_foreign_key :opinionated_pundit_business_process_has_controller_actions,
    #                 :opinionated_pundit_controller_actions,
    #                 column: :controller_action_id
    #
    # add_foreign_key :opinionated_pundit_business_process_has_controller_actions,
    #                 :opinionated_pundit_business_processes,
    #                 column: :business_process_id


    create_table :opinionated_pundit_business_process_has_controller_actions do |t|
      t.references :opinionated_pundit_controller_action,
                   index: { name: 'opinionated_pundit_bphca_controller_action_index' },
                   foreign_key: true

      t.references :opinionated_pundit_business_process,
                   index: { name: 'opinionated_pundit_bphca_business_process_index' },
                   foreign_key: true

      t.timestamps
    end
  end
end
