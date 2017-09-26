class CommentResource < JSONAPI::Resource
  attributes :author, :comment

  has_one :post
end
