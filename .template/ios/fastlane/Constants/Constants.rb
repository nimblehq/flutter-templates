# frozen_string_literal: true

class Constants
  #################
  #### PROJECT ####
  #################

  # Workspace path
  def self.WORKSPACE_PATH
    './Runner.xcworkspace'
  end

  # Project path
  def self.PROJECT_PATH
    './Runner.xcodeproj'
  end

  # bundle ID for Staging app
  def self.BUNDLE_ID_STAGING
    'co.nimblehq.flutter.template.staging'
  end

  # bundle ID for Production app
  def self.BUNDLE_ID_PRODUCTION
    'co.nimblehq.flutter.template'
  end

  #################
  #### BUILDING ###
  #################

  # a derived data path
  def self.DERIVED_DATA_PATH
    './DerivedData'
  end

  # a build path
  def self.BUILD_PATH
    './Build'
  end
  
  #################
  #### KEYCHAIN ####
  #################

  # Keychain name
  def self.KEYCHAIN_NAME
    'github_action_keychain'
  end

  def self.KEYCHAIN_PASSWORD
    'password'
  end

  #################
  ### ARCHIVING ###
  #################
  # an staging environment scheme name
  def self.SCHEME_NAME_STAGING
    'staging'
  end

  # a Production environment scheme name
  def self.SCHEME_NAME_PRODUCTION
    'production'
  end

  # an staging product name
  def self.PRODUCT_NAME_STAGING
    'Flutter Template Staging'
  end

  # a staging TestFlight product name
  def self.PRODUCT_NAME_STAGING_TEST_FLIGHT
    'Flutter Template Staging'
  end

  # a Production product name
  def self.PRODUCT_NAME_PRODUCTION
    'Flutter Template'
  end

  # a main target name
  def self.MAIN_TARGET_NAME
    'Flutter Template'
  end
end
