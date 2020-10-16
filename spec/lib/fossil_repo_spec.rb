# frozen_string_literal: true

require_relative "../spec_helper"

describe FossilRepo do
  after do
    FileUtils.remove_dir FossilRepo.root, true
  end

  let(:fossil) { FossilRepo.new username: "test", repo: "test" }

  it "makes the user dir on creation" do
    assert fossil.repo_root.exist?
  end

  it "makes a new fossil repo" do
    assert 0, fossil.create_repository!
    assert fossil.repository_file.exist?
  end

  it "throws making a dup fossil repo" do
    assert 0, fossil.create_repository!
    assert_raises(RuntimeError) { fossil.create_repository! }
  end
end
