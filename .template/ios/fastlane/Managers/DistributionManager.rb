# frozen_string_literal: true

class DistributionManager
  def initialize(fastlane:, build_path:)
    @fastlane = fastlane
    @build_path = build_path
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
end
