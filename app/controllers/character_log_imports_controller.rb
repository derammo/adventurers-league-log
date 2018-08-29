# :nodoc:
class CharacterLogImportsController < LogEntriesController
  def new
    if current_user
      # TODO show a dialog to pick a character and then redirect
      @character_log_import = CharacterLogImport.new
      authorize @character_log_import
      character  = Character.where(user_id: current_user).first()
      defaults = { :date_played => DateTime.now, :location_played => "roll20.net" }
      # TODO how do you use log_entries_params in this context to actually filter/permit the parameters?   
      redirect_to(import_user_character_character_log_entries_path(current_user, character.id, character_log_entry: defaults.merge(params[:character_log_entry].permit!))) && return
    else
      redirect_to(root_path) && return
    end
  end
 
  def log_entries_params
    params.require(:character_log_entry)
          .permit(:adventure_title, :treasure_tier, :session_num, :date_played,
                  :old_format, :advancement_checkpoints, :treasure_checkpoints,
                  :xp_gained, :gp_gained, :renown_gained,
                  :downtime_gained, :num_secret_missions,
                  :location_played, :dm_name, :dm_dci_number,
                  :player_dm_id, :notes,
                  magic_items_attributes: magic_item_params)
  end
end
