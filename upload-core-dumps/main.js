// @ts-check
const { execSync } = require("child_process");
const fs = require("fs");
const os = require("os");

function log(message) {
  const color = "\x1b[32m";
  const reset = "\x1b[0m";
  console.log(`${color}${message}${reset}`);
}

function configureForUnix() {
  const coresPath = "/cores";
  if (!fs.existsSync(coresPath)) {
    execSync(`sudo mkdir ${coresPath}`);
  }
  execSync("sudo chmod 777 /cores");
  if (fs.existsSync("/proc/sys/kernel/core_pattern")) {
    execSync('echo "/cores/%e.%p.%t" | sudo tee /proc/sys/kernel/core_pattern');
  }
  log("Core dump configuration completed, core dumps will be saved in /cores");
  log(
    "Remember to call `$ ulimit -c unlimited` in each step to enable core dumps for the current session"
  );
}

function configureForWindows() {
  const coresPath = "C:\\cores";
  if (!fs.existsSync(coresPath)) {
    fs.mkdirSync(coresPath, { recursive: true });
  }
  const powershellCommands = `
    New-Item -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Force;
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Name "DumpFolder" -Value "${coresPath}";
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Name "DumpType" -Value 2;
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Name "CustomDumpFlags" -Value 0;
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Name "DumpCount" -Value 100;
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting\\LocalDumps" -Name "DumpMaxSize" -Value 1024;
  `;
  execSync(`powershell.exe -Command "${powershellCommands}"`);
  log("Core dump configuration completed");
}

function main() {
  if (os.platform() === "linux" || os.platform() === "darwin") {
    configureForUnix();
  } else if (os.platform() === "win32") {
    configureForWindows();
  } else {
    console.log("::warning::Unsupported platform for core dump configuration");
  }
}

try {
  main();
} catch (error) {
  console.log("::warning::Could not configure core dump", error);
}
