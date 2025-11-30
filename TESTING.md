# Testing Guide

This project is a Swift library for iOS applications. Use the `xcodebuild` command-line tool to run tests.

## Prerequisites

1. Ensure Xcode is installed
2. Verify command line tools are configured:
   ```bash
   xcode-select --install
   ```

## Check Available Test Devices

To run tests on the latest iOS standard devices (such as iPhone 17), first check available simulators:

```bash
# Check available iPhone devices
xcrun simctl list devices available | grep "iPhone" | grep -v "Pro" | grep -v "Plus"
```

## Test Execution Steps

### 1. Check Available Schemes

First, identify the correct scheme name for this project:

```bash
# List available schemes
xcodebuild -list
```

### 2. Get Device ID

Obtain the ID for standard iPhone devices (with latest OS) such as iPhone 17:

```bash
# Get iPhone 17 device ID
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 17" | head -1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}')
echo "Device ID: $DEVICE_ID"
```

### 3. Build Project

```bash
# Build Swift package (replace SCHEME_NAME with the actual scheme from step 1)
xcodebuild -scheme SCHEME_NAME -destination "platform=iOS Simulator,id=$DEVICE_ID" build
```

### 4. Run Tests

```bash
# Execute tests (replace SCHEME_NAME with the actual scheme from step 1)
xcodebuild -scheme SCHEME_NAME -destination "platform=iOS Simulator,id=$DEVICE_ID" test
```

## Useful Command Examples

### One-liner Execution

```bash
# Get device ID and run tests in one command (replace SCHEME_NAME with actual scheme)
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 17" | head -1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}') && xcodebuild -scheme SCHEME_NAME -destination "platform=iOS Simulator,id=$DEVICE_ID" test
```

### Testing on Multiple Devices

```bash
# Test on iPhone 17 and iPhone 16 (replace SCHEME_NAME with actual scheme)
for device in "iPhone 17" "iPhone 16"; do
    DEVICE_ID=$(xcrun simctl list devices available | grep "$device" | head -1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}')
    echo "Testing on $device (ID: $DEVICE_ID)"
    xcodebuild -scheme SCHEME_NAME -destination "platform=iOS Simulator,id=$DEVICE_ID" test
done
```

## Troubleshooting

- If simulators are not found, download them in Xcode
- If build fails, check dependencies:
  ```bash
  swift package resolve
  ```
- If tests fail, check detailed logs:
  ```bash
  xcodebuild -scheme SCHEME_NAME -destination "platform=iOS Simulator,id=$DEVICE_ID" test -verbose
  ```

## Important Notes

- Prioritize standard iPhone devices (iPhone 17, iPhone 16, etc.)
- Use standard models rather than Pro, Plus, or Max variants for testing
- Use simulators with the latest iOS versions installed

