# Aotearoa Tides

An app that displays tidal data using [the official LINZ tide
predictions](https://www.linz.govt.nz/sea/tides/tide-predictions). Currently,
the app is pending approval, but will soon be live on the
[play store.](https://play.google.com/store/apps/details?id=nz.kota.aotearoa_tides)
[Manual apk downloads](https://git.sr.ht/~kota/aotearoa_tides/refs/v1.0.0) are
also attached to each release.

<img src="https://paste.nilsu.org/e8438b6e252e3b7fc4e7bf8cd7e89f7d3a5fee24.png" width="350">

# Privacy

Uploading to the Google Play store requires a privacy policy. You can view the
current version in PRIVACY.md in this repository.

# Build

Aotearoa Tides is written in [Flutter](https://flutter.dev/) which is a cross
platform library for developing native Android or iOS apps. Currently, the app
is only tested on Android. To build it yourself install flutter, and the [android
development toolchain](https://developer.android.com/studio). You can use `flutter
doctor` to ensure your install is working properly.

Finally: `flutter build apk`

# Resources

Aotearoa Tides uses a public mailing list for contributions and discussion. You can
browse the list [here](https://lists.sr.ht/~kota/public-inbox) and
[email patches](https://git-send-email.io) or questions to
[~kota/public-inbox@lists.sr.ht](https://lists.sr.ht/~kota/public-inbox). The
project is licensed under the GPL3-or-later and contributions are welcome!
