require "minitest/autorun"
require "env"

class TestFossilRepo < Minitest::Test
  def setup
    @fossil = FossilRepo.new "test"
  end

  def teardown
    FileUtils.remove_dir FossilRepo.root, true
  end

  def test_that_dir_is_made
    assert @fossil.repo_root.exist?
  end

  def test_that_will_be_skipped
    skip "test this later"
  end
end
