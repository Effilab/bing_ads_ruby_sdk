## V1.6 Release
- Fixed an error not returning ad extension associations
- All error messages are now returned instead of just the first one
- Updated dependencies

## V1.6 Release
- Updated documentation
- Fixed an envkey/dotenv related bug preventing the gem from starting
- Dropped support for Ruby 2

## V1.5.1 Release
- Bug fix: Rake task missing

## V1.5.0 Release
- Breaking: Now raises functional errors
- Breaking: Now raises an error if not able to read the store in order to refresh the token

## V1.4.0 Release

- Breaking: change scope from `https://ads.microsoft.com/ads.manage` to `https://ads.microsoft.com/msads.manage` as requested by Bing (deadline March 22)

- now reading store at the very last moment to get freshest token

## V1.3.4 Release

- lift constraint on signet gem

## V1.3.1 Release

- add client secret in signatures

## V1.3.0 Release
Allow instrumentation of HTTP requests via ActiveSupport::Notifications

## V1.2.0 Release
Replaced Live connect auth with Microsoft Identity as it is now the default from Bing.

## V1.1.1 Release

- fix broken 1.1.0 which didnt bundle lib folder in gem release

## V1.1.0 Release

- Use bing api v13

- Bulk api v6


## V1.0.0 Release
The main reasons of the refactoring were to:

- add convenient methods returning structured data

- remove metaprogramming

- remove the dependency on an unmerged and unmaintained branch of the lolsoap gem


Alongside these key points, we now have:

- filtered logs

- split concerns

- strong specs suite

- a customizable configuration

- Use bing api v12

- Bulk api v6
