class Ability
  include CanCan::Ability

  def initialize(current_user)
    if current_user
      can :call, Skala::User::CreateNote, user: current_user
      can :call, Skala::User::CreateWatchList, user: current_user
      can :call, Skala::User::DeleteNote, note: { user: current_user }
      can :call, Skala::User::DeleteWatchListService, watch_list: { user: current_user }
      can :call, Skala::User::UpdateNote, note: { user: current_user }

      can :call, Skala::User::WatchList::CreateEntry do |_create_entry|
        _create_entry.watch_list.try(:user) == current_user
      end

      can :call, Skala::User::WatchList::DeleteEntry do |_delete_entry|
        _delete_entry.user == _delete_entry.entry.try(:watch_list).try(:user)
      end
    end

    can :call, Skala::GetRecord

    #can :call, GetRecords
    #can :call, Records::GetItems
    #can :call, SearchRecords

    #can :call, WatchList::CreateEntry do |_operation|
    #  _operation.user == user
    #end
=begin
    #
    # Note
    #
    can :manage, Note, user_id: user.try(:id)

    #
    # User
    #
    can [:edit, :show, :update], User, id: user.try(:id)

    #can :call, Servizio::Service do |operation|
    #  operation.class.to_s.deconstantize.starts_with?("User") && can?(:show, operation.user)
    #end

    #can :call, WatchListService do |operation|
    #  can?(:manage, operation.watch_list)
    #end

    #
    # WatchList
    #
    can :read, WatchList do |watch_list|
      can?(:manage, watch_list) || watch_list.slave_watch_lists.any? { |slave_watch_list| slave_watch_list.user == user }
    end

    can :manage, WatchList do |watch_list|
      watch_list.users.any? { |watch_list_user| watch_list_user == user }
    end

    #
    # WatchListEntry
    #
    can :manage, WatchListEntry do |watch_list_entry|
      can?(:manage, watch_list_entry.watch_list) || watch_list_entry.watch_list.is_shared_with?(user)
    end
=end
  end
end
