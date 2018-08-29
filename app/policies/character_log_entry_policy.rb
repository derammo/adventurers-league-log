class CharacterLogEntryPolicy < ApplicationPolicy
  class Scope < Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(user_id: user.id)
    end
  end

  def show?
    if record.character.publicly_visible?
      true
    else
      user_is_current_user
    end
  end

  def print?
    show?
  end

  def new?
    user_is_current_user
  end

  def create?
    user_is_current_user
  end

  def edit?
    user_is_current_user
  end

  def update?
    user_is_current_user
  end

  def destroy?
    user_is_current_user
  end

  def import?
    user_is_current_user
  end
end
