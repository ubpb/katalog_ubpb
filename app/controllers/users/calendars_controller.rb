class Users::CalendarsController < UsersController

  before_filter { add_breadcrumb name: "users.calendars#index" }

end
