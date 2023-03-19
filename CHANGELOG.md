# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0](https://github.com/aws-samples/terraform-aws-scheduled-switch/compare/v2.0.1...v3.0.0) (2023-03-19)


### ⚠ BREAKING CHANGES

* replace eventbridge rules with scheduler

### Features

* replace eventbridge rules with scheduler ([8f26433](https://github.com/aws-samples/terraform-aws-scheduled-switch/commit/8f26433c78826937da1def72d04422ce1c3247c6))

### [2.0.1](https://github.com/aws-samples/aws-terraform-scheduled-switch/compare/v2.0.0...v2.0.1) (2022-07-25)


### Bug Fixes

* added permission for version param ([1dae3e4](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/1dae3e499231727761db25f98381a9b3801550fa))

## [2.0.0](https://github.com/aws-samples/aws-terraform-scheduled-switch/compare/v1.1.0...v2.0.0) (2022-07-25)


### ⚠ BREAKING CHANGES

* refactored to use SSM instead of variables override
* added dependencies and use name_prefix
* removed target_id and added random suffix

### Features

* added dependencies and use name_prefix ([dae678b](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/dae678b370f53e52a9975d6c38418b00c955618a))
* refactored to use SSM instead of variables override ([82180de](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/82180de7eff0c3a089430097b852195d1c4ae2dd))
* removed target_id and added random suffix ([d9e024f](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/d9e024f87a88d8d6135095d3750c399dd143fccb))

## [1.1.0](https://github.com/aws-samples/aws-terraform-scheduled-switch/compare/v1.0.1...v1.1.0) (2022-07-20)


### Features

* parameterized codebuild role ([22d85bb](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/22d85bb3ca089756d35cd1081ec568e46cf5f574))

### [1.0.1](https://github.com/aws-samples/aws-terraform-scheduled-switch/compare/v1.0.0...v1.0.1) (2022-07-20)


### Bug Fixes

* name_prefix length ([1120c7d](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/1120c7ddf24e686b00d361e99a7532ea24519ad9))

## 1.0.0 (2022-07-09)


### Features

* Add MWAA example for scheduled switch module ([2042e5c](https://github.com/aws-samples/aws-terraform-scheduled-switch/commit/2042e5c16977a6aa3f70a5817dcbdb3054d09149))
