class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      user.admin? ? admin_abilities : user_abilities(user)
    else
      guest_abilities
    end
  end

  def set_aliases
    alias_action :vote_up, :vote_down, :cancel_vote, to: :vote
  end

  def guest_abilities
    can :read, :all
  end

  def user_abilities(user)
    set_aliases

    guest_abilities

    can :create, [Question, Answer, Comment]
    can :manage, [Question, Answer], user_id: user.id
    can :vote, [Question, Answer]
    cannot :vote, [Question, Answer], user_id: user.id
    can :mark, Answer, question: { user_id: user.id }
    cannot :mark, Answer, user_id: user.id
    can :create, Badge, question: { user_id: user.id }
    can [:create, :destroy], Link, linkable: { user_id: user.id }
  end

  def admin_abilities
    can :manage, :all
  end
end
