# Contributing

Thanks for helping. Bug reports, testing on other keyboards, and pull requests are all welcome.

## Getting started

```sh
git clone https://github.com/mohin7/aula-f75max.git
cd aula-f75max
make test    # unit tests
make run     # launch the app
```

No keyboard? Use `AULA_DEMO=1 make run`.

## Pull requests

- Keep each PR focused on one change, and describe what you tested (unit tests, and on which keyboard and firmware, if relevant).
- Match the surrounding code style. `make test` must pass.
- Every new keyboard command needs a packet builder in `AulaKit/Protocol` with golden-byte tests, and it must be verified on real hardware before release.

## Legal ground rules

To keep the project safe for everyone:

- **Don't commit vendor files.** No AULA or Epomaker drivers, firmware, installers, images, GIFs or other assets.
- **Don't commit decompiled or copied code** from any vendor software. Contribute protocol facts (IDs, byte layouts, timings) that you've confirmed on hardware you own, written in your own words and code.
- **Credit your sources.** If you build on another open-source project, say so and respect its license.
- **No secrets.** Never commit certificates, Apple Developer credentials, tokens or personal data (serial numbers, Bluetooth addresses).
- **Don't flash firmware.** Code that writes firmware or bootloader regions won't be accepted.

By contributing, you agree your contribution is licensed under the project's [MIT License](LICENSE).
