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
  end

  scope "/api", PappapWeb do
    pipe_through :api

    get  "/load/image", ImageController, :load
    post "/upload/image", ImageController, :upload

    get  "/auth/:string", AuthController, :pass_get_request
    post "/auth/:string", AuthController, :pass_post_request
    post "/user_report", UserController, :report
    post "/user/get", UserController, :get
    post "/user/get_with_room", UserController, :get_with_room_id
    get  "/user/:string", UserController, :pass_get_request
    post "/user/:string", UserController, :pass_post_request

    post "/tournament", TournamentController, :create
    post "/tournament/start", TournamentController, :start
    post "/tournament/claim_win", TournamentController, :claim_win
    post "/tournament/claim_lose", TournamentController, :claim_lose
    post "/tournament/finish", TournamentController, :finish

    get  "/tournament/:string", TournamentController, :pass_get_request
    post "/tournament/:string", TournamentController, :pass_post_request
    # get  "/tournament/get_game", TournamentController, :get_game
    # TODO: 画像なのでwebserverでもいろいろしないといけない
    # get  "/tournament/get_thumbnail", TournamentController, :get_thumbnail_image
    # TODO: 動作未確認
    # post "/tournament/update_tabs", TournamentController, :tournament_update_topics

    get  "/relation/:string", RelationController, :pass_get_request
    post "/relation/:string", RelationController, :pass_post_request

    # TODO: チャットのリクエストのルーティングの、ファイルの中の関数を含めた調整
    get  "/chat/:string", ChatController, :pass_get_request
    post "/chat/:string", ChatController, :pass_post_request
    delete "/chat", ChatController, :delete

    post "/chat/chat_room/create", ChatController, :create_chatroom
    post "/chat_room/private_rooms", ChatController, :private_rooms
    post "/chat/chat_member/create", ChatController, :create_chatmember
    post "/chat/chats/create", ChatController, :create_chats

    get  "/chat_room", ChatRoomController, :show
    get  "/chat_room/:string", ChatRoomController, :pass_get_request
    post "/chat_room/:string", ChatRoomController, :pass_post_request

    post "/assistant", AssistantController, :create_assistant

    post "/entrant", EntrantController, :create
    get  "/entrant/rank/:tournament_id/:user_id", EntrantController, :show_rank
    get  "/entrant/:string", EntrantController, :pass_get_request
    post "/entrant/:string", EntrantController, :pass_post_request
    delete "/entrant/:string", EntrantController, :pass_delete_request

    post "/register/device", DeviceController, :register_device_id

    get  "/game/:string", GameController, :pass_get_request
    post "/game/:string", GameController, :pass_post_controller

    get  "/notification/:string", NotificationController, :pass_get_request
    post "/notification/:string", NotificationController, :pass_post_request

    get  "/profile/:string", ProfileController, :pass_get_request
    post "/profile/:string", ProfileController, :pass_post_request
    post "/profile", ProfileController, :send

    post "/sync", SyncController, :sync

    post "/online/all", OnlineController, :get_online_users
  end

  # DEBUG
  scope "/api", PappapWeb do
    pipe_through :api

    post "/notification/force", DeviceController, :force_notify
    post "/broadcast", DeviceController, :broadcast
    post "/dtw", TournamentController, :debug_tournament_ws

    post "/match", ReportController, :register_match
    post "/report", ReportController, :report
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
