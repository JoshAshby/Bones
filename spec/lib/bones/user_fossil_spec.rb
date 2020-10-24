# frozen_string_literal: true

describe Bones::UserFossil do
  let(:username) { "test" }

  subject { Bones::UserFossil.new username }

  describe "creating repositories" do
    let(:repo_name) { "test" }

    before do
      skip "Bones::UserFossil needs some refactor to allow better stubbing of the directories before tests are easy to pull off"
    end

    after do
      subject.repository(repo_name).tap do |repo|
        next unless repo.path.exist?

        repo.delete!
      end
    end

    it "doesn't set the project code when nil" do
      expect(subject.create_repository(repo_name, project_code: nil)).wont_be_nil

      subject.repository(repo_name).repository_db do |db|
        val = db[:config].where(name: "project-code").get(:value)

        expect(val).wont_be_nil
        expect(val).wont_be_empty
      end
    end

    it "doesn't set the project code when empty" do
      expect(subject.create_repository(repo_name, project_code: "")).wont_be_nil

      subject.repository(repo_name).repository_db do |db|
        val = db[:config].where(name: "project-code").get(:value)

        expect(val).wont_be_nil
        expect(val).wont_be_empty
      end
    end
  end
end
