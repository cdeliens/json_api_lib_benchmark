module BenchHelper
  module_function

  def clear_data
    Comment.delete_all
    Post.delete_all
    User.delete_all
  end

  def seed_data
    data_config = {
      comments_per_post: 2,
      posts: 20
    }

    u = User.create(first_name: 'Diana', last_name: 'Prince', birthday: 3000.years.ago)

    data_config[:posts].times do
      p = Post.create(user_id: u.id, title: 'Some Post', body: 'awesome content')
      data_config[:comments_per_post].times do
        Comment.create(author: 'me', comment: 'nice blog', post_id: p.id)
      end
    end
  end

  def print_render(render_gem)
    fname = "#{render_gem}_output.json"
    file = File.open(fname, "w")
    file.puts test_render(render_gem).to_json
    file.close
  end

  def test_render(render_gem)
    render_data(
      User.first,
      render_gem
    )
  end

  def test_manual_eagerload(render_gem)
    render_data(
      # User.auto_include(false).includes(posts: [:comments]).first,
      User.includes(posts: [:comments]).first,
      render_gem
    )
  end

  def render_data(data, render_gem)
    return render_with_ams(data) if render_gem == :ams
    return render_with_jsonapi_rb(data) if render_gem == :jsonapi_rb
    return render_with_jsonapi_jr(data) if render_gem == :jsonapi_jr
  end

  def render_with_ams(data)
    ActiveModelSerializers::SerializableResource.new(
      data,
      include: 'posts.comments',
      # fields: params[:fields],
      adapter: :json_api
    ).as_json
  end

  def render_with_jsonapi_rb(data)
    renderer = JSONAPI::Serializable::Renderer.new
    renderer.render(data,
      relationships: 'posts.comments',
      class: { Post: SerializablePost, User: SerializableUser,
              Comment: SerializableComment },
      include: [posts: [:comments]],
    )
  end

  def render_with_jsonapi_jr(data)
    include_resources = ['posts','posts.comments']
    JSONAPI::ResourceSerializer.new(UserResource, include: include_resources).serialize_to_hash(UserResource.new(data, nil))
  end
end
