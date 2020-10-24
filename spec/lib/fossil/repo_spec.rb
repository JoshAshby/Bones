# frozen_string_literal: true

describe Fossil::Repo do
  def stub_failed_command exitstatus=1, &block
    result_mock = Minitest::Mock.new Fossil::CmdResult.new nil, ""
    result_mock.expect :exitstatus, exitstatus
    result_mock.expect :exitstatus, exitstatus
    result_mock.expect :success?, false

    Fossil.stub :run_command, result_mock, &block
  end

  let(:username) { "test-user" }
  let(:path) { Pathname.new(__FILE__).parent.join("test.fossil") }

  after do
    FileUtils.remove_file path if path.exist?
  end

  describe ".create" do
    subject { Fossil::Repo }

    it "makes a new repo" do
      res = subject.create path, username: username

      expect(res).must_be_instance_of Fossil::Repo
      expect(res.path).path_must_exist
    end

    it "raises existing repo error on dup repo" do
      expect(subject.create(path, username: username)).must_be_instance_of Fossil::Repo
      expect { subject.create path, username: username }.must_raise Fossil::ExistingRepositoryError
    end

    it "raises command error when unsuccessful" do
      stub_failed_command do
        expect { subject.create path, username: "" }.must_raise Fossil::FossilCommandError
      end
    end
  end

  # Cloning is broken for me with my 2.12.1 version of Fossil from homebrew.
  # https://fossil-scm.org/forum/forumpost/469343699c?t=h It seems the fix
  # should be in 2.12 but I'm not 100% sure so I'll wait till 2.13 which is
  # pending release before trying these again
  describe ".clone" do
    let(:cloned_path) { repo_path.dirname.join("clone.fossil") }

    subject { Fossil::Repo }

    before do
      skip "Cloning is currently broken on my Fossil 2.12.1 from homebrew"
      subject.create path username: username
    end

    after do
      FileUtils.remove_file cloned_path if cloned_path.exist?
    end

    it "clones a repo" do
      expect(subject.clone(cloned_path, url: "file://#{ path }", username: username)).must_be_nil
    end

    it "raises a dup repo error" do
      expect do
        subject.clone(path, url: "file://#{ path }", username: username)
      end.must_raise Fossil::ExistingRepositoryError
    end

    it "raises a command error when failed" do
      expect { subject.clone(url: "file:///", username: username) }.must_raise Fossil::FossilCommandError
    end
  end

  describe "#delete!" do
    subject { Fossil::Repo.create(path, username: username) }

    it "deletes a repo" do
      expect(subject.delete!)
    end
  end

  describe "editing a repository" do
    subject { Fossil::Repo.create path, username: username }

    it "creates a setup user" do
      password = "testing"
      expect(subject.create_setup_user(username: "test-1", contact_info: "bones user", password: password))
        .wont_be_nil
    end

    it "fails creating a setup user with an empty password" do
      expect do
        subject.create_setup_user(username: "test-1", contact_info: "bones user", password: "")
      end.must_raise ArgumentError
    end

    it "raises a command error when creating a setup user fails" do
      stub_failed_command do
        expect do
          subject.create_setup_user(username: username, contact_info: "bones user", password: "test")
        end.must_raise Fossil::FossilCommandError
      end
    end

    it "changes the password when given" do
      password = "testing"
      expect(subject.change_password(username: username, password: password)).wont_be_nil
    end

    it "fails with an empty password" do
      expect { subject.change_password(username: username, password: "") }.must_raise ArgumentError
    end

    it "raises a command error when changing the password fails" do
      stub_failed_command do
        expect { subject.change_password(username: "", password: "test") }.must_raise Fossil::FossilCommandError
      end
    end
  end
end
