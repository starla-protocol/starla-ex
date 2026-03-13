import Config

config :starla_ex,
  start_http: true,
  http_port: 4747

import_config "#{config_env()}.exs"
