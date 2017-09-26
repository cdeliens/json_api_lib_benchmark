class PostResource < JSONAPI::Resource
  attributes :title, :body,
             :created_at, :updated_at

  has_one :user#, serializer: UserSerializer
  has_many :comments#, each_serializer: CommentSerializer
end
