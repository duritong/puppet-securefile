# manage a location where
# we are mounting an encrypted drive
class securefile(
  $mount_source   = '/dev/xvdb3',
  $fstype         = 'absent',
  $mount_options  = 'absent',
  $mount_atboot   = true
) {

  file{
    '/e':
      ensure  => directory,
      owner   => root,
      group   => 0,
      mode    => '0644';
    '/e/.issecure':
      content => "### file managed by puppet ####
# this file should ensure that a crypted disk is mounted!
# don't remove it\n",
      owner   => root,
      group   => 0,
      mode    => '0644';
  }

  if str2bool($::selinux) {
    File['/e']{
      seltype => 'default_t'
    }
  }

  mount{'/e': }
  if $mount_source != 'fake' {
    $def_fs =  $::operatingsystem ? {
      'OpenBSD'=> 'ffs',
      default  => 'ext4'
    }
    $real_mount_options = $mount_options ? {
      'absent' => $::operatingsystem ? {
        'OpenBSD' => 'rw,nodev,nosuid',
        default   => 'nodev',
      },
      default => $mount_options
    }
    $real_fstype = $fstype ? {
      'absent' => $def_fs,
      default => $fstype
    }
    $remounts = $::operatingsystem ? {
      'OpenBSD' => false,
      default   => true
    }

    Mount['/e']{
      device    => $mount_source,
      ensure    => mounted,
      fstype    => $real_fstype,
      options   => $real_mount_options,
      remounts  => $remounts,
      require   => File['/e'],
    }

    case $::operatingsystem {
      'OpenBSD': { }
      default: {
        Mount['/e']{
          atboot  => $mount_atboot
        }
      }
    }
    File['/e/.issecure']{
      require => Mount['/e']
    }
  } else {
    Mount['/e']{
      ensure => absent
    }
  }
}
