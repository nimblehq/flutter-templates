# Deployment Process

## For Android

### Guide

- Before publishing the Android application, we have to prepare the necessary credentials and information:
  - A Play Store developer account.
  - Your application's app id. This could be multiple bundle ids according to the number of application’s flavors.
  - A new app on Play Store.

- Add these variables as the secrets of CI:
  - **ENV**: the production .env configuration file content.
  - **GOOGLE_PLAY_SERVICE_ACCOUNT_JSON**: the json file content of the Play Store's Service Account for app publishing. Please check out [how to create the Service Account](https://support.staffbase.com/hc/en-us/articles/360018569579-Preparing-Automated-Publishing-for-Google-Play-Store).

### Resources

- [Build and release an Android app](https://docs.flutter.dev/deployment/android#build-an-apk).
- [Preparing Automated Publishing for Google Play Store](https://support.staffbase.com/hc/en-us/articles/360018569579-Preparing-Automated-Publishing-for-Google-Play-Store).

## For iOS

### Guide

- Before publishing the iOS application, we have to prepare the necessary credentials and information:

    - An Apple developer account.
    - Your application’s bundle id. This could be multiple bundle ids according to the number of application’s flavors.
    - A new app on Apple Store Connect that links to the bundle id.
    - The access to Git’s [Match repository](https://codesigning.guide/).

- Create certificates for distribution and [code signing](https://codesigning.guide/) so we are able to fetch the certificates through the [Match](https://docs.fastlane.tools/actions/match/) repository.
- Set up [Fastlane](https://docs.fastlane.tools/getting-started/ios/setup/) and [Match](https://docs.fastlane.tools/actions/match/).
- Add these variables as the secrets of CI:

    - **FASTLANE_USER**: This will be referred to in `Appfile` and `Fastfile`. Set your Apple ID to this variable.
    - **FASTLANE_PASSWORD**: This variable will be referred to internally in Fastlane. Set the password of your Apple ID to this variable.
    - **FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD**: We need to generate an `application specific password` to upload your app to TestFlight. Reference [here](https://support.apple.com/en-us/HT204397).
    - **FASTLANE_SESSION**: When your Apple ID has Two-Factor Authentication or Two-Step verification information, we can’t validate your Apple ID with a prompt on your CI machine. We need to generate a login session for Apple ID in advance with `spaceauth`. Please check `Method 2: Two-step or two-factor authentication` in [here](https://docs.fastlane.tools/getting-started/ios/authentication/) to get the fastlane session and read the note in `Important note about session duration`.
    - **MATCH_PASSWORD**: This will be referred to internally in `fastlane match` to decrypt your profiles. We can get the password from the one who has Admin access in Apple Store Connect.
    - **KEYCHAIN_PASSWORD**: We can create a keychain password for ourself and it could be anything.
    - **SSH_PRIVATE_KEY**: In order to fetch the distribution files from Git’s [Match repository](https://codesigning.guide/), we have to generate an SSH key and save it as the environment variable in CI.
  
- Run the corresponding workflows or `fastlane` commands and enjoy the result!

### Resources

- [https://medium.com/flutter-community/deploying-flutter-ios-apps-with-fastlane-and-github-actions-2e87465e056e](https://medium.com/flutter-community/deploying-flutter-ios-apps-with-fastlane-and-github-actions-2e87465e056e)
- [https://docs.flutter.dev/deployment/cd](https://docs.flutter.dev/deployment/cd)
- [https://jaysavsani07.medium.com/flutter-ci-cd-with-github-actions-fastlane-part-2-ios-a4b281921d39](https://jaysavsani07.medium.com/flutter-ci-cd-with-github-actions-fastlane-part-2-ios-a4b281921d39)
