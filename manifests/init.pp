# modules/securefile/manifests/init.pp - manage securefiles stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "securefile": }

class securefile {

    $real_e_mount_source = $e_mount_source ? {
        '' => "/dev/xvdb3",
        default => $e_mount_source
    }
    $real_e_mount_atboot = $e_mount_atboot ? {
        '' => true,
        default => $e_mount_atboot
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

    file{"/e":
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
    }
    
    if $selinux {
        selinux::module {"extension_securefile":}
    }

    mount{"e_disk":
        name    => '/e',
        atboot  => $real_e_mount_atboot,
        device  => $real_e_mount_source,
        ensure  => mounted,
        fstype  => $real_e_mount_fstype,
        options => $real_e_mount_options,
        require => File["/e"],
    } 

    file{'/e/.issecure':
        source  => "puppet://$server/securefile/issecure",
        owner   => root,
        group   => 0,
        mode    => 0644,
        require => Mount["e_disk"]
    }
}

define securefile::deploy(
    $source,
    $path = 'absent',
    $owner = 'root',
    $group = '0',
    $mode = '0640'
){
    include securefile

    if $require {
        $real_require  = [ File['/e/.issecure'], $require]
    } else {
        $real_require =  File['/e/.issecure']
    }

    $real_path = $path ? {
        'absent' => $name,
        default => $path,
    }

    file{$name:
        source => "puppet://$server/secfiles/$source",
        path => "/e/$real_path",
        owner => $owner,
        group => $group,
        mode => $mode,
        ensure => present,
        require => $real_require,
    }
    if $notify {
        File[$name]{
            notify => $notify,
        }
    }
    if $before {
        File[$name]{
            before => $before,
        }
    }
}
