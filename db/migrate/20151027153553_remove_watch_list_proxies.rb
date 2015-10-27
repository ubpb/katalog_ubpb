class RemoveWatchListProxies < ActiveRecord::Migration

  class WatchList < ActiveRecord::Base ; end

  def up
    WatchList.where(name: "WatchList proxy").destroy_all
  end
end
