require 'rails/all'
Bundler.require(*Rails.groups)

ActiveRecord::Base.logger = nil
ActiveModelSerializers.logger = nil

require './support/rails'
require './support/bench_helper'

# AMS
require './support/serializers/user_serializer.rb'
require './support/serializers/post_serializer'
require './support/serializers/comment_serializer'
# jsonapi-rb
require 'jsonapi/serializable'
require './support/serializers/serializable_comment'
require './support/serializers/serializable_post'
require './support/serializers/serializable_user'
# jsonapi-resources
require './support/serializers/user_resource'
require './support/serializers/post_resource'
require './support/serializers/comment_resource'

GC.disable

%i[ips memory].each do |bench|
  BenchHelper.clear_data
  BenchHelper.seed_data

  Benchmark.send(bench) do |x|
    x.config(time: 10, warmup: 5, stats: :bootstrap, confidence: 95) if x.respond_to?(:config)

    x.report('ams                    ') { BenchHelper.test_render(:ams) }
    x.report('jsonapi-rb             ') { BenchHelper.test_render(:jsonapi_rb) }
    x.report('jsonapi-resources      ') { BenchHelper.test_render(:jsonapi_jr) }
    x.report('ams        eager       ') { BenchHelper.test_manual_eagerload(:ams) }
    x.report('jsonapi-rb eager       ') { BenchHelper.test_manual_eagerload(:jsonapi_rb) }
    x.report('jsonapi-resources eager') { BenchHelper.test_manual_eagerload(:jsonapi_jr) }

    x.compare!
  end
  BenchHelper.print_render(:ams)
  BenchHelper.print_render(:jsonapi_rb)
  BenchHelper.print_render(:jsonapi_jr)
end
