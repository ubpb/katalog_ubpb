# This is only a dummy in order to be able to access version 1.x searches
class Compatibility::Search < ActiveRecord::Base
  self.table_name = "searches"

  belongs_to :user
  serialize  :query
end
