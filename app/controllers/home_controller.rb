class HomeController < ApplicationController
  def index
    if current_user
      redirect_to(user_characters_path(current_user)) && return
    else
      @show_jumbotron = true
    end
  end

  def character_log_entries_import
    if current_user
      redirect_to(user_characters_path(current_user, character_log_entry: params.permit([:character_log_entry])[:character_log_entry])) && return
    else
      @show_jumbotron = true
    end
  end

  def stats
    @users_count             = User.count
    @characters_count        = Character.count
    @public_characters_count = Character.where(publicly_visible: true).count
    @log_entries_count       = LogEntry.count

    @factions_count          = Faction.all.map { |faction| [faction.name, faction.characters.count] }
  end

  def donate

  end
end
