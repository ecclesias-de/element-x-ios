# ecclesias.Chat

## relevant documentation
* [CONTRIBUTING.md](CONTRIBUTING.md)
* [AGENTS.md](AGENTS.md) (Because i gues, documenation for humans is not that relavant...)

## Run
0. (`swift run tools setup-project` setup project dependecies. [CONTRIBUTING.md#setup-project](CONTRIBUTING.md#setup-project))
1. run `xcodegen`
2. open element x project with xcode (`./ElementX.xcodeproj/project.pbxproj`)
3. run app and test manualy: in xcode menue bar `Product > Run`

## Build
0. (`swift run tools setup-project` setup project dependecies. [CONTRIBUTING.md#setup-project](CONTRIBUTING.md#setup-project)) 
1. set `settings` `MARKETING_VERSION` in `project.yml`. The maketing version should follow this schema: `<element major version>.<element minor version>.<element patch version * 100 + ecclesias chat version counter>`. (Apple only allows 3 numbers seperated by dots as version)
2. run `xcodegen`, to update the xcode project with the marketing version
3. commit changes (project.yml und xcode project)
4. create a tag following this schema: `<element x tag>-0ecclesias<version counter>[-rc<release candidate counter>]`. The rc counter is not represented in the `MARKETING_VERSION`! Apps versions will only be distinguishable by upload datetime.
5. open element x project with xcode (`./ElementX.xcodeproj/project.pbxproj`)
6. let xcode build index
7. run app and test manualy: in xcode menue bar `Product > Run`
8. run unit tests: in xcode menue bar `Product > Test`
9. build app: in xcode menue bar `Product > Archive`
10. Push to app store: In the window openin when the build is done:
    1. click `Distribute App` button
    2. select `App Store Connect`
    3. click `Distrbute` button (todo: check if it works like thah)
11. Go to https://appstoreconnect.apple.com/apps/6503890817/distribution/ios/version/deliverable and release the new version

## Tests
Our own featues currently have no tests. They need to be tested manualy for now. Non the less we want to run unit test. To check if we have broken anything else.

Some media related test are failing for me. I have skipped them.

Skipping test: Test can be skipped in xcode by clicking there icon and exclude. Some xcode files change, they need to be commited.


# Original Element X README

[![Element iOS Matrix room #element-x-ios:matrix.org](https://img.shields.io/matrix/element-x-ios:matrix.org.svg?label=%23element-x-ios:matrix.org&logo=matrix&server_fqdn=matrix.org)](https://matrix.to/#/#element-x-ios:matrix.org)
![GitHub](https://img.shields.io/github/license/element-hq/element-x-ios)

![Build Status](https://img.shields.io/github/actions/workflow/status/element-hq/element-x-ios/unit_tests.yml?style=flat-square)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/element-hq/element-x-ios)

[![codecov](https://codecov.io/gh/element-hq/element-x-ios/branch/develop/graph/badge.svg?token=AVIJB2MJU2)](https://codecov.io/gh/element-hq/element-x-ios)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=element-x-ios&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=element-x-ios)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=element-x-ios&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=element-x-ios)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=element-x-ios&metric=bugs)](https://sonarcloud.io/summary/new_code?id=element-x-ios)

# Element X iOS

Element X iOS is the next-generation [Matrix](https://matrix.org/) client provided by [Element](https://element.io/).

Compared to the previous-generation [Element Classic](https://github.com/element-hq/element-ios), it is a total rewrite using the [Matrix Rust SDK](https://github.com/matrix-org/matrix-rust-sdk) underneath and targeting devices running iOS 17+.

## Rust SDK

Element X leverages the [Matrix Rust SDK](https://github.com/matrix-org/matrix-rust-sdk) through an FFI layer exposed as a [swift package](https://github.com/matrix-org/matrix-rust-components-swift) that the final client can directly import and use. We're doing this as a way to share code between platforms, with [Element X Android](https://github.com/element-hq/element-x-android) using the same SDK.

## Status

This project is actively developed and supported. New users are recommended to use Element X instead of the previous-generation app.

## Contributing

Please see our [contribution guide](CONTRIBUTING.md).

Come chat with the community in the dedicated Matrix [room](https://matrix.to/#/#element-x-ios:matrix.org).

## Build instructions

Please refer to the [setting up a development environment](CONTRIBUTING.md#setting-up-a-development-environment) section from the [contribution guide](CONTRIBUTING.md).

## Support

When you are experiencing an issue on Element X iOS, please first search in [GitHub issues](https://github.com/element-hq/element-x-ios/issues)
and then in [#element-x-ios:matrix.org](https://matrix.to/#/#element-x-ios:matrix.org).
If after your research you still have a question, ask at [#element-x-ios:matrix.org](https://matrix.to/#/#element-x-ios:matrix.org). Otherwise feel free to create a GitHub issue if you encounter a bug or a crash, by explaining clearly in detail what happened. You can also perform bug reporting (Rageshake) from the Element application by going to the application settings. This is especially recommended when you encounter a crash.

## Forking

Please read our [forking guide](docs/FORKING.md).

## Copyright & License

Copyright (c) 2025 Element Creations Ltd.
Copyright (c) 2022 - 2025 New Vector Ltd.

This software is dual licensed by Element Creations Ltd (Element). It can be used either:

(1) for free under the terms of the GNU Affero General Public License (as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version); OR

(2) under the terms of a paid-for Element Commercial License agreement between you and Element (the terms of which may vary depending on what you and Element have agreed to). 

Unless required by applicable law or agreed to in writing, software distributed under the Licenses is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the Licenses for the specific language governing permissions and limitations under the Licenses.
