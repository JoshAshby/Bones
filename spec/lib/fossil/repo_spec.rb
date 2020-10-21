# frozen_string_literal: true

describe Fossil::Repo do
  let(:repo_path) { Pathname.new(__FILE__).parent.join("test.fossil") }
  subject { Fossil::Repo.new repo_path }

  let(:username) { "test-user" }

  def stub_failed_command exitstatus=1, &block
    process_status_mock = Minitest::Mock.new
    process_status_mock.expect :exitstatus, exitstatus
    process_status_mock.expect :success?, false

    subject.stub :run_fossil_command, process_status_mock, &block
  end

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
      stub_failed_command do
        expect { subject.create_repository username: "" }.must_raise Fossil::FossilCommandError
      end
    end
  end

  # Cloning is broken for me with my 2.12.1 version of Fossil from homebrew.
  # https://fossil-scm.org/forum/forumpost/469343699c?t=h It seems the fix
  # should be in 2.12 but I'm not 100% sure so I'll wait till 2.13 which is
  # pending release before trying these again
  describe "cloning repos" do
    let(:clonable_path) { repo_path.dirname.join("clone-base.fossil") }
    let(:clonable_repo) { Fossil::Repo.new clonable_path }

    before do
      skip "Cloning is currently broken on my Fossil 2.12.1 from homebrew"
      clonable_repo.create_repository username: username
    end

    after do
      FileUtils.remove_file repo_path, true
      FileUtils.remove_file clonable_path, true
    end

    it "clones a repo" do
      expect(subject.clone_repository(url: "file://#{ clonable_path }", username: username)).must_be_nil
    end

    it "raises a dup repo error" do
      subject.create_repository username: username
      expect do
        subject.clone_repository(url: "file://#{ clonable_path }", username: username)
      end.must_raise Fossil::ExistingRepositoryError
    end

    it "raises a command error when failed" do
      expect { subject.clone_repository(url: "file:///", username: username) }.must_raise Fossil::FossilCommandError
    end
  end

  describe "deleting repositories" do
    it "deletes a repo" do
      expect(subject.create_repository(username: username)).must_be_nil
      expect(subject.delete_repository!).must_equal 1 # 1 file removed
    end
  end

  describe "editing a repository" do
    before do
      subject.create_repository username: username
    end

    after do
      FileUtils.remove_file repo_path
    end

    it "creates a user" do
      password = "testing"
      expect(subject.create_user(username: "test-1", contact_info: "bones user", password: password))
        .must_equal password
    end

    it "creates a user with a random password when not given" do
      expect(subject.create_user(username: "test-1", contact_info: "bones user")).wont_be_nil
    end

    it "raises a command error when creating a user fails" do
      expect do
        subject.create_user(username: username, contact_info: "bones user")
      end.must_raise Fossil::FossilCommandError
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

    it "raises a command error when changing the password fails" do
      expect { subject.change_password(username: "") }.must_raise Fossil::FossilCommandError
    end
  end
end
