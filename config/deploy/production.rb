server "ubkatalog1", user: "ubpb", roles: %w{app web db}
server "ubkatalog2", user: "ubpb", roles: %w{app web}
set :branch, "production"
set :deploy_to, "/ubpb/katalog-production"
