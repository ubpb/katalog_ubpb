server "ubpegasus18", user: "ubpb", roles: %w{app web db}
server "ubperseus18", user: "ubpb", roles: %w{app web}
set :branch, "es6"
set :deploy_to, "/ubpb/katalog"
