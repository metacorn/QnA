class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      user.admin? ? admin_abilities : user_abilities(user)
    else
      guest_abilities
    end
  end

  def guest_abilities
    can :read, :all
  end

  def user_abilities(user)
    alias_action :vote_up, :vote_down, :cancel_vote, to: :vote

    guest_abilities

    can :create, [Question, Answer, Comment]
    can :manage, [Question, Answer], user_id: user.id
    can :vote, [Question, Answer]
    cannot :vote, [Question, Answer], user_id: user.id
    can :mark, Answer, question: { user_id: user.id }
    cannot :mark, Answer, user_id: user.id
    can :destroy, Link, linkable: { user_id: user.id }
    can :destroy, ActiveStorage::Attachment, record: { user_id: user.id }
    can :me, User, id: user.id
  end

  def admin_abilities
    can :manage, :all
  end
end
