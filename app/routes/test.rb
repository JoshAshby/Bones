# frozen_string_literal: true

class Routes::Test < Routes::Base
  route do |r|
    set_layout_options template: :layout_logged_in

    r.on "flash" do
      flash.now[:notice] = "Hello"
      flash.now[:info] = "Hi"
      flash.now[:warn] = "Allo"
      flash.now[:alert] = "Hello!!"

      view "test/flash"
    end

    r.root { view "test/index" }
  end
end
