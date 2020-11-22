# frozen_string_literal: true

class Cells::RepositoryInfo < Cells::Base
  def project_url
    "#{ options[:domain] }/user/#{ options[:username] }/repository/#{ model[:name] }"
  end
end
