class Users::FeesController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    @fees = Skala::User::FeesDecorator.decorate Skala::GetUserFeesService.call({
      ils_adapter: KatalogUbpb.config.ils_adapter.instance,
      locale: current_locale,
      user_id: current_user.username
    })
  end
end
