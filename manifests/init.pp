# modules/securefile/manifests/init.pp - manage securefiles stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "securefile": }

class securefile {

    $real_e_mount_source = $e_mount_source ? {
        '' => "/dev/xvdb3",
        default => $e_mount_source
    }

    $real_secure_fs_type = $secure_fs_type ? {
        '' => 'ext3',
        default => $secure_fs_type
    }

    file{"/e":
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
    }
    
    if $selinux {
        selinux::module {"aa_securefile":}
    }

    mount{"e_disk":
        name    => '/e',
        atboot  => true,
        device  => $real_e_mount_source,
        ensure  => mounted,
        fstype  => $real_secure_fs_type,
        options => 'nodev',
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
    $path,
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

    file{$name:
        source => "puppet://$server/secfiles/$source",
        path => $path,
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
