server "ubstage1.upb.de", user: "ubpb", roles: %w{app db web}
set :deploy_to, "/ubpb/katalog"
set :branch, "stop-words"
