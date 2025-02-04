$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
$global:TestConfig = Get-TestConfig

Describe "$CommandName Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        [object[]]$params = (Get-Command $CommandName).Parameters.Keys | Where-Object {$_ -notin ('whatif', 'confirm')}
        [object[]]$knownParameters = 'SqlInstance', 'SqlCredential', 'Database', 'ExcludeDatabase', 'SinceCreation', 'SinceLastExecution', 'ExcludeEmptyQueryPlan', 'Force', 'EnableException'
        $knownParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        It "Should only contain our specific parameters" {
            (@(Compare-Object -ReferenceObject ($knownParameters | Where-Object {$_}) -DifferenceObject $params).Count ) | Should Be 0
        }
    }
}

Describe "$commandname Integration Tests" -Tags "IntegrationTests" {

    Context "Gets Execution Plan" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 | Where-Object {$_.statementtype -eq 'SELECT'} | Select-object -First 1
        It "Gets results" {
            $results | Should Not Be $null
        }
    }
    Context "Gets Execution Plan when using -Database" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 -Database Master | Select-object -First 1
        It "Gets results" {
            $results | Should Not Be $null
        }
        It "Should be execution plan on Master" {
            $results.DatabaseName | Should Be 'Master'
        }
    }
    Context "Gets no Execution Plan when using -ExcludeDatabase" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 -ExcludeDatabase Master | Select-object -First 1
        It "Gets results" {
            $results | Should Not Be $null
        }
        It "Should be execution plan on Master" {
            $results.DatabaseName | Should Not Be 'Master'
        }
    }
    Context "Gets Execution Plan when using -SinceCreation" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 -Database Master -SinceCreation '01-01-2000' | Select-object -First 1
        It "Gets results" {
            $results | Should Not Be $null
        }
        It "Should be execution plan on Master" {
            $results.DatabaseName | Should Be 'Master'
        }
        It "Should have a creation date Greater than 01-01-2000" {
            $results.CreationTime | Should BeGreaterThan '01-01-2000'
        }
    }
    Context "Gets Execution Plan when using -SinceLastExecution" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 -Database Master -SinceLastExecution '01-01-2000' | Select-object -First 1
        It "Gets results" {
            $results | Should Not Be $null
        }
        It "Should be execution plan on Master" {
            $results.DatabaseName | Should Be 'Master'
        }
        It "Should have a execution time Greater than 01-01-2000" {
            $results.LastExecutionTime | Should BeGreaterThan '01-01-2000'
        }
    }
    Context "Gets Execution Plan when using -ExcludeDatabase" {
        $results = Get-DbaExecutionPlan -SqlInstance $TestConfig.instance2 -ExcludeEmptyQueryPlan
        It "Gets no results" {
            $results | Should Not Be $null
        }
    }
}
