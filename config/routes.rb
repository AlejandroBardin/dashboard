Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "webhooks", to: "webhooks#create"
      post "ai_responses", to: "ai_responses#create"
    end
  end

  post "dashboards/analyze", to: "dashboards#analyze", as: :analyze_dashboard

  resources :bot_failures, only: [ :index ]
  resources :delivery_failures, only: [ :index ]
  resources :design_failures, only: [ :index ]

  # Dashboard route (Hito 2)
  root "dashboards#index"

  get "/service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "/manifest.json" => "rails/pwa#manifest", as: :pwa_manifest
end
