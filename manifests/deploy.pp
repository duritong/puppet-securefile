define securefile::deploy(
  $source = 'absent',
  $content = 'absent',
  $ensure = 'present',
  $path = 'absent',
  $owner = 'root',
  $group = '0',
  $mode = '0640',
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
    path => "/e/${real_path}",
    ensure => $ensure,
  }

  if $ensure == 'present' {
    include ::securefile

    File[$name]{
      require => File['/e/.issecure'],
      owner => $owner, group => $group, mode => $mode
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
