define securefile::deploy(
    $source,
    $path = 'absent',
    $owner = 'root',
    $group = '0',
    $mode = '0640'
){
    include ::securefile

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
        source => "puppet://$server/modules/site-securefile/$source",
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
