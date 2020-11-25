# frozen_string_literal: true

class Cells::RepositoryInfo < Cells::Base
  def project_url
    "#{ CONFIG['domain'] }/user/#{ model[:username] }/repository/#{ model[:repository][:name] }"
  end
end
