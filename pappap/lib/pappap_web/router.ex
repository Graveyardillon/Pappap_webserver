defmodule PappapWeb.Router do
  use PappapWeb, :router

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

  scope "/", PappapWeb do
    pipe_through :browser

    #get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", PappapWeb do
    pipe_through :api

    get "/load/image", ImageController, :load
    post "/upload/image", ImageController, :upload

    post "/signup", AuthController, :signup
    post "/signin", AuthController, :signin
    post "/signout", AuthController, :logout
    post "/user/get", UserController, :get
    post "/user/get_with_room", UserController, :get_with_room_id

    get "/tournament/participating", TournamentController, :get_participating
    get "/tournament/tabs", TournamentController, :get_tournament_topics
    post "/tournament", TournamentController, :create
    post "/tournament/start", TournamentController, :start
    post "/tournament/deleteloser", TournamentController, :delete_loser
    post "/tournament/claim_win", TournamentController, :claim_win
    post "/tournament/claim_lose", TournamentController, :claim_lose

    post "/follow", RelationController, :follow
    post "/unfollow", RelationController, :unfollow
    post "/following_list", RelationController, :following_list
    post "/chat/chat_room/create", ChatController, :create_chatroom
    post "/chat/chat_member/create", ChatController, :create_chatmember
    post "/chat/chats/create", ChatController, :create_chats

    post "/assistant", AssistantController, :create_assistant

    post "/entrant", EntrantController, :create

    post "/profileupdate", ProfileController, :send
    post "/register/device", DeviceController, :register_device_id

    get "/notification/list", NotificationController, :index

    post "/online/all", OnlineController, :get_online_users
    
    # DEBUG
    post "/notification/force", DeviceController, :force_notify

    post "/match", ReportController, :register_match
    post "/report", ReportController, :report
    post "/sync", SyncController, :sync
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PappapWeb.Telemetry
    end
  end
end
