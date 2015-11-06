class Ability
  include CanCan::Ability

  def initialize(current_user = nil)
    if current_user
      #
      # UpdateUserEmailAddressService
      #
      if student?(current_user)
        cannot :call, UpdateUserEmailAddressService
      else
        can :call, UpdateUserEmailAddressService do |_instance|
          current_user.ilsuserid == _instance.ilsuserid
        end
      end

      #
      # UpdateUserPasswordService
      #
      can :call, UpdateUserPasswordService do |_instance|
        current_user.ilsuserid == _instance.ilsuserid
      end

      can :call, CreateUserHoldRequestService, ilsuserid: current_user.ilsuserid
    end
  end

  private

  def student?(ilsuserid_or_user)
    regex = /\APS/i

    if ilsuserid_or_user.is_a?(String)
      !!ilsuserid_or_user[regex]
    elsif ilsuserid_or_user.respond_to?(:ilsuserid)
      !!ilsuserid_or_user.send(:ilsuserid).try(:[], regex)
    else
      raise ArgumentError.new("Parameter has to be a/or respond to ilsuserid!")
    end
  end
end
