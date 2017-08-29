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
        )

    begin
        {
            [xml]$xmlFile = Get-Content -Path $FilePath
            $steps = $xmlFile.Transaction.Configuration.Step

            $internetExplorer = New-Object -ComObject internetexplorer.application
            $internetExplorer.Visible = $xmlFile.Transaction.Configuration.internetExplorerSettings.enable_ui
            $internetExplorer.FullScreen = $xmlFile.Transaction.Configuration.internetExplorerSettings.enable_full_screen
			$internetExplorer.AddressBar = $xmlFile.Transaction.Configuration.internetExplorerSettings.enable_address_bar

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
                            if ($stepAction -eq "back")
                                {
                                    $preActionLocation = $internetExplorer.LocationURL
                                    $internetExplorer.GoBack()

                                    Wait-InternetExplorer

                                    if ($preActionLocation -ne ($internetExplorer.LocationURL))
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }            
                                }

                            elseif ($stepAction -eq "forward")
                                {
                                    $preActionLocation = $internetExplorer.LocationURL
                                    $internetExplorer.GoForward()

                                    Wait-InternetExplorer

                                    if ($preActionLocation -ne ($internetExplorer.LocationURL))
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }            
                                }

                            elseif ($stepAction -eq "Refresh")
                                {
                                    $preActionLocation = $internetExplorer.LocationURL
                                    $internetExplorer.Refresh()

                                    Wait-InternetExplorer

                                    if ($preActionLocation -eq ($internetExplorer.LocationURL))
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }            
                                }

                            elseif ($stepAction -eq "get_location_name")
                                {
                                    $locationName = $internetExplorer.LocationName

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$locationName"
                                }

                            elseif ($stepAction -eq "get_location_url")
                                {
                                    $locationURL = $internetExplorer.LocationURL

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$locationURL"
                                }

                            elseif ($stepAction -eq "get_cookie")
                                {
                                    $cookie = $internetExplorer.Document.Cookie

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$cookie"
                                }

                            elseif ($stepAction -eq "set_cookie")
                                {
                                    [string]$cookie = $step.value
                                    [string] $preActionCookie = $internetExplorer.Document.Cookie
                                    $internetExplorer.Document.Cookie = "$cookie"

                                    Wait-InternetExplorer

                                    if ($preActionCookie -ne ($internetExplorer.Document.Cookie))
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }
                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }
                                }

                            elseif ($stepAction -eq "get_page_title")
                                {
                                    [string]$pageTitle = $internetExplorer.Document.IHTMLDocument2_title

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$pageTitle"
                                }


                            elseif ($stepAction -eq "set_page_title")
                                {
                                    [stirng]$pageTitle = $step.value
                                    [string]$preActionTitle = $internetExplorer.Document.IHTMLDocument2_title
                                    $internetExplorer.Document.IHTMLDocument2_title = "$pageTitle"

                                    Wait-InternetExplorer

                                    if ($preActionTitle -ne ($internetExplorer.Document.IHTMLDocument2_title))
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }
                                }


                            elseif ($stepAction -eq "click_element_by_id")
                                {
                                    [string]$stepElement = $step.element
                                    $internetExplorer.Document.IHTMLDocument3_getElementByID("$stepElement").Click()

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                }

                            elseif ($stepAction -eq "click_element_by_tag_name")
                                {
                                    [string]$stepTag = $step.tag
                                    [string]$stepProperty = $step.property
                                    [string]$stepValue = $step.Value

                                    ($internetExplorer.Document.IHTMLDocument3_getElementsByTagName("$stepTag") | Where-Object {$_.$stepProperty -eq "$stepValue"} | Select-Object -First 1).Click()

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                }
                       
                            elseif ($stepAction -eq "navigate")
                                {
                                    [string]$stepUrl = $step.url
                                    [string]$preActionLocation = $internetExplorer.LocationURL
                                    $internetExplorer.Navigate("$stepUrl")

                                    Wait-InternetExplorer

                                    $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                }

                            elseif ($stepAction -eq "validate_text")
                                {
                                    [string]$stepContent = $step.value

                                    if (($internetExplorer.Document.IHTMLDocument3_documentElement.innerText.Contains("$stepContent")) -eq $true)
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }
                                }

                            elseif ($stepAction -eq "set_element_by_id")
                                {
                                    [string]$stepElement = $step.element
                                    [string]$stepValue = $step.value

                                    $internetExplorer.Document.IHTMLDocument3_getElementByID("$stepElement").value = "$stepValue"

                                    Wait-InternetExplorer

                                    if (($internetExplorer.Document.IHTMLDocument3_getElementByID("$stepElement").value) -eq "$stepValue")
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$true"
                                        }

                                    else
                                        {
                                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                                        }
                                }
                        }

                    catch [System.Management.Automation.ErrorRecord]
                        {
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Results" -Value "$false"
                            $stepResults | Add-Member -MemberType NoteProperty -Name "Error" -Value "$stepElement not found on page"
                        }

                    catch
                        {
                            $errorType = $Error[0].GetType().FullName
                            $errorMessage = $Error[0].ToString() + $Error[0].InvocationInfo.PositionMessage

                            Write-Output "You Shopuld Handle This Error Type: $errorType"
                            Write-Output "$errorMessage"
                        }

                    [datetime]$stepEndTime = Get-Date
                    [int32]$stepTimeTaken = (New-TimeSpan -Start $stepStartTime -End $stepEndTime).Seconds
                    $stepResults | Add-Member -MemberType NoteProperty -Name "Time in Step" -Value "$stepTimeTaken Seconds"
                    $transactionResults += $stepResults
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
    <#
        .SYNOPSIS
            Helper Fucntion that Looks at Internet Explorers State.
        .DESCRIPTION
            Helper Fucntion that Looks at Internet Explorers State. If state is busy we wait two seconds, if not we conitnue.
    #>

    While ($internetExplorer.Busy -eq $true)
        {
            Start-Sleep -Seconds 2
        }
}
