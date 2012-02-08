class securefile {

  file{"/e":
    ensure => directory,
    owner => root, group => 0, mode => 0755;
  }

  if $::selinux == 'true' {
    File['/e']{
      seltype => 'cert_t'
    }
  }

  file{'/e/.issecure':
    content => "### file managed by puppet ####\n# this file should ensure that a crypted disk is mounted!\n# don't remove it\n",
    owner => root, group => 0, mode => 0644;
  }

  mount{'/e': }
  if hiera('e_mount_source','/dev/xvdb3') != 'fake' {
    $def_fs =  $::operatingsystem ? {
        openbsd => 'ffs',
        default => 'ext3'
    }
    $def_mount_options = $::operatingsystem ? {
      openbsd => 'rw,nodev,nosuid',
      default => 'nodev'
    }

    Mount['/e']{
      device  => hiera('e_mount_source','/dev/xvdb3'),
      ensure  => mounted,
      fstype  => hiera('e_mount_fstype',$def_fs),
      options => hiera('e_mount_options',$def_mount_options),
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
          atboot  => hiera('e_mount_atboot',true)
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
