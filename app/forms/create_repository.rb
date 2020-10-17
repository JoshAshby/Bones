# frozen_string_literal: true

module Forms
  CreateRepository = Struct.new :name, :password, :project_name, keyword_init: true do
    def self.from_params params
      new(params.slice(*members.map(&:to_s)))
    end

    def to_forme(**opts)
      opts[:method] ||= :post

      Forme.form(self, **opts) do |f|
        f.input :name, type: :text, label: "Repository Name", required: true
        f.input :password, type: :password, label: "Admin Password"

        f.input :project_name, type: :text, label: "Project Name"

        yield f if block_given?

        f.button "Create Repository"
      end
    end
  end
end
