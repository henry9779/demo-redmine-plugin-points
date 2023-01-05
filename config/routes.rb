resources :point_settings, only: %i[index create destroy]

resources :point_management, only: :index do
  collection do
    post :user_points
    get 'user_point_log', to: 'point_management#user_point_log'
  end
end

resources :points

resources :point_lines, only: :destroy do
  get 'edit_entries', to: 'point_lines#edit_entries'
  post 'update_entries', to: 'point_lines#update_entries'
end

post 'points/new', to: 'points#new'

put 'edit_point_lines', to: 'point_apis#edit_point_lines', as: 'edit_point_lines'
post 'check_projects_by_wade', to: 'point_apis#check_projects_by_wade', as: 'check_projects_by_wade'
post 'check_projects_by_cherry', to: 'point_apis#check_projects_by_cherry', as: 'check_projects_by_cherry'
