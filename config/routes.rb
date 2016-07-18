require 'sidekiq/web'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#new_index'

  # get    "/thank-you"           => "home#thank_you",         as: :thank_you
  # post   "/email/process"       => "home#email_process",     as: :email_process
  post   "/concierge/process"             => "home#concierge_process", as: :concierge_process
  
  get    "/admin"                         => "admin#index",            as: :admin
  get    "/admin/twitter"                 => "admin#twitter",          as: :twitter
  post   "/admin/twitter"                 => "admin#twitter"
  get    "/admin/twitter/:id/followers"   => "admin#twitter_followers"
  get    "/admin/twitter/:id/job"         => "admin#twitter_job_rerun"
  get    "/admin/twitter/tweets/:id"      => "admin#twitter_tweets" 

  get    "/admin/inbound"                 => "admin#inbound",          as: :inbound
  post   "/admin/inbound"                 => "admin#inbound"
  get    "/admin/inbound/:id/run"         => "admin#inbound_crawl"
  get    "/admin/inbound/:id/update"      => "admin#inbound_crawl"
  get    "/admin/inbound/:id"             => "admin#ajax_inbound_user_modal", format: "js"
  get    "/admin/twitter-tweets-all"      => "admin#twitter_tweets_all",      format: "json"

  # AWS tracking
  get    "/admin/tracking/90078359cb94c2401bb7dc6e4d68ac32/bounce"         =>  "admin/aws#bounce"
  get    "/admin/tracking/02abbe35eecc06b40e4e9794d097be46/complaint"      =>  "admin/aws#complaint"
  get    "/admin/tracking/227d6bc3c8858f21c1ab216c79ff1ed2/delivered"      =>  "admin/aws#delivered"
  get    "/admin/aws"                                                      =>  "admin/aws#view"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == "sidekiq" && password == "sidekiq1905!"
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"
  
  get    "*unmatched_route"               => "home#no_route_match_error"
  end
