# frozen_string_literal: true

class DistributionManager
  def initialize(fastlane:, build_path:, firebase_token:)
    @fastlane = fastlane
    @build_path = build_path
    @firebase_token = firebase_token
  end

  def upload_to_testflight(product_name:, bundle_identifier:)
    @fastlane.pilot(
      ipa: "#{@build_path}/#{product_name}.ipa",
      app_identifier: bundle_identifier,
      notify_external_testers: false,
      skip_waiting_for_build_processing: true
    )
  end

  def upload_to_app_store_connect(product_name:, bundle_identifier:)
    @fastlane.deliver(
      ipa: "#{@build_path}/#{product_name}.ipa",
      app_identifier: bundle_identifier,
      force: true,
      skip_metadata: true,
      skip_screenshots: true,
      run_precheck_before_submit: false
    )
  end

  def upload_to_firebase(product_name:, firebase_app_id:, notes:, tester_groups:)
    ipa_path = "#{@build_path}/#{product_name}.ipa"
    @fastlane.firebase_app_distribution(
      app: firebase_app_id,
      ipa_path: ipa_path,
      groups: tester_groups,
      firebase_cli_token: @firebase_token,
      release_notes: notes
    )
  end
end
