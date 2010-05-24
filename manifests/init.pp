# modules/securefile/manifests/init.pp - manage securefiles stuff
# Copyright (C) 2007 admin@immerda.ch
#

class securefile {

    file{"/e":
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
    }

    file{'/e/.issecure':
        source  => "puppet://$server/modules/securefile/issecure",
        owner => root, group => 0, mode => 0644;
    }

    mount{'/e': }
    if $e_mount_source != 'fake' {

        $real_e_mount_source = $e_mount_source ? {
            '' => "/dev/xvdb3",
            default => $e_mount_source
        }
        $real_e_mount_fstype = $e_mount_fstype ? {
            '' => $operatingsystem ? {
                openbsd => 'ffs',
                default => 'ext3'
            },
            default => $e_mount_fstype
        }
        $real_e_mount_options = $e_mount_options ? {
            '' => $operatingsystem ? {
                openbsd => 'rw,nodev,nosuid',
                default => 'nodev'
            },
            default => $e_mount_options,
        }

        Mount['/e']{
            device  => $real_e_mount_source,
            ensure  => mounted,
            fstype  => $real_e_mount_fstype,
            options => $real_e_mount_options,
            remounts => $operatingsystem ? {
                openbsd => false,
                default => true
            },
            require => File["/e"],
        }

        case $operatingsystem {
            openbsd: { info("openbsd doesn't yet support atboot") }
            default: {
                $real_e_mount_atboot = $e_mount_atboot ? {
                    '' => true,
                    default => $e_mount_atboot
                }

                Mount['/e']{
                    atboot  => $real_e_mount_atboot,
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
