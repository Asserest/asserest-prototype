# Command-line tools for testing accessibility of URL address.

This program will be simply tested the given URL can be access or not in corresponded network
as assertion.

## Supported URL schemes

* HTTP (Based on [http](https://pub.dev/packages/http) package)
    * Includes HTTPS
* FTP (Based on [ftpconnect](https://pub.dev/packages/ftpconnect))

## Usage

1. [Install](#install)
1. [Create YAML script](#create-yaml-script)
1. [Assertion](#assertion)

#### Install

Simply go to [release page](https://github.com/rk0cc/asserest/releases) to get the latest version of Asserest.
Then, unzip archive to your ideal install location and good to go.

Optionally, you can set path environment variable to avoid typing with directory location.

#### Create YAML script

Create a YAML file for specify assertion of URL and remember the file's path as arguements.
The configuration should be like this:

```yaml
# Define accessible on this URL
- url: https://www.example.com
  accessible: true
  try_count: 1 # Mandatory field for expected accessible URL
  method: GET

# Define inaccessible on this URL
- url: http://www.example.com
  accessible: false
  # DO NOT define try_count in expected inaccessible assertion
  method: GET
```

If you are using Visual Studio Code or other IDEs which support JSON schema, it is recommended to
[bind the schema](schema/README.md) in IDEs settings for full support.

#### Assertion

Enter this command:

```bash
asserest path/to/script.yaml
```

For Linux users, if unable to execute, please assign execute permission first:

```bash
chmod +x asserest
```

## System requirements

All provided binaries are 64-bit only, no 32-bit version provided.

There is no pre-build binary for macOS since it is **impossible to target Apple
Silicon** which prefer to running natively instead of emulation on Rosetta 2
that may possibility causing performance dropped.

* Binary (AMD64) available in [release](https://github.com/rk0cc/asserest/releases)
    * Windows 10 or later
    * Linux
* Can be built by yourself
    * Windows 10 or later
    * Linux
    * macOS 11 or later

## Build

Building Asserest requires [Dart SDK](https://dart.dev/get-dart)
(or [Flutter](https://docs.flutter.dev/get-started/install)) installed
already in your computer.

When Dart SDK installed, set the location of `bin` folders in path environment
variable. Then, run this command:

```bash
git clone https://github.com/rk0cc/asserest.git

cd asserest

dart pub get

dart compile exe bin/asserest.dart
```

The compiled binary will be generated under `bin` directory.

## Import as library

Dart (or Flutter) allows import library from Git directly. In the project's `pubspec.yaml`,
you need to insert this property under `dependencies`:

```yaml
# Name, description and other mandatory stuff
dependencies:
  asserest:
    git:
      url: https://github.com/rk0cc/asserest.git
      ref: 1.0.0-beta.2 # It's better to uses tag's name.
# Additional settings (e.g. `flutter`)
```

Then, run `pub get` command if necessary.

### Alternative one shell script install for macOS and Linux

**You are required to install these tools before running script:**

* **wget**
* **git**

For UNIX based user (macOS and Linux), it can be compiled by a shell script file from:

```
https://raw.githubusercontent.com/rk0cc/asserest/main/asserest_unix_autobuild.sh
```

The binary `asserest` will be installed in your home directory already.

## License

* Under `bin` directory: MIT License
* Under `lib` directory: Apache 2.0 License
* Under `schema` directory: JSON License
