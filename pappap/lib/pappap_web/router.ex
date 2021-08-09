defmodule PappapWeb.Router do
  use PappapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CORSPlug, origin: ["https://e-players-web.web.app"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["https://e-players-web.web.app"]
  end

  scope "/", PappapWeb do
    pipe_through :browser

    get "/", BrowserController, :index
  end

  scope "/api", PappapWeb do
    pipe_through :api
    get  "/check/connection", ConnectionCheckController, :connection_check

    get  "/load/image", ImageController, :load
    post "/upload/image", ImageController, :upload

    get  "/auth/:string", AuthController, :pass_get_request
    post "/auth/signup", AuthController, :signup
    options "/auth/signup", AuthController, :options
    post "/auth/:string", AuthController, :pass_post_request
    options "/auth/:string", AuthController, :options
    post "/user_report", UserController, :report
    options "/user_report", UserController, :options
    post "/tournament_report", TournamentController, :report
    options "/tournament_report", TournamentController, :options
    post "/user/get", UserController, :get
    post "/user/get_with_room", UserController, :get_with_room_id
    get  "/user/:string", UserController, :pass_get_request
    post "/user/:string", UserController, :pass_post_request
    delete "/user/:string", UserController, :pass_delete_request
    options "/user/:string", UserController, :options

    get  "/conf/:string", ConfController, :pass_get_request
    post "/conf/:string", ConfController, :pass_post_request

    post "/tournament", TournamentController, :create
    options "/tournament", TournamentController, :options
    post "/tournament/start", TournamentController, :start
    post "/tournament/start_match", TournamentController, :start_match
    post "/tournament/claim_win", TournamentController, :claim_win
    post "/tournament/claim_lose", TournamentController, :claim_lose
    post "/tournament/claim_score", TournamentController, :claim_score
    post "/tournament/defeat", TournamentController, :force_to_defeat
    post "/tournament/finish", TournamentController, :finish
    get "/tournament/home/:string", TournamentController, :pass_home_request

    get  "/tournament/:string", TournamentController, :pass_get_request
    post "/tournament/:string", TournamentController, :pass_post_request
    options "/tournament/:string", TournamentController, :options
    # get  "/tournament/get_game", TournamentController, :get_game
    # TODO: 画像なのでwebserverでもいろいろしないといけない
    # get  "/tournament/get_thumbnail", TournamentController, :get_thumbnail_image
    # TODO: 動作未確認
    # post "/tournament/update_tabs", TournamentController, :tournament_update_topics

    get  "/relation/:string", RelationController, :pass_get_request
    post "/relation/:string", RelationController, :pass_post_request
    options "/relation/:string", RelationController, :options

    # TODO: チャットのリクエストのルーティングの、ファイルの中の関数を含めた調整
    get  "/chat/:string", ChatController, :pass_get_request
    post "/chat/:string", ChatController, :pass_post_request
    options "/chat/:string", ChatController, :options
    delete "/chat", ChatController, :delete

    post "/chat/chat_room/create", ChatController, :create_chatroom
    options "/chat/chat_room/create", ChatController, :options
    post "/chat_room/private_rooms", ChatController, :private_rooms
    post "/chat/chat_member/create", ChatController, :create_chatmember
    options "/chat/chat_member/:string", ChatController, :options
    post "/chat/chats/create", ChatController, :create_chats
    options "/chat/chats/:string", ChatController, :_options

    get  "/chat_room", ChatRoomController, :show
    get  "/chat_room/:string", ChatRoomController, :pass_get_request
    post "/chat_room/:string", ChatRoomController, :pass_post_request
    options "/chat_room/:string", ChatController, :options

    post "/assistant", AssistantController, :create_assistant
    options "/assistant", AssistantController, :options

    post "/entrant", EntrantController, :create
    options "/entrant", EntrantController, :options
    get  "/entrant/rank/:tournament_id/:user_id", EntrantController, :show_rank
    get  "/entrant/:string", EntrantController, :pass_get_request
    post "/entrant/:string", EntrantController, :pass_post_request
    options "/entrant/:string", EntrantController, :options
    delete "/entrant/:string", EntrantController, :pass_delete_request

    post "/team", TeamController, :create
    options "/team", TeamController, :options
    delete "/team", TeamController, :delete
    get "/team", TeamController, :show
    get "/team/:string", TeamController, :pass_get_request
    post "/team/:string", TeamController, :pass_post_request
    options "/team/:string", TeamController, :options

    options "/device/:string", DeviceController, :options
    post "/device/:string", DeviceController, :pass_post_request

    get  "/game/:string", GameController, :pass_get_request
    post "/game/:string", GameController, :pass_post_controller
    options "/game/:string", GameController, :options

    get  "/notification/:string", NotificationController, :pass_get_request
    post "/notification/:string", NotificationController, :pass_post_request
    options "/notification/:string", NotificationController, :options
    delete "/notification/:string", NotificationController, :pass_delete_request

    get "/profile", ProfileController, :show
    get  "/profile/:string", ProfileController, :pass_get_request
    post "/profile/update_icon", ProfileController, :update_icon
    post "/profile/:string", ProfileController, :pass_post_request
    options "/profile/:string", ProfileController, :options
    post "/profile", ProfileController, :send
    options "/profile", ProfileController, :options

    post "/sync", SyncController, :sync
    options "/sync", SyncController, :options

    post "/online/all", OnlineController, :get_online_users
    options  "/online/all", OnlineController, :options
    get  "/online/entrants", OnlineController, :get_online_entrants
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
