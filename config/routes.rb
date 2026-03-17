Qedit::Engine.routes.draw do
  root to: "editor#index"

  get  "files",        to: "editor#files"
  get  "file",         to: "editor#show"
  put  "file",         to: "editor#update"
  post "lint",         to: "editor#lint"
  get  "ping",         to: "editor#ping"

  get  "monaco/*path", to: "monaco#serve", format: false, as: :monaco
end
