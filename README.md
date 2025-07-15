# PowerShell Script Auto Update Apps via Intune

The scripts are designed to automatically update applications on a Windows machine using a daily scheduled task. It uses GitHub APIs to check the latest version, compares it with the installed version, and installs the update silently if needed.

### User Sign-In Not Required
- **Users do not need to be signed in** for PowerShell scripts to execute.

### Intune Management Extension Check-In
- Intune checks for new or changed scripts **after every reboot**.
- If a script **fails**, Intune retries it **up to 3 times** during the next **3 consecutive check-ins**.

### Script Execution Frequency
- Scripts run **once** unless:
  - The **script or its policy is updated**.
  - The **initial execution fails**.

### Execution Order
- PowerShell scripts run **before** any assigned **Win32 apps**.

### Execution Timeout
- Each script has a **30-minute** execution timeout.

---

**Note:** These behaviors are subject to change based on Microsoft Intune service updates.

