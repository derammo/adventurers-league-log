# :nodoc:
class CharacterLogEntriesController < LogEntriesController
  skip_before_action :authenticate_user!, only: [:show]

  add_crumb('Home', '/')
  before_action :load_user
  before_action :load_character
  before_action :build_log_entry, only: [:create]
  before_action :import_log_entry, only: [:import]
  before_action :load_log_entry, only: [:show, :edit, :update, :destroy]
  before_action :load_locations, only: [:new, :create, :edit, :update, :import]
  before_action :load_player_dms, only: [:new, :create, :edit, :update, :import]

  before_action do
    add_crumb @character.name,
              user_character_path(@character.user, @character)
  end

  before_action(only: [:new]) { add_crumb 'New Game Log Entry', '#' }
  before_action(only: [:edit]) { add_crumb 'Edit Log Entry' }
  before_action(only: [:show]) { add_crumb 'Show Log Entry' }

  def show
    authorize @log_entry
    @magic_items = @log_entry.magic_items.where(character: @character)
  end

  def new
    @log_entry = @character.character_log_entries.new
    @log_entry.characters = [@character]
    @log_entry.old_format = @user.character_log_entry_style_old?
    authorize @log_entry
    @magic_items = [MagicItem.new]
    @magic_item_count = 0
  end

  def create
    authorize @log_entry
    manage_locations
    manage_player_dms

    if @log_entry.save
      redirect_to user_character_path(current_user, @character, q: params[:q]),
                  flash: { notice: 'Successfully created log entry '\
                                   "#{@log_entry.adventure_title}" }
    else
      flash.now[:error] = log_entry_error_message 'create'
      render :new, q: params[:q]
    end
  end

  def import
    authorize @log_entry
    @magic_items = [MagicItem.new] + @log_entry.magic_items
    @magic_item_count = @log_entry.magic_items.count
    @use_location_override = true
    @use_dm_override = true
    render :new, q: params[:q]
  end

  def edit
    authorize @log_entry
    @magic_items = [MagicItem.new] + @log_entry.magic_items
    @magic_item_count = @log_entry.magic_items.count
  end

  def update
    authorize @log_entry
    manage_locations
    manage_player_dms

    if @log_entry.update_attributes(log_entries_params)
      redirect_to user_character_path(current_user, @character, q: params[:q]),
                  flash: { notice: 'Successfully updated log entry '\
                                   "#{@log_entry.adventure_title}" }
    else
      flash.now[:error] = log_entry_error_message 'update'
      render :edit, q: params[:q]
    end
  end

  def destroy
    authorize @log_entry
    @log_entry.destroy

    redirect_to user_character_path(current_user, @character, q: params.permit(q: [:s]).fetch(:q, nil)),
                flash: { notice: 'Successfully deleted '\
                                 "#{@log_entry.adventure_title}" }
  end

  protected

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_character
    @character   = Character.find(params[:character_id])
  end

  def load_log_entry
    @log_entry   = LogEntry.find(params[:id])
  end

  def build_log_entry
    @log_entry = @character.character_log_entries.build(log_entries_params)
    @log_entry.characters = [@character]
  end

  # TODO: why does the default implementation of build not work, preventing us from using build_log_entry for the import action?
  def import_log_entry
    @log_entry = @character.character_log_entries.build(log_entries_params.except(:magic_items_attributes))
    @log_entry.characters = [@character]
    # uncounted item 0
    @magic_items = [MagicItem.new]
    log_entries_params[:magic_items_attributes].each { |k, v| 
      @magic_items.push(@log_entry.magic_items.build(v.except(:_destroy, :_id)))
    }
    @magic_item_count = @magic_items.count - 1
  end

  def load_player_dms
    @player_dms = @user.player_dms.all
  end

  def manage_player_dms
    if params[:character_log_entry][:player_dm_id].present?
      load_existing_player_dm
    elsif params[:character_log_entry][:dm_dci_number].present?
      create_player_dm
    end
  end

  def load_existing_player_dm
    player_dm_id = params[:character_log_entry][:player_dm_id]
    @player_dm = @user.player_dms.find(player_dm_id)

    params[:character_log_entry][:dm_name]       = @player_dm.name
    params[:character_log_entry][:dm_dci_number] = @player_dm.dci
  end

  def create_player_dm
    dm_name = params[:character_log_entry][:dm_name]
    dm_dci_number = params[:character_log_entry][:dm_dci_number]

    @player_dm = @user.player_dms.find_or_create_by!(
      name: dm_name,
      dci: dm_dci_number
    )

    params[:character_log_entry][:player_dm_id] = @player_dm.id
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
