module UserRelatedService
  extend ActiveSupport::Concern

  included do
    attr_accessor :ilsuserid
    attr_accessor :user

    def ilsuserid
      @ilsuserid || user.try(:ilsuserid)
    end
  end
end
