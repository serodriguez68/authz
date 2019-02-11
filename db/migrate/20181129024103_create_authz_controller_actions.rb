class CreateAuthzControllerActions < ActiveRecord::Migration[5.2]
  def change
    create_table :authz_controller_actions do |t|
      t.string :controller
      t.string :action

      t.timestamps
    end
    add_index :authz_controller_actions, [:controller, :action], unique: true
  end
end
