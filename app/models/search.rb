# This is only a dummy in order to be able to access old-fashioned searches
class Search < ActiveRecord::Base
  belongs_to :user
  serialize  :query
end
