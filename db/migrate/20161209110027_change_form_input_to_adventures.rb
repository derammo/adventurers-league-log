class ChangeFormInputToAdventures < ActiveRecord::Migration[5.2]
  def change
    rename_table :form_inputs, :adventures
    remove_column :adventures, :type
  end
end
