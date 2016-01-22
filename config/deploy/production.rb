server "131.234.233.141", user: "ubpb", roles: %w{app db web}
server "131.234.233.142", user: "ubpb", roles: %w{app web}
set :branch, "production"
set :deploy_to, "/ubpb/katalog-production"
