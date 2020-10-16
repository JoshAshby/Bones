# frozen_string_literal: true

class Routes::User < Routes::Base
  route do |r|
    r.root do
      binding.irb
      view "user/index"
    end
  end
end
