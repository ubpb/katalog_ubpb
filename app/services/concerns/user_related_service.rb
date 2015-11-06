module UserRelatedService
  extend ActiveSupport::Concern

  included do
    attr_accessor :ilsuserid
    attr_accessor :user

    def ils_user_id
      @ils_user_id || ilsuserid
    end

    def ilsuserid
      @ilsuserid || user.try(:ilsuserid)
    end
  end
end
