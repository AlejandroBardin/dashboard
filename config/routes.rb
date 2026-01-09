Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "webhooks", to: "webhooks#create"
    end
  end

  # Dashboard route (Hito 2)
  root "dashboards#index"
end
