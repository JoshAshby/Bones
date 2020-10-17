# frozen_string_literal: true

module Forms
  CloneRepository = Struct.new :name, :password, :clone_url, keyword_init: true do
    def self.from_params params
      new(params.slice(*members.map(&:to_s)))
    end
  end
end
