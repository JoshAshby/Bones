# frozen_string_literal: true

describe Fossil::Repo do
  let(:repo_path) { Pathname.new(__FILE__).parent.join("test.fossil") }
  subject { Fossil::Repo.new repo_path }

  let(:username) { "test-user" }

  describe "creating repos" do
    after do
      FileUtils.remove_file repo_path, true
    end

    it "makes a new repo" do
      expect(subject.create_repository(username: username)).must_be_nil
      expect subject.repository_file.exist?
    end

    it "throws making a dup repo" do
      expect(subject.create_repository(username: username)).must_be_nil
      expect { subject.create_repository username: username }.must_raise Fossil::ExistingRepositoryError
    end

    it "throws a command error when unsuccessful" do
      process_status_mock = Minitest::Mock.new
      process_status_mock.expect :exitstatus, 1
      process_status_mock.expect :success?, false

      subject.stub :run_fossil_command, process_status_mock do
        expect { subject.create_repository username: "asdf" }.must_raise Fossil::FossilCommandError
      end
    end
  end

  describe "cloning repos" do
    after do
      FileUtils.remove_file repo_path
    end
  end

  it "deletes a repo" do
    expect(subject.create_repository(username: username)).must_be_nil
    expect(subject.delete_repository!).must_equal 1 # 1 file removed
  end

  describe "editing a repository" do
    before do
      subject.create_repository username: username
    end

    after do
      FileUtils.remove_file repo_path
    end

    it "changes the password when given" do
      password = "testing"
      expect(subject.change_password(username: username, password: password)).must_equal password
    end

    it "changes the password to a generated one when nil" do
      expect(subject.change_password(username: username)).wont_be_empty
    end

    it "changes the password to a generated one when empty" do
      expect(subject.change_password(username: username, password: "")).wont_equal ""
    end
  end
end
