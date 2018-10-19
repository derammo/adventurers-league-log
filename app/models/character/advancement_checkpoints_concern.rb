module Character::AdvancementCheckpointsConcern
  def total_checkpoints
    checkpoints_from_xp + total_checkpoints_from_logs
  end

  def checkpoint_level
    return total_checkpoints.floor / 4 + 1 if total_checkpoints <= 16
    (total_checkpoints.floor + 16) / 8 + 1
  end

  def checkpoints_to_next_level
    checkpoints_by_level(checkpoint_level + 1) - total_checkpoints
  end

  def checkpoints_for_level target_level
    return 0 if target_level == 1
    return 4 if target_level <= 5
    8
  end

  def checkpoints_by_level target_level
    return (target_level - 1) * 4 if target_level <= 5
    (target_level - 1) * 8 - 16
  end

  def total_checkpoints_from_logs
    log_entries.sum(:advancement_checkpoints)
  end


  def checkpoints_from_xp
    checkpoints_by_level(xp_level) + checkpoints_to_next_level_from_xp
  end

  def checkpoints_to_next_level_from_xp
    fractional_cp = (fraction_of_xp_to_next_level * checkpoints_for_level(xp_level + 1))
    return 0 if fractional_cp < 0

    if conversion_speed_slow?
      return (fractional_cp * 2).ceil / 2.0 if conversion_type_round_up?
      (fractional_cp * 2).floor / 2.0
    else
      return fractional_cp.ceil if conversion_type_round_up?
      fractional_cp.floor
    end
  end

end
