# deploys a file under the "secure" path
define securefile::deploy(
  $source  = 'absent',
  $content = 'absent',
  $ensure  = 'present',
  $path    = 'absent',
  $owner   = 'root',
  $group   = '0',
  $mode    = '0640',
  $seltype = 'absent'
){
  if ($source == 'absent') and ($content == 'absent') and ($ensure == 'present'){
    fail("Source or content must be set if ${name} should be present!")
  }

  $real_path = $path ? {
    'absent' => $name,
    default => $path,
  }

  file{$name:
    ensure => $ensure,
    path   => "/e/${real_path}",
  }
  if $name != "/e/${real_path}" {
    File[$name]{
      alias => "/e/${real_path}"
    }
  }

  if $ensure == 'present' {
    File[$name]{
      require => File['/e/.issecure'],
      owner   => $owner,
      group   => $group,
      mode    => $mode
    }

    if $seltype != 'absent' {
      File[$name]{
        seltype => $seltype
      }
    }

    if $source != 'absent' {
      File[$name]{
        source => "puppet:///modules/site_securefile/${source}",
      }
    } else {
      File[$name]{
        content => $content,
      }
    }
  }
}
