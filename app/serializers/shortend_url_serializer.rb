class ShortendUrlSerializer < ActiveModel::Serializer
  attributes :id, :original_url, :short_url, :sanitize_url, :page_title, :hits, :created_at, :updated_at, :creator, :users

  # serialize the creator object
  def creator
    UserSerializer.new(object.creator)
  end

  # add list of associated users to the object
  def users
    object.users.uniq.each do |user|
      UserSerializer.new(user)
    end
  end
end