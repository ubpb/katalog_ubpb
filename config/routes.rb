Rails.application.routes.draw do
  mount Katalog::Engine, at: "/"
  root to:  redirect('/')
end
