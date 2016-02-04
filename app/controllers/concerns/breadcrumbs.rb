module Breadcrumbs
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
  end

  def add_breadcrumb(name: nil, url: request.fullpath)
    name ||= "#{controller_path.gsub("/", ".")}##{action_name}"

    @breadcrumbs ||= []
    @breadcrumbs.push({name: name, url: url})
  end

  def breadcrumbs
    @breadcrumbs
  end

end
