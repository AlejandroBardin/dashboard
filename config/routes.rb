Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "webhooks", to: "webhooks#create"
    end
  end

  # Dashboard route (Hito 2)
  root "dashboards#index"

  get "/service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "/manifest.json" => "rails/pwa#manifest", as: :pwa_manifest
end
