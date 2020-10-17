# frozen_string_literal: true

module Forms
  CloneRepository = Struct.new :name, :password, :clone_url, keyword_init: true do
    def self.from_params params
      new(params.slice(*members.map(&:to_s)))
    end

    def to_forme(**opts)
      opts[:method] ||= :post

      Forme.form(self, **opts) do |f|
        f.input :name, type: :text, label: "Repository Name", required: true
        f.input :password, type: :password, label: "Admin Password"
        f.input :clone_url, type: :url, label: "Clone From URL", required: true

        yield f if block_given?

        f.button "Clone Repository"
      end
    end
  end
end
