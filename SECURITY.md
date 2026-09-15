# Security Policy

## Reporting a vulnerability

Please **don't open a public issue** for security problems.

Report them privately through GitHub: open the repository's **Security** tab and choose **Report a vulnerability**. You'll get a reply as soon as possible, and the fix is credited to you unless you'd rather stay anonymous.

## What AULA Studio does and doesn't do

AULA Studio is designed to keep its attack surface small:

- **No network access.** The app never connects to the internet: no analytics, no telemetry, no update checks and no accounts.
- **Nothing you type is recorded.** With Input Monitoring allowed, key presses from the AULA keyboard only drive the on-screen preview and Key Tester. They're never stored, logged or sent anywhere.
- **It only talks to known AULA devices.** HID commands go only to the F75 Max's USB IDs and vendor interfaces. Other devices are never written to.
- **It never updates firmware.** There's no firmware flashing and no bootloader access. The worst a command can do is change lighting, screen or keyboard settings, which you can change back.
- **Settings stay on your Mac**, in the app's standard preferences.
- **No third-party dependencies.** The project uses only Apple frameworks, so there are no packages to hijack.

## Developer tool warning

The `aulactl raw` command sends arbitrary bytes to the keyboard for protocol research. Only use it if you understand the protocol, and never paste raw commands from untrusted sources.

## Downloads

Only install AULA Studio from this repository's **Releases** page, and compare the file's SHA-256 checksum with the one listed in the release notes:

```sh
shasum -a 256 AULA-Studio-*.dmg
```
