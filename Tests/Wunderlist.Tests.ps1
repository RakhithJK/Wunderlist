﻿#requires -Version 3
#Variables for Pester tests

$ModulePath = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
$ModuleName = 'Wunderlist'
$ManifestPath   = "$ModulePath\Wunderlist\$ModuleName.psd1"
$ModulePSM1file   = "$ModulePath\Wunderlist\$ModuleName.psm1"
if (Get-Module -Name $ModuleName) 
{
  Remove-Module $ModuleName -Force 
}
Import-Module $ManifestPath -Verbose:$false


# test the module manifest - exports the right functions, processes the right formats, and is generally correct
Describe -Name 'Manifest' -Fixture {
  $ManifestHash = Invoke-Expression -Command (Get-Content $ManifestPath -Raw)

  It -name 'has a valid manifest' -test {
    {
      $null = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
    } | Should Not Throw
  }

  It -name 'has a valid root module' -test {
    $ManifestHash.RootModule | Should Be "$ModuleName.psm1"
  }

  It -name 'has a valid Description' -test {
    $ManifestHash.Description | Should Not BeNullOrEmpty
  }

  It -name 'has a valid guid' -test {
    $ManifestHash.Guid | Should Be '8418f0c1-db0c-4605-85b6-4ed52b460160'
  }

  It -name 'has a valid version' -test {
    $ManifestHash.ModuleVersion -as [Version] | Should Not BeNullOrEmpty
  }

  It -name 'has a valid copyright' -test {
    $ManifestHash.CopyRight | Should Not BeNullOrEmpty
  }

  It -name 'has a valid license Uri' -test {
    $ManifestHash.PrivateData.Values.LicenseUri | Should Be 'http://opensource.org/licenses/MIT'
  }
    
  It -name 'has a valid project Uri' -test {
    $ManifestHash.PrivateData.Values.ProjectUri | Should Be 'https://github.com/stefanstranger/Wunderlist'
  }
    
  It -name "gallery tags don't contain spaces" -test {
    foreach ($Tag in $ManifestHash.PrivateData.Values.tags)
    {
      $Tag -notmatch '\s' | Should Be $true
    }
  }
}


Describe -Name 'Module Wunderlist works' -Fixture {
  It -name 'Passed Module load' -test {
    Get-Module -Name 'Wunderlist' | Should Not Be $null
  }
}

Describe -Name 'Wunderlist Aliases work' -Fixture {
  It -Name 'Testing gwu alias' -Test {
    $result = (Get-Alias -name gwu).Definition 
    $result | Should Be "Get-WunderlistUser"
  }

  It -Name 'Testing gwl alias' -Test {
    $result = (Get-Alias -name gwl).Definition 
    $result | Should Be "Get-WunderlistList"
  }

  It -Name 'Testing gwt alias' -Test {
    $result = (Get-Alias -name gwt).Definition 
    $result | Should Be "Get-WunderlistTask"
  }

  It -Name 'Testing nwt alias' -Test {
    $result = (Get-Alias -name nwt).Definition 
    $result | Should Be "New-WunderlistTask"
  }

  It -Name 'Testing rwt alias' -Test {
    $result = (Get-Alias -name rwt).Definition 
    $result | Should Be "Remove-WunderlistTask"
  }

  It -Name 'Testing gwn alias' -Test {
    $result = (Get-Alias -name gwn).Definition 
    $result | Should Be "Get-WunderlistNote"
  }

  It -Name 'Testing gwf alias' -Test {
    $result = (Get-Alias -name gwf).Definition 
    $result | Should Be "Get-WunderlistFolder"
  }
}

Describe -Name 'Test Functions in Wunderlist Module' -Fixture {
  Context -Name 'Testing Public Functions' -Fixture {
    It -name 'Passes New-WunderlistTaks Function' -test {
      $result = New-WunderlistTask -listid '126300146' -title 'Wunderlist Pester Test'
      $result.title | Should Be 'Wunderlist Pester Test'
    }

    It -name 'Passes Get-WunderlistUser Function' -test {
      Get-WunderlistUser | Should Not Be $null
    }

    It -name 'Passes Get-WunderlistTask Function' -test {
      Get-WunderlistTask | Should Not Be $null
    }

    It -name 'Passes Get-WunderlistList Function' -test {
      Get-WunderlistList| Should Not Be $null
    }

    It -name 'Passes Get-WunderlistReminder Function' -test {
      Get-WunderlistReminder | Should Not Be $null
    }
        
    It 'Passes Remove-WunderlistTask Function' {
        {
            $null = Get-WunderlistTask -Title 'Wunderlist Pester Test' | Remove-WunderlistTask 
        } | Should Not Throw
    }

    It 'Passes Get-WunderlistNote Function' -test {
      Get-WunderlistTask | Get-WunderlistNote -Task | Should Not Be $null
    }

    It 'Passes Get-WunderlistFolder Function' -test {
      Get-WunderlistFolder | Should Not Be $null
    }

  }
}
