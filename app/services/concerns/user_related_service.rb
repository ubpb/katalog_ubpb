module UserRelatedService
  extend ActiveSupport::Concern

  included do
    attr_accessor :ilsuserid
    attr_accessor :user
    attr_accessor :user_id

    def ils_user_id
      @ils_user_id || ilsuserid
    end

    def ils_user_id=(value)
      self.ilsuserid = value
    end

    def ilsuserid
      @ilsuserid || user.try(:ilsuserid)
    end

    def user
      if @user
        @user
      elsif @user_id
        User.find_by_id(@user_id)
      end
    end
  end
end
