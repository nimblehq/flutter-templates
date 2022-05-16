class Environments
  def self.CI
    ENV['CI']
  end

  def self.MANUAL_VERSION
    ENV['MANUAL_VERSION']
  end

  def self.FASTLANE_USER
    ENV['FASTLANE_USER']
  end

  def self.TEAM_ID
    ENV['TEAM_ID']
  end
end
