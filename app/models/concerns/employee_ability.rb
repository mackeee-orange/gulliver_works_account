# frozen_string_literal: true
# Ability
class EmployeeAbility
  include CanCan::Ability

  def initialize(employee)
    employee ||= Employee.new
    can :manage, Employee, id: employee.id
  end
end
