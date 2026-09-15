APP_NAME    := AULA Studio
PRODUCT     := AULAStudio
BUNDLE_ID   := app.aulastudio.AULAStudio
BUILD_DIR   := build
APP_BUNDLE  := $(BUILD_DIR)/$(APP_NAME).app
CONFIG      ?= release

# Command Line Tools (without Xcode) don't ship the SwiftUI macro plugins that
# macOS 27 SDK needs for @State. Build against the 26 SDK in that case.
# With full Xcode selected, the default SDK is used.
# The swift-testing macro plugin also has to be passed explicitly there.
TEST_FLAGS :=
ifneq ($(findstring CommandLineTools,$(shell xcode-select -p 2>/dev/null)),)
  CLT_SDK := /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
  ifneq ($(wildcard $(CLT_SDK)),)
    export SDKROOT := $(CLT_SDK)
  endif
  TEST_FLAGS := -Xswiftc -plugin-path -Xswiftc /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
endif

.PHONY: help build test run app open dmg icon endpoints keys clean

help:
	@echo "make build      Build all targets ($(CONFIG))"
	@echo "make test       Run unit tests"
	@echo "make app        Package $(APP_BUNDLE)"
	@echo "make open       Package and launch the app"
	@echo "make dmg        Build a shareable universal DMG in dist/ (SIGN_IDENTITY / NOTARY_PROFILE optional)"
	@echo "make icon       Regenerate Support/AppIcon.icns"
	@echo "make run        Run the app unbundled (fast dev loop)"
	@echo "make endpoints  List the keyboard's HID interfaces"
	@echo "make keys       Stream live key events from the keyboard"
	@echo "make clean      Remove build products"

build:
	swift build -c $(CONFIG)

test:
	swift test $(TEST_FLAGS)

run:
	swift run $(PRODUCT)

endpoints:
	swift run aulactl endpoints

keys:
	swift run aulactl keys

app: build
	@rm -rf "$(APP_BUNDLE)"
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS" "$(APP_BUNDLE)/Contents/Resources"
	@cp "$$(swift build -c $(CONFIG) --show-bin-path)/$(PRODUCT)" "$(APP_BUNDLE)/Contents/MacOS/$(PRODUCT)"
	@sed -e 's/$$(BUNDLE_ID)/$(BUNDLE_ID)/' Support/Info.plist > "$(APP_BUNDLE)/Contents/Info.plist"
	@cp Support/AppIcon.icns "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns"
	@codesign --force --sign - "$(APP_BUNDLE)"
	@echo "Built $(APP_BUNDLE)"

open: app
	open "$(APP_BUNDLE)"

dmg:
	Scripts/package.sh

icon:
	swift Scripts/make-icon.swift Support/AppIcon.icns

clean:
	rm -rf .build $(BUILD_DIR) dist
