Rails.application.routes.draw do
  mount Skala::Frontend::Engine, at: "/"
  root to:  redirect('/')
end
