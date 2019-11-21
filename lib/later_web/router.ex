defmodule LaterWeb.Router do
  use LaterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # scope "/", LaterWeb do
  #   pipe_through :browser

  #   # get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/", LaterWeb do
    pipe_through :api

    post "/files", FileController, :new
    put "/files/:public_token/release_on", FileController, :release_on
    put "/files/:public_token/keep_private", FileController, :stay_private
    post "/files/:public_token/info/", FileController, :info
    get "/files/:public_token", FileController, :get
    delete "/files/:public_token", FileController, :delete
  end
end
