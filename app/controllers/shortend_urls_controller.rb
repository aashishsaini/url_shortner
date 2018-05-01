class ShortendUrlsController < ApplicationController

  before_action :get_url, only: [:show, :shortend]
  skip_before_filter :verify_authencity_token

  # displays the blank form to create the shortend url
  def index
    @url = ShortendUrl.new
  end

  # visit the shortend url or used to see the stats around shortend url in json and xml format
  def show
    unless api_request?
      @url.add_user_details(request, true)
    else
      result = params[:q] ? ShortendUrl.search_url(params[:q]) : [@url]
    end
    respond_to do |format|
      format.html {redirect_to @url.sanitize_url and return} # response for normal http request
      format.json {render json: ShortendUrl.serialize_response(result)} # response to api in json format
      format.xml {render xml: ShortendUrl.serialize_xml_response(result)}# response to api in xml format
    end
  end

  # creates the shortend url and displays the success and error message
  def create
    @url = ShortendUrl.new
    @url.original_url = params[:original_url]
    @url.sanitize
    if @url.is_new_url?
      if @url.save
        # add user details to the url created
        @url.add_user_details(request, false, true)
        redirect_to shortend_path(@url.short_url)
      else #unable to save the associated url
        flash[:error] = 'check the error below'
        render action: :index and return
      end
    else #if url is not new then redirect to already existed url page where user can access the previously created short url
      @url.add_user_details(request)
      flash[:notice] = 'A short link to this url is already present in database'
      redirect_to shortend_path(@url.find_duplicate.short_url)
    end
  end

  # used to show the shortend url
  def shortend
    @url = ShortendUrl.find_by_short_url(params[:short_url])
    host = request.host_with_port
    @original_url = @url.sanitize_url
    @short_url = host + '/' + @url.short_url
  end

  private
  # gets the url
  def get_url
    @url = ShortendUrl.find_by_short_url(params[:short_url])
  end

  def url_params
    params.require(:url).permit(:original_url)
  end

  # checks if the request is an api request or normal web request
  def api_request?
    request.format.json? || request.format.xml?
  end
end