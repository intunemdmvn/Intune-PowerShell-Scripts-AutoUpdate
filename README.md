# PowerShell Script Execution via Intune

## 🔧 Key Behavior Summary

### Administrator Context
- Scripts set to **user context** will run with **administrator privileges** if the end user has administrative rights.

### User Sign-In Not Required
- **Users do not need to be signed in** for PowerShell scripts to execute.

### Intune Management Extension Check-In
- Intune checks for new or changed scripts **after every reboot**.
- If a script **fails**, Intune retries it **up to 3 times** during the next **3 consecutive check-ins**.

### Script Execution Frequency
- Scripts run **once** unless:
  - The **script or its policy is updated**.
  - The **initial execution fails**.

### Device Assignment Behavior
- When assigned to a **device**, the script:
  - Runs **once per new user** signing in.
  - Does **not run per-user** on **multi-session SKUs** (user check-in is disabled).

### Execution Order
- PowerShell scripts run **before** any assigned **Win32 apps**.

### Execution Timeout
- Each script has a **30-minute** execution timeout.

---

**Note:** These behaviors are subject to change based on Microsoft Intune service updates.

