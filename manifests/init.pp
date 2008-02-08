# modules/securefile/manifests/init.pp - manage securefiles stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "securefile": }

class securefile {

    $real_e_mount_source = $e_mount_source ? {
        '' => "/dev/xvdb3",
        default => $e_mount_source
    }

   file{"/e":
        ensure => directory,
        owner => root,
        group => 0,
        mode => 0755,
   }

   mount{"e_disk":
        name    => '/e',
        atboot  => true,
        device  => $e_mount_source,
        ensure  => mounted,
        options => 'nodev',
        require => File["/e"],
    } 

    file{"/e/.issecure":
        source  => 'puppet://$server/securefile/issecure',
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
    $mode => '0640'
){
    include securefile
    file{$name:
        source => "puppet://$server/secfiles/$source",
        path => $path,
        owner => $owner,
        group => $group,
        mode => $mode,
        ensure => present,
        require => File["/e/.issecure"],
    }
}
