# pp file is the global configuration that defines which rules you want to use.

# By default boxen will look into the modules/people/manifests dir for user specific .pp files.
# It will use your github username to track down your file (modules/people/manifests/mcansky.pp).
# Instead of adding things to the site.pp file you should add them in your user's pp file. It's cleaner.


# fortyAU thangs #
##################

include chrome
include firefox
include lastpass
include sourcetree


# https://github.com/boxen/puppet-virtualbox/issues/45
class { 'virtualbox':
  version     => '5.0.14',
  patch_level => '105127'
}

# https://github.com/boxen/puppet-heroku
include heroku
heroku::plugin { 'accounts':
  source => 'ddollar/heroku-accounts'
}

# https://github.com/boxen/puppet-atom
include atom
atom::package { 'aligner': }
atom::package { 'aligner-ruby': }
atom::package { 'atom-beautify': }
atom::package { 'atom-pair': }
atom::package { 'autocomplete-elixir': }
atom::package { 'codo': }
atom::package { 'imdone-atom': }
atom::package { 'impress': }
atom::package { 'line-count-status': }
atom::package { 'linter': }
atom::package { 'linter-coffee-variables': }
atom::package { 'linter-eslint': }
atom::package { 'linter-js-standard': }
atom::package { 'linter-ruby': }
atom::package { 'linter-sass-lint': }
atom::package { 'linter-stylint': }
atom::package { 'markdown-preview-plus': }
atom::package { 'node-debugger': }
atom::package { 'pigments': }
atom::package { 'symbols-tree-view': }
atom::package { 'sync-settings': }
atom::package { 'tab-switcher': }
atom::theme { 'monokai': }


# https://github.com/boxen/puppet-mysql
include mysql
mysql::db { 'mydb': }

# https://github.com/boxen/puppet-postgresql
include postgresql
postgresql::db { 'mydb': }

# https://github.com/boxen/puppet-mongodb
include mongodb

# https://github.com/boxen/puppet-osx
include osx::finder::empty_trash_securely
include osx::finder::show_all_on_desktop
include osx::no_network_dsstores
include osx::safari::enable_developer_mode
include osx::software_update


# Java
include java


# Stock Config #
################

require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
