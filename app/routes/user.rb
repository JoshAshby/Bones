# frozen_string_literal: true

class Routes::User < Routes::Base
  route do |r|
    r.root do
      view "user/index"
    end
  end
end
