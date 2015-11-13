#= require urijs/URI

(window.app ?= {}).PathHelpers = class
  @path_helper_factory: (path) ->
    (path_arguments..., options = {}) ->
      unless typeof(options) == "object"
        path_arguments.push(options)
        options = {}

      # create a uri object from the current url and extract the query params
      uri = URI(path)
      params = uri.query(true)

      # overwrite original params with the given options
      for key of options
        value = options[key]
        params[key] = if typeof(value) == "object" then JSON.stringify(value) else value

      # convert the uri object to a path
      path = uri.query(params).protocol("").host("").toString()
      [non_query_part, query_part] = path.split("?")

      # replace path arguments in non query part
      for path_argument in path_arguments
        non_query_part = non_query_part.replace(/:\w*/, path_argument)

      if query_part
        #loosely_encoded_query = (_.map query_part.split("&"), (element) ->
        #  decodeURIComponent(element).replace(/&/g, "%26")
        #).join("&")

        [non_query_part, query_part].join("?")
      else
        non_query_part
