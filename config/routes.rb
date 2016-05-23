require 'sidekiq/web'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#new_index'

  # get    "/thank-you"           => "home#thank_you",         as: :thank_you
  # post   "/email/process"       => "home#email_process",     as: :email_process
  post   "/concierge/process"             => "home#concierge_process", as: :concierge_process
  get    "/admin/twitter"                 => "admin#twitter",          as: :twitter
  post   "/admin/twitter"                 => "admin#twitter"
  get    "/admin/twitter/:id/followers"   => "admin#twitter_followers"
  get    "/admin/twitter/:id/job"         => "admin#twitter_job_rerun"

  get    "/admin/inbound"                 => "admin#inbound",          as: :inbound
  post   "/admin/inbound"                 => "admin#inbound"
  


  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == "sidekiq" && password == "sidekiq1905!"
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"
  
  get    "*unmatched_route"               => "home#no_route_match_error"
  end
