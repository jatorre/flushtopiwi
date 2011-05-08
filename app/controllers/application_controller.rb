class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404: #{exception.message}"
      logger.info "Backtrace: #{exception.backtrace}"
    end

    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500: #{exception.message}"
      logger.info 'Backtrace:'
      logger.info exception.backtrace.join("\n")
    end

    render :file => "#{Rails.root}/public/500.html", :status => 500, :layout => false
  end

end
