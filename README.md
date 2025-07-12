Before you begin
When scripts are set to user context and the end user has administrator rights, by default, the PowerShell script runs under the administrator privilege.

End users aren't required to sign in to the device to execute PowerShell scripts.

The Intune management extension checks after every reboot for any new scripts or changes. After you assign the policy to the Microsoft Entra groups, the PowerShell script runs, and the run results are reported. Once the script executes, it doesn't execute again unless there's a change in the script or policy. If the script fails, the Intune management extension retries the script three times for the next three consecutive Intune management extension check-ins.

A PowerShell script assigned to the device will run for every new user that signs in, except on multi-session SKUs where user check-in is disabled.

PowerShell scripts are executed before Win32 apps run. In other words, PowerShell scripts execute first. Then, Win32 apps execute.

PowerShell scripts time out after 30 minutes.
