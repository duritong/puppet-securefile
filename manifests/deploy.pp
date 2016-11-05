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
    default  => $path,
  }

  file{"/e/${real_path}":
    ensure => $ensure,
  }
  if $name != "/e/${real_path}" {
    File["/e/${real_path}"]{
      alias => $name,
    }
  }

  if $ensure == 'present' {
    File["/e/${real_path}"]{
      require => File['/e/.issecure'],
      owner   => $owner,
      group   => $group,
      mode    => $mode
    }

    if $seltype != 'absent' {
      File["/e/${real_path}"]{
        seltype => $seltype
      }
    }

    if $source != 'absent' {
      File["/e/${real_path}"]{
        source => "puppet:///modules/site_securefile/${source}",
      }
    } else {
      File["/e/${real_path}"]{
        content => $content,
      }
    }
  }
}
