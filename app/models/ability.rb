class Ability
  include CanCan::Ability

  def initialize(current_user = nil)
    if current_user
      #
      # Notes
      #
      can :call, CreateNoteService, user: current_user
      can :call, DeleteNoteService, note: { user: current_user }
      can :call, GetUserNotesService, user: current_user
      can :call, UpdateNoteService, note: { user: current_user }

      #
      # UpdateUserEmailAddressService
      #
      if student?(current_user)
        cannot :call, UpdateUserEmailAddressService
      elsif employee?(current_user)
        cannot :call, UpdateUserEmailAddressService
      else
        can :call, UpdateUserEmailAddressService do |_instance|
          current_user.ilsuserid == _instance.ilsuserid
        end
      end

      #
      # user
      #
      can :call, UpdateUserPasswordService, ilsuserid: current_user.ilsuserid

      #
      # hold_requests
      #
      can :call, CreateUserHoldRequestService, ilsuserid: current_user.ilsuserid
      can :call, DeleteUserHoldRequestService, ilsuserid: current_user.ilsuserid

      #
      # loans
      #
      can :call, RenewAllUserLoansService, ilsuserid: current_user.ilsuserid
      can :call, RenewUserLoanService, ilsuserid: current_user.ilsuserid

      #
      # watch lists
      #
      can :call, CreateWatchListService, user: current_user
      can :call, DeleteWatchListService, { watch_list: { user: current_user } }
      can :call, GetUserWatchListsService, user: current_user
      can :call, GetWatchListService do |_operation|
        watch_list = WatchList.find_by_id(_operation.id)
        watch_list.blank? || watch_list.user == current_user
      end
      can :call, UpdateWatchListService, { watch_list: { user: current_user } }

      #
      # watch list entries
      #
      can :call, CreateWatchListEntryService do |_operation|
        _operation.watch_list.user == current_user
      end

      can :call, GetWatchListWatchListEntriesService do |_operation|
        _operation.watch_list.user == current_user
      end

      can :call, DeleteWatchListEntryService do |_operation|
        _operation.watch_list_entry.watch_list.user == current_user
      end
    end

    #
    # records
    #
    can :call, GetRecordsService
    can :call, SearchRecordsService
  end

private

  def student?(user)
    !!(user.ilsusername =~ /\APS/i)
  end

  def employee?(user)
    !!(user.ilsusername =~ /\APA/i)
  end

end
