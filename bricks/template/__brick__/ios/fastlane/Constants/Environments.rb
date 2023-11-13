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

  def self.APP_STORE_KEY_ID
    ENV['APP_STORE_KEY_ID']
  end

  def self.APP_STORE_ISSUER_ID
    ENV['APP_STORE_ISSUER_ID']
  end

  def self.APP_STORE_CONNECT_API_KEY_BASE64
    ENV['APP_STORE_CONNECT_API_KEY_BASE64']
  end

  #################
  ### Firebase ###
  #################

  def self.FIREBASE_CLI_TOKEN
    ENV['FIREBASE_CLI_TOKEN']
  end

  def self.FIREBASE_APP_ID
    ENV['FIREBASE_APP_ID']
  end

  def self.FIREBASE_TESTER_GROUPS
    ENV['FIREBASE_DISTRIBUTION_TESTER_GROUPS']
  end

  def self.GITHUB_RUN_NUMBER
    ENV['GITHUB_RUN_NUMBER']
  end

  def self.RELEASE_NOTE_CONTENT
    ENV['RELEASE_NOTE_CONTENT']
  end
end
