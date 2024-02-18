// @ts-check
const fs = require("fs");
const { execFileSync } = require("child_process");
const path = require("path");

const uploadScriptUrl =
  "https://raw.githubusercontent.com/actions/upload-artifact/v4.3.1/dist/upload/index.js";
const filePath = path.join(__dirname, "downloaded_script.js");

function log(message) {
  const color = "\x1b[32m";
  const reset = "\x1b[0m";
  console.log(`${color}${message}${reset}`);
}

function filterCoreDumps() {
  const coresPath = "/cores";
  let files;

  try {
    files = fs.readdirSync(coresPath);
  } catch (error) {
    return [];
  }

  let toUpload = [];

  for (let file of files) {
    const filePath = path.join(coresPath, file);
    const stats = fs.statSync(filePath);
    if (stats.size <= 50 * 1024 * 1024 * 1024) {
      log(
        `Adding ${file} to the list of cores to upload (size: ${
          stats.size / 1024 / 1024
        } MiB)`
      );
      toUpload.push(filePath);
    } else {
      console.log(
        `::warning::Skipping ${file} as it is too big ${
          stats.size / 1024 / 1024 / 1024
        } GiB)`
      );
    }
  }
  return toUpload;
}

function downloadFile(url, destPath) {
  const args = ["--fail", "--silent", "--location", "--output", destPath, url];
  const opts = { stdio: "inherit" }; // @ts-ignore
  execFileSync("curl", args, opts);
}

function executeScript(scriptPath) {
  const cores = filterCoreDumps();

  if (cores.length === 0) {
    log(
      "Found no core dumps (if you expected one, make sure to run `ulimit -c unlimited` in each step before the command that might crash the process runs)"
    );
    return;
  } else {
    log(`Found ${cores.length} core dumps to upload`);
  }

  const arch = `${process.platform}-${process.arch}`;
  const repoName = (process.env.GITHUB_REPOSITORY || "gha").split("/").pop();
  const jobId = process.env.GITHUB_JOB;
  const uploadFileName = `core-dumps-${arch}-${repoName}-${jobId}`;
  const extraFiles = (process.env.INPUT_EXTRA_FILES_TO_UPLOAD || "").split(
    "\n"
  );
  const filesToUpload = [
    ...cores,
    ...inferCrashingExecutables(),
    ...extraFiles,
  ];

  // I know... I know... I'm sorry
  const envKey = (key) => `INPUT_${key.toUpperCase().replace(/ /g, "_")}`;

  const env = {
    [envKey("name")]: uploadFileName,
    [envKey("path")]: filesToUpload.join("\n"),
    [envKey("overwrite")]: "true",
    [envKey("if-no-files-found")]: "ignore",
    GITHUB_ACTION_PATH: scriptPath,
  };

  for (let key in process.env) {
    if (!key.startsWith("INPUT_")) {
      env[key] = process.env[key];
    }
  }

  downloadFile(uploadScriptUrl, filePath);
  log("Downloaded the upload action, executing it...");
  execFileSync("node", [scriptPath], { stdio: "inherit", env });
}

function inferCrashingExecutables() {
  const coresPath = "/cores";
  const files = fs.readdirSync(coresPath);
  const crashingExecutables = new Set();

  for (let file of files) {
    const filePath = path.join(coresPath, file);
    const stats = fs.statSync(filePath);
    if (stats.size <= 50 * 1024 * 1024 * 1024) {
      const output = execFileSync("file", [filePath], { encoding: "utf-8" });
      const regex = /execfn: '([^']+)'/;
      const match = output.match(regex);
      if (match && match[1]) {
        const executable = match[1];
        log(`Inferred crashing executable: ${executable}`);
        crashingExecutables.add(executable);
      }
    }
  }

  return Array.from(crashingExecutables);
}

async function main() {
  try {
    executeScript(filePath);
  } catch (error) {
    console.log("::error::Errored when executing script", error);
  }
}

main();
