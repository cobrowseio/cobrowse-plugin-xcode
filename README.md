# Cobrowse.io - Xcode plugin

## Installation

### SPM

Use the URL below when adding the package dependecy.

```
https://github.com/cobrowseio/cobrowse-plugin-xcode.git
```

Do not add the `cbio` target to any of your own targets.

### Manual download

Download the binary from the [releases](https://github.com/cobrowseio/cobrowse-plugin-xcode/releases) page.

## Try it out

### Xcode Plugin

To use the Xcode plugin you must use the Swift Package rather than the manual download.

With the package added you can right mouse click on your app project in the project navigator and select **GenerateCobrowseSelectors**.

<img width="369" alt="xcode-plugin-1" src="https://github.com/user-attachments/assets/acedae93-bccc-468f-8026-4f5586e09395">

Select your targets you wish to use and click run.

Aruments can be passed by expanding the arguments section and clicking + to add a new argument.

<img width="532" alt="xcode-plugin-2" src="https://github.com/user-attachments/assets/6186fdbc-1948-4deb-9822-a345a8317990">

It will ask for permission to modify your files. This is needed in order for the selectors to be added in the correct places.

<img width="372" alt="xcode-plugin-3" src="https://github.com/user-attachments/assets/c9dfef16-b252-4bef-944e-2bf48fdac1ea">

### Command line

If using the Swift Package you can find the executable at the location where your packages are checked out. Usually `~/Library/Developer/Xcode/DerivedData` but you can choose where by using the `clonedSourcePackagesDirPath` parameter when using `xcodebuild`.

If you have manually downloaded the executable then you will already know of it's location.

You can then run `cbio generate selectors --source <PATH_TO_TARGET_FILES>`

## Questions?
Any questions at all? Please email us directly at [hello@cobrowse.io](mailto:hello@cobrowse.io).

## Requirements

* macOS 13+
