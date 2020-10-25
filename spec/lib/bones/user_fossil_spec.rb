# frozen_string_literal: true

describe Bones::UserFossil do
  subject(:user_fossil) { described_class.new username }

  let(:username) { "test" }
  let(:repo_name) { "test" }

  before do
    user_fossil.ensure_fs!
  end

  after do
    next unless Bones.config.root_path.exist?

    FileUtils.remove_dir Bones.config.root_path
  end

  describe "#create_repository" do
    subject(:created_repo) { user_fossil.create_repository(repo_name, project_code: project_code) }

    let(:db_project_code) do
      user_fossil.repository(repo_name).repository_db do |db|
        db[:config].where(name: "project-code").get(:value)
      end
    end

    context "with a nil project code" do
      let(:project_code) { nil }

      it { expect(created_repo).not_to be_nil }

      it "isn't a nil project-code" do
        expect(created_repo).not_to be_nil
        expect(db_project_code).not_to be_nil
      end

      it "isn't an empty project-code" do
        expect(created_repo).not_to be_nil
        expect(db_project_code).not_to be_empty
      end
    end

    context "with an empty project code" do
      let(:project_code) { "" }

      it { expect(created_repo).not_to be_nil }

      it "isn't a nil project-code" do
        expect(created_repo).not_to be_nil
        expect(db_project_code).not_to be_nil
      end

      it "isn't an empty project-code" do
        expect(created_repo).not_to be_nil
        expect(db_project_code).not_to be_empty
      end
    end
  end
end
