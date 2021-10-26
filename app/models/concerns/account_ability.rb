# frozen_string_literal: true
# Ability
class AccountAbility
  include CanCan::Ability

  def initialize(account)
    account ||= Account.new
    can :manage, Account, id: account.id
  end
end
