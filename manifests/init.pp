class securefile(
  $mount_source = '/dev/xvdb3',
  $fstype = 'absent',
  $mount_options = 'absent',
  $mount_atboot = true
) {

  file{"/e":
    ensure => directory,
    owner => root, group => 0, mode => 0755;
  }

  if $::selinux == 'true' {
    File['/e']{
      seltype => 'default_t'
    }
  }

  file{'/e/.issecure':
    content => "### file managed by puppet ####\n# this file should ensure that a crypted disk is mounted!\n# don't remove it\n",
    owner => root, group => 0, mode => 0644;
  }

  mount{'/e': }
  if $mount_source != 'fake' {
    $def_fs =  $::operatingsystem ? {
        openbsd => 'ffs',
        default => 'ext3'
    }
    $def_mount_options = $::operatingsystem ? {
      openbsd => 'rw,nodev,nosuid',
      default => 'nodev'
    }

    Mount['/e']{
      device  => $mount_source,
      ensure  => mounted,
      fstype  => $fstype ? {
        'absent' => $def_fs,
        default => $fstype
      },
      options => $mount_options ? {
        'absent' => $def_mount_options,
        default => $mount_options
      },
      remounts => $::operatingsystem ? {
        openbsd => false,
        default => true
      },
      require => File["/e"],
    }

    case $::operatingsystem {
      openbsd: { }
      default: {
        Mount['/e']{
          atboot  => $mount_atboot
        }
      }
    }
    File['/e/.issecure']{
      require => Mount["/e"]
    }
  } else {
    Mount['/e']{
      ensure => absent
    }
  }
}
