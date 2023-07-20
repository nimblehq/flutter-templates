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

  #################
  ### Firebase ###
  #################

  def self.FIREBASE_CLI_TOKEN
    ENV['FIREBASE_CLI_TOKEN']
  end

  def self.FIREBASE_APP_ID_STAGING
    ENV['FIREBASE_APP_ID_STAGING']
  end

  def self.FIREBASE_TESTER_GROUPS
    ENV['FIREBASE_DISTRIBUTION_TESTER_GROUPS']
  end
end
