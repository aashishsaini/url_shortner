class ShortendUrl < ActiveRecord::Base
  require 'mechanize'

  UNIQUE_ID_LENGTH= 10
  validates :original_url, presence: true, on: :create
  validates_format_of :original_url, :with => URI::regexp(%w(http https))
  before_create :generate_short_url
  before_create :sanitize

  # adds the creator relationship for the url generator
  belongs_to :creator, :class_name => 'User'

  # defines relation between url and associated user
  has_and_belongs_to_many :users

  # generator to generate the short url
  def generate_short_url
    url = ([*('a'..'z'), *('0'..'9')]).sample(UNIQUE_ID_LENGTH).join
    old_url = ShortendUrl.where(short_url: url).last

    # get the page title whose short url is being created
    get_set_url_title

    if old_url.present?
      self.generate_short_url
    else
      self.short_url = url
    end
  end

  # finds the dulicate url in db
  def find_duplicate
    ShortendUrl.find_by_sanitize_url(self.sanitize_url)
  end

  # check if url is new url or a duplicated one
  def is_new_url?
    find_duplicate.nil?
  end

  # used to sanitize the url
  def sanitize
    self.original_url.strip!
    self.sanitize_url = self.original_url.downcase.gsub(/(http?:\/\/)|(https?:\/\/)|(www\.)/, '')
    self.sanitize_url = "http://#{self.sanitize_url}"
  end

  # fetch the url page title so that it can be used in stats for categorization
  def get_set_url_title
    self.original_url.strip!
    begin
      # tries to fetch the relevant information from the page; for now only title is being stored.
      # TODO: may include the category of the page
      self.page_title = Mechanize.new.get(self.original_url.strip).title
    rescue Exception => e
      my_logger.info("failed to get title for #{self.original_url} because of exception: '#{e}'")
      self.page_title = ''
    end
  end

  # fetch user details which could be a creator or a consumer of a url
  def add_user_details(request, alter_count=false, is_creator=false)
    begin
      # finds the user in the available list so that association can be meant.
      @user = User.find_by_ip(request.ip)

      # increment the counter to 1 if user is returning user or other guest user tries to access the short url
      (self.hits += 1) if alter_count

      # if user not found in records create the new one
      @user ||= User.create(
          name: "guest_#{request.ip}",
          address: "#{request.location.address}",
          city: "#{request.location.city}",
          state: "#{request.location.state}",
          state_code: "#{request.location.state_code}",
          country: "#{request.location.country}",
          country_code: "#{request.location.country_code}",
          postal_code: "#{request.location.postal_code}",
          metro_code: "#{request.location.metro_code}",
          ip: "#{request.ip}",
          coordinates: "#{request.location.coordinates}",
          latitude: "#{request.location.latitude}",
          longitude: "#{request.location.longitude}",
          province: "#{request.location.province}",
          province_code: "#{request.location.province_code}",
          browser: "#{request.env['HTTP_USER_AGENT']}"
      )

      # sets the creator of the url
      self.creator_id = @user.id if is_creator

      # adds the user to list who is accessing the url
      users << @user
      save
    rescue Exception => e
      my_logger('geocoder').info("failed to create user for #{self.original_url} because of exception: '#{e}'")
    end
  end

  # generic query builder
  def self.build_condition_arr(params ,condition_container, condition_value_container, join_table=nil)
    params.each do |k,v|
      condition_container.push("#{join_table ? (join_table+'.') : ''} #{k} LIKE CONCAT('%',?,'%')")
      condition_value_container.push(v)
    end
  end

  # creates the error logger file for different type of external services
  def my_logger(experiment='mechanize')
    # sets the log file path.
    file_url = "#{Rails.root}/log/#{experiment}_error.log"

    # checks the existence of file
    # if not found then create it.
    unless File.exist?(file_url)
      # creates a file #{experiment_name}_optimzely.log
      f = File.open(file_url, "a")
      f.close
    end
    begin
      # tries to get the class distinct class variable for experiment.
      container = ShortendUrl.class_variable_get(:"@@#{experiment}")
    rescue Exception => e
      # inits the class variable for experiment for write operation.
      container = ShortendUrl.class_variable_set(:"@@#{experiment}", Logger.new(file_url))
    end
    container
  end
end
