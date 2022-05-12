defmodule PappapWeb.Router do
  use PappapWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CORSPlug, origin: [
      "https://e-players-web.web.app",
      "https://epbeta.papillon.co.jp",
      "https://eplayers.co.jp"
    ]
  end

  pipeline :api do
    plug :accepts, ["json", "jpeg", "png"]
    plug CORSPlug, origin: [
      "https://e-players-web.web.app",
      "https://epbeta.papillon.co.jp",
      "https://eplayers.co.jp"
    ]
  end

  scope "/", PappapWeb do
    pipe_through :browser

    get "/", BrowserController, :index
  end

  scope "/api", PappapWeb do
    pipe_through :api
    get  "/check/connection", ConnectionCheckController, :connection_check
    post "/check/data_for_web", ConnectionCheckController, :data_for_web
    options "/check/data_for_web", PreflightController, :preflight

    get  "/load/image", ImageController, :load
    post "/upload/image", ImageController, :upload
    get "/image/:string", ImageController, :pass_get_image_by_path_request

    get  "/auth/:string", AuthController, :pass_get_request
    post "/auth/signup", AuthController, :signup
    options "/auth/signup", PreflightController, :preflight
    post "/auth/:string", AuthController, :pass_post_request
    options "/auth/:string", PreflightController, :preflight
    post "/user_report", UserController, :report
    options "/user_report", PreflightController, :preflight
    post "/tournament_report", TournamentController, :report
    options "/tournament_report", PreflightController, :preflight
    post "/user/get", UserController, :get
    post "/user/get_with_room", UserController, :get_with_room_id
    get  "/user/:string", UserController, :pass_get_request
    post "/user/:string", UserController, :pass_post_request
    delete "/user/:string", UserController, :pass_delete_request
    options "/user/:string", PreflightController, :preflight

    get  "/conf/:string", ConfController, :pass_get_request
    post "/conf/:string", ConfController, :pass_post_request

    post "/tournament", TournamentController, :create
    options "/tournament", PreflightController, :preflight
    post "/tournament/defeat", TournamentController, :force_to_defeat
    post "/tournament/finish", TournamentController, :finish
    get "/tournament/home/:string", TournamentController, :pass_home_request
    get "/tournament/url/:url", TournamentController, :redirect_by_url

    get "/tournament/:string", TournamentController, :pass_get_request
    post "/tournament/:string", TournamentController, :pass_post_request
    delete "/tournament/:string", TournamentController, :pass_delete_request
    options "/tournament/:string", PreflightController, :preflight
    # get  "/tournament/get_game", TournamentController, :get_game
    # TODO: 画像なのでwebserverでもいろいろしないといけない
    # get  "/tournament/get_thumbnail", TournamentController, :get_thumbnail_image

    get  "/relation/:string", RelationController, :pass_get_request
    post "/relation/:string", RelationController, :pass_post_request
    options "/relation/:string", PreflightController, :preflight

    post "/chat/upload/image", ImageController, :upload
    get "/chat/load/image", ImageController, :load

    # TODO: チャットのリクエストのルーティングの、ファイルの中の関数を含めた調整
    get  "/chat/:string", ChatController, :pass_get_request
    post "/chat/:string", ChatController, :pass_post_request
    options "/chat/:string", PreflightController, :preflight
    delete "/chat", ChatController, :delete

    post "/chat/chat_room/create", ChatController, :create_chatroom
    options "/chat/chat_room/create", PreflightController, :preflight
    post "/chat_room/private_rooms", ChatController, :private_rooms
    post "/chat/chat_member/create", ChatController, :create_chatmember
    options "/chat/chat_member/:string", PreflightController, :preflight
    post "/chat/chats/create", ChatController, :create_chats
    options "/chat/chats/:string", PreflightController, :preflight

    get  "/chat_room", ChatRoomController, :show
    get  "/chat_room/:string", ChatRoomController, :pass_get_request
    post "/chat_room/:string", ChatRoomController, :pass_post_request
    options "/chat_room/:string", PreflightController, :preflight

    get "/bracket", BracketController, :show
    get "/bracket/:string", BracketController, :pass_get_request
    post "/bracket", BracketController, :create
    post "/bracket/:string", BracketController, :pass_post_request
    delete "/bracket", BracketController, :delete
    delete "/bracket/:string", BracketController, :pass_delete_request
    options "/bracket/:string", PreflightController, :preflight

    get "/discord/:string", DiscordController, :pass_get_request
    post "/discord/:string", DiscordController, :pass_post_request
    delete "/discord/:string", DiscordController, :pass_delete_request
    options "/discord/:string", PreflightController, :preflight

    post "/assistant", AssistantController, :create_assistant
    options "/assistant", PreflightController, :preflight

    post "/entrant", EntrantController, :create
    options "/entrant", PreflightController, :preflight
    get  "/entrant/rank/:tournament_id/:user_id", EntrantController, :show_rank
    get  "/entrant/:string", EntrantController, :pass_get_request
    post "/entrant/:string", EntrantController, :pass_post_request
    options "/entrant/:string", PreflightController, :preflight
    delete "/entrant/:string", EntrantController, :pass_delete_request

    post "/team/invitation_confirm", TeamController, :confirm_invitation
    options "/team/invitation_confirm", TeamController, :options
    post "/team", TeamController, :create
    options "/team", PreflightController, :preflight
    delete "/team", TeamController, :delete
    get "/team", TeamController, :show
    get "/team/:string", TeamController, :pass_get_request
    post "/team/:string", TeamController, :pass_post_request
    options "/team/:string", PreflightController, :preflight

    options "/device/:string", PreflightController, :preflight
    post "/device/:string", DeviceController, :pass_post_request

    get  "/game/:string", GameController, :pass_get_request
    post "/game/:string", GameController, :pass_post_controller
    options "/game/:string", PreflightController, :preflight

    get  "/notification/:string", NotificationController, :pass_get_request
    post "/notification/:string", NotificationController, :pass_post_request
    options "/notification/:string", PreflightController, :preflight
    delete "/notification/:string", NotificationController, :pass_delete_request

    get "/profile", ProfileController, :show
    get  "/profile/:string", ProfileController, :pass_get_request
    post "/profile/update_icon", ProfileController, :update_icon
    options "/profile/update_icon", PreflightController, :preflight
    post "/profile/:string", ProfileController, :pass_post_request
    options "/profile/:string", PreflightController, :preflight
    post "/profile", ProfileController, :send
    options "/profile", PreflightController, :preflight
    delete "/profile/:string", ProfileController, :pass_delete_request

    post "/sync", SyncController, :sync
    options "/sync", PreflightController, :preflight
  end

  # DEBUG
  scope "/api", PappapWeb do
    pipe_through :api

    post "/notification/force", DeviceController, :force_notify
    post "/broadcast", DeviceController, :broadcast
    post "/dtw", TournamentController, :debug_tournament_ws

    post "/match", ReportController, :register_match
    #post "/report", ReportController, :report
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
