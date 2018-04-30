class ShortendUrlsController < ApplicationController

  before_action :get_url, only: [:show, :shortend]
  skip_before_filter :verify_authencity_token

  def index
    @url ||= ShortendUrl.new
  end

  def show
    redirect_to @url.sanitize_url
  end

  def create
    @url = ShortendUrl.new
    @url.original_url = params[:original_url]
    @url.sanitize
    if @url.is_new_url?
      if @url.save
        redirect_to shortend_path(@url.short_url)
      else
        flash[:error] = 'check the error below'
        render action: :index and return
      end
    else
      flash[:notice] = 'A short link to this url is already present in database'
      redirect_to shortend_path(@url.find_duplicate.short_url)
    end
  end

  def shortend
    @url = ShortendUrl.find_by_short_url(params[:short_url])
    host = request.host_with_port
    @original_url = @url.sanitize_url
    @short_url = host + '/' + @url.short_url
  end

  def fetch_original_url
    fetch_url = ShortendUrl.find_by_short_url(params[:short_url])
    redirect_to fetch_url.sanitize_url
  end

  private
  def get_url
    @url = ShortendUrl.find_by_short_url(params[:short_url])
  end

  def url_params
    params.require(:url).permit(:original_url)
  end
end
