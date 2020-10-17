# frozen_string_literal: true

module Forms
  CreateRepository = Struct.new :name, :password, :project_name, keyword_init: true do
    def self.from_params params
      new(params.slice(*members.map(&:to_s)))
    end
  end
end
