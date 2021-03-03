<h1 align="center">
	<a href="https://github.com/WolfSoftware">
		<img src="https://raw.githubusercontent.com/WolfSoftware/branding/master/images/general/banners/64/black-and-white.png" alt="Wolf Software Logo" />
	</a>
	<br>
	caretaker-core
</h1>

<p align="center">
	<a href="https://travis-ci.com/DevelopersToolbox/caretaker-core">
		<img src="https://img.shields.io/travis/com/DevelopersToolbox/caretaker-core/master?style=for-the-badge&logo=travis" alt="Build Status">
	</a>
	<a href="https://github.com/DevelopersToolbox/caretaker-core/releases/latest">
		<img src="https://img.shields.io/github/v/release/DevelopersToolbox/caretaker-core?color=blue&style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Release">
	</a>
	<a href="https://github.com/DevelopersToolbox/caretaker-core/releases/latest">
		<img src="https://img.shields.io/github/commits-since/DevelopersToolbox/caretaker-core/latest.svg?color=blue&style=for-the-badge&logo=github&logoColor=white" alt="Commits since release">
	</a>
	<a href="LICENSE.md">
		<img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" alt="Software License">
	</a>
	<br>
	<a href=".github/CODE_OF_CONDUCT.md">
		<img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/CONTRIBUTING.md">
		<img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/SECURITY.md">
		<img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
	<a href=".github/SUPPORT.md">
		<img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge&logo=read-the-docs&logoColor=white" />
	</a>
</p>

## Overview

caretaker Core is the brain that makes [Sonny](https://github.com/DevelopersToolbox/sonny) work, it processes the git log for a given repository and returns all of the required information as a single JSON object.

[Sonny](https://github.com/DevelopersToolbox/sonny) makes use of this object in order to dynamically build a CHANGELOG.md file for the given project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'caretaker-core'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install caretaker-core

## Usage

The following is a very [simple snippet](testing/get-raw.rb) showing how to integrate the core into your own code. The key is the single call to [caretakerCore.run](lib/caretaker-core.rb#L20).

```ruby
#!/usr/bin/env ruby

require 'json'
require 'caretaker-core'

begin
    results = caretakerCore.run
rescue StandardError => e
    puts e.message
    exit
end

puts JSON.pretty_generate(JSON.parse(results))
```

### Output

The output from [caretakerCore.run](lib/caretaker-core.rb#L20) is a JSON formatted object. In the case of an error it will raise a `StandardError`. 

The basic structure of the JSON is as follows:

```yaml
{
    "tags": [ ],
    "commits": {
        "chronological": { },
        "categorised": { },
    },
    "repo": {
        "url": "",
        "slug": ""
    }
}
```
* tags - An array of tag names, it will also include 'untagged' for all commits that are not part of a tag.
* commits - A hash with 2 elements
    * chronological - All commits in chronological order.
    * categorised - All commits split by category.
* repo - A hash with information relating to the repository
    * url - The full base url to the repo (e.g. https://github.com/DevelopersToolbox/caretaker-core)
    * slug - The github organisation / repository name (e.g. DevelopersToolbox/caretaker-core)

A more full example (Showing a single commit)

```yaml
{
    "tags": [
        "untagged"
    ],
    "commits": {
        "chronological": {
            "untagged": [
                {
                    "hash": "11781d3",
                    "hash_full": "11781d3cbdac68a003492fc0d318d402dd241579",
                    "subject": "The initial commit",
                    "extra": false,
                    "commit_type": "commit",
                    "category": "Uncategorised:",
                    "date": "2021-03-03"
                }
            ]
        },
        "categorised": {
            "untagged": {
                "New Features:": [ ],
                "Improvements:": [ ],
                "Bug Fixes:": [ ],
                "Security Fixes:": [ ],
                "Refactor:": [ ],
                "Style:": [ ],
                "Deprecated:": [ ],
                "Removed:": [ ],
                "Tests:": [ ],
                "Documentation:": [ ],
                "Chores:": [ ],
                "Experiments:": [ ],
                "Miscellaneous:": [ ],
                "Uncategorised:": [
                    {
                        "hash": "11781d3",
                        "hash_full": "11781d3cbdac68a003492fc0d318d402dd241579",
                        "subject": "The initial commit",
                        "extra": false,
                        "commit_type": "commit",
                        "category": "Uncategorised:",
                        "date": "2021-03-03"
                    }
                ],
                "Initial Commit:": [ ],
                "Skip:": [ ]
            }
        }
    },
    "repo": {
        "url": "https://github.com/DevelopersToolbox/caretaker-core",
        "slug": "DevelopersToolbox/caretaker-core"
    }
}
```

#### Other Values

| Name | Purpose | Possible Values |
| ---- | ------- | --------------- |
| hash | Stores the short hash for the commit. | 7 character hexidecimal string |
| hash_full | Stores the full hash for the commit. | 40 character hexodecimal string|
| commit_message | The commit message message. | Anything alphanumberic |
| child_commit_messages | The commit messages of any commits that form part of a pull/merge request | Anything alphanumberic or false |
| commit_type | The type of commit | pr or commit |
| category | The category the commit belongs to | [Category List](lib/caretaker-core/config.rb#L13) |
| date | The date the commit was made | YYYY-MM-DD format |

> For more information about the use of categories - please refer to the sonny documentation.

### Limitations with regards to Pull Requests

1. Squished commits work as exepected and the contents of the child commmits is available
2. Rebased commits show as local commits as there is no way to see where they came from
3. Unsquished commits only show the PR commit_message as the child commits are ignored

> Our advice is to always use Squished commits.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributors

<p>
	<a href="https://github.com/TGWolf">
		<img src="https://img.shields.io/badge/Wolf-black?style=for-the-badge" />
	</a>
</p>

## Show Support

<p>
	<a href="https://ko-fi.com/wolfsoftware">
		<img src="https://img.shields.io/badge/Ko%20Fi-blue?style=for-the-badge&logo=ko-fi&logoColor=white" />
	</a>
</p>
