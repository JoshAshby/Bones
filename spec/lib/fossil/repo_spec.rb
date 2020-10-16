# frozen_string_literal: true

require "spec_helper"

describe Fossil::Repo do
  after do
    FileUtils.remove_file repo_path
  end

  let(:repo_path) { Pathname.new(__FILE__).parent.join("test.fossil") }
  subject { Fossil::Repo.new repo_path }

  let(:username) { "test-user" }

  it "makes a new repo" do
    assert 0, subject.create_repository!(username)
    assert subject.repository_file.exist?
  end

  it "throws making a dup repo" do
    assert 0, subject.create_repository!(username)
    assert_raises(RuntimeError) { subject.create_repository! username }
  end
end
