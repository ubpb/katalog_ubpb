class ExportWatchListMailer < ActionMailer::Base
  default from: "webmaster@ub.uni-paderborn.de"

  def export_watch_list_email(user, watch_list, records, calling_controller)
    @user = user
    @watch_list = watch_list
    @records = records

    # need to use the request from the calling controller in order for url helpers to work and we need urls (not paths) in our email
    # http://pivotallabs.com/users/nick/blog/articles/281-how-i-learned-to-stop-hating-and-love-action-mailer
    default_url_options[:host] = calling_controller.request.host
    default_url_options[:protocol] = calling_controller.request.protocol.gsub(/:\/\//, '') # need to strip the following '://'
    default_url_options[:port] = calling_controller.request.port unless default_url_options[:protocol].eql? 'https'

    unless user.email.blank?
      mail(:to => user.email, :subject => "Ihre Merkliste: #{watch_list.name}")
      calling_controller.flash[:success] = 'Merkliste wurde versandt.'
    else
      calling_controller.flash[:error] = 'Merkliste konnte nicht versandt werden. Es liegt keine Emailadresse vor.'
    end
  end
end
