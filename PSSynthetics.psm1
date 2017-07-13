Function Start-SyntheticTransaction
{
    <#
        .SYNOPSIS
            Function to simulate user interaction on a website.
        .DESCRIPTION
            This Funciton process's the supplied xml file and simulates the web transaction using the internet explorer Com Object.
        .PARAMETER FilePath
            Provide the full path to the xml file to process.
        .EXAMPLE
            PS> Start-SyntheticTransaction -FilePath C:\Some\Path\someFile.xml

            This Example will spawn an instance of internet explorer and will perform the transaction from the provided xml file.
        .INPUTS
            XML
        .OUTPUTS
            PSObject
    #>

    param
        (
            [CmdletBinding(SupportsShouldProcess=$true)]
            [Parameter(Mandatory=$true, Position=0)]
            [validateScript({Test-Path -Path $_ -PathType Leaf})]
            [string]$FilePath

            #[Parameter(Position=1)]
            #[string]$ResultPath = "$env:USERPROFILE\Desktop\$(get-date -Format 'yyyy-MM-dd_hhmmss')"
        )


    begin
        {
            <#if (-not(Test-Path -Path $ResultPath))
                {
                    New-Item -Path $ResultPath -ItemType Directory | Out-Null
                }#>

            [xml]$xmlFile = Get-Content -Path $FilePath
            $steps = $xmlFile.Transaction.Configuration.Step

            $internetExplorer = New-Object -ComObject internetexplorer.application
            $internetExplorer.Visible = $xmlFile.Transaction.Configuration.internetExplorerSettings.uiVisible
            $internetExplorer.FullScreen = $xmlFile.Transaction.Configuration.internetExplorerSettings.uiFullScreen

            [array]$transactionResults = @()
        }

    process
        {
            foreach ($step in $steps)
                {
                    [string]$stepNumber = $step.stepNumber
                    [string]$stepAction = $step.action
                    [string]$stepDescription = $step.description

                    [object]$stepResults = New-Object -TypeName psobject
                    $stepResults | Add-Member -MemberType NoteProperty -Name "Step" -Value "$stepNumber"
                    $stepResults | Add-Member -MemberType NoteProperty -Name "Action" -Value "$stepAction"
                    $stepResults | Add-Member -MemberType NoteProperty -Name "Description" -Value "$stepDescription"

                    [datetime]$stepStartTime = Get-Date
                    try
                        {
                            if ($stepAction -eq "clickElementById")
                                {
                                    [string]$stepElement = $step.element
                                    $internetExplorer.Document.IHTMLDocument3_getElementByID("$stepElement").Click()

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$true"        

                            [datetime]$stepEndTime = Get-Date
                            [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                            $transactionResults += $stepResults
                        }

                            elseif ($stepAction -eq "clickElementByTagName")
                                {
                                    [string]$stepTag = $step.tag
                                    [string]$stepProperty = $step.property
                                    [string]$stepPropertyValue = $step.propertyValue

                                    ($internetExplorer.Document.IHTMLDocument3_getElementsByTagName("$stepTag") | Where-Object {$_.$stepProperty -eq "$stepPropertyValue"} | Select-Object -First 1).Click()

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$true"

                            [datetime]$stepEndTime = Get-Date
                            [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                            $transactionResults += $stepResults
                        }
                       
                            elseif ($stepAction -eq "navigate")
                                {
                                    [string]$stepUrl = $step.url
                                    $internetExplorer.Navigate("$stepUrl")

                                    Wait-InternetExplorer

                                    if (($internetExplorer.LocationURL) -eq $stepUrl)
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$false" 
                                        }

                            [datetime]$stepEndTime = Get-Date
                            [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                            $transactionResults += $stepResults
                        }

                            elseif ($stepAction -eq "validateInnerText")
                                {
                                    [string]$stepContent = $step.content

                                    if (($internetExplorer.Document.IHTMLDocument3_documentElement.innerText.Contains("$stepContent")) -eq $true)
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$false"
                                        }

                            [datetime]$stepEndTime = Get-Date
                            [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                            $transactionResults += $stepResults
                        }

                            elseif ($stepAction -eq "valueElementbyID")
                                {
                                    [string]$stepElement = $step.element
                                    [string]$stepValue = $step.value

                                    $internetExplorer.Document.IHTMLDocument3_getElementByID("$stepElement").value = "$stepValue"

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$true"

                            [datetime]$stepEndTime = Get-Date
                            [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                            $transactionResults += $stepResults
                        }
                        }

                    catch [System.Management.Automation.ErrorRecord]
                        {
                            #$internetExplorer.Document.body.outerHTML | Out-File -FilePath "$ResultPath\$stepNumber.html"
                           
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Passed" -Value "$false"
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Error" -Value "$stepElement not found on page"
                            #$stepResults | Add-Member -MemberType NoteProperty -Name "Snapshot" -Value "&lt;a href=&quot;file:///$ResultPath\$stepNumber&quot;&gt;Show Error&lt;/a&gt;"
                        }

                    catch
                        {
                            $errorType = $Error[0].GetType().FullName
                            $errorMessage = $Error[0].ToString() + $Error[0].InvocationInfo.PositionMessage

                            Write-Output "You Shopuld Handle This Error Type: $errorType"
                            Write-Output "$errorMessage"
                        }
                }
        }

    end
        {
            $internetExplorer.Stop()
            $internetExplorer.Quit()

            Write-Output $transactionResults
        }
}

Function Wait-InternetExplorer
    {
        While ($internetExplorer.Busy -eq $true)
            {
                Start-Sleep -Seconds 2
            }
    }