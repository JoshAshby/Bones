# frozen_string_literal: true

describe Fossil::Repo do
  def stub_failed_command exitstatus=1
    result_double = instance_double(Fossil::CmdResult)
    allow(result_double).to receive(:exitstatus).and_return exitstatus
    allow(result_double).to receive(:success?).and_return false

    allow(Fossil).to receive(:run_command).and_return result_double
  end

  let(:path) { Pathname.new(__FILE__).parent.join("test.fossil") }

  after do
    FileUtils.remove_file path if path.exist?
  end

  describe ".create" do
    let(:username) { "test-user" }

    it "makes a new repo" do
      res = described_class.create path, username: username

      expect(res).to be_an_instance_of described_class
      expect(res.path).to exist
    end

    it "raises existing repo error on dup repo" do
      expect(described_class.create(path, username: username)).to be_an_instance_of described_class
      expect { described_class.create path, username: username }.to raise_error Fossil::ExistingRepositoryError
    end

    it "raises command error when unsuccessful" do
      stub_failed_command
      expect { described_class.create path, username: "" }.to raise_error Fossil::FossilCommandError
    end
  end

  # Cloning is broken for me with my 2.12.1 version of Fossil from homebrew.
  # https://fossil-scm.org/forum/forumpost/469343699c?t=h It seems the fix
  # should be in 2.12 but I'm not 100% sure so I'll wait till 2.13 which is
  # pending release before trying these again
  xdescribe ".clone", skip: "Cloning is currently broken on my Fossil 2.12.1 from homebrew" do
    let(:cloned_path) { path.dirname.join("clone.fossil") }
    let(:username) { "test-user" }

    before do
      described_class.create path, username: username
    end

    after do
      FileUtils.remove_file cloned_path if cloned_path.exist?
    end

    it "clones a repo" do
      expect(described_class.clone(cloned_path, url: "file://#{ path }", username: username)).to be_nil
    end

    it "raises a dup repo error" do
      expect do
        described_class.clone(path, url: "file://#{ path }", username: username)
      end.to raise_error Fossil::ExistingRepositoryError
    end

    it "raises a command error when failed" do
      expect { described_class.clone(url: "file:///", username: username) }.to raise_error Fossil::FossilCommandError
    end
  end

  describe "#delete!" do
    subject(:deleted_repo) { described_class.create(path, username: username) }

    let(:username) { "test-user" }

    it "deletes a repo" do
      expect(deleted_repo.delete!).to be_truthy
    end
  end

  describe "editing a repository" do
    subject(:created_repo) { described_class.create path, username: username }

    let(:username) { "test-user" }
    let(:password) { "testing" }

    it "creates a setup user" do
      expect(created_repo.create_setup_user(username: "test-1", contact_info: "bones user", password: password))
        .not_to be_nil
    end

    it "fails creating a setup user with an empty password" do
      expect do
        created_repo.create_setup_user(username: "test-1", contact_info: "bones user", password: "")
      end.to raise_error ArgumentError
    end

    it "raises a command error when creating a setup user fails" do
      stub_failed_command
      expect do
        created_repo.create_setup_user(username: username, contact_info: "bones user", password: "test")
      end.to raise_error Fossil::FossilCommandError
    end

    it "changes the password when given" do
      expect(created_repo.change_password(username: username, password: password)).not_to be_nil
    end

    it "fails with an empty password" do
      expect { created_repo.change_password(username: username, password: "") }.to raise_error ArgumentError
    end

    it "raises a command error when changing the password fails" do
      stub_failed_command
      expect { created_repo.change_password(username: "", password: "test") }.to raise_error Fossil::FossilCommandError
    end
  end
end
