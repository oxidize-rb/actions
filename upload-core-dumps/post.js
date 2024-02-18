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

function genHelpers(relativePathToCore) {
  const lldb = `
    #!/usr/bin/env lldb -s
    target create --core ${relativePathToCore}
    bt all
    quit
  `;
  const gdb = `
    #!/usr/bin/env gdb -x
    core-file ${relativePathToCore}
    bt
    quit
  `;
  const readme = `
    # Core dump analysis
    This core dump was generated during the CI run. To analyze it, you can use the following commands:

    ## Using LLDB
    \`\`\`
    ./analyze-lldb
    \`\`\`

    ## Using GDB
    \`\`\`
    ./analyze-gdb
    \`\`\`
  `;

  let files = {
    ["analyze-lldb"]: lldb,
    ["analyze-gdb"]: gdb,
    ["README.md"]: readme,
  };

  for (let file in files) {
    fs.writeFileSync(file, files[file]);
    if (file.startsWith("bin/")) {
      fs.chmodSync(file, "755");
    }
  }

  return Object.keys(files);
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

  const outdir = "coredumps";
  fs.mkdirSync(outdir, { recursive: true });

  for (let core of cores) {
    const coredest = path.join(outdir, core);
    fs.mkdirSync(path.dirname(coredest), { recursive: true });
    fs.copyFileSync(core, coredest);
    const executable = inferCrashingExecutable(core);
    if (executable) {
      const exedest = path.join(outdir, executable);
      fs.mkdirSync(path.dirname(exedest), { recursive: true });
      fs.copyFileSync(executable, exedest);
    }
  }
  process.chdir(outdir);
  genHelpers(cores[0]);
  process.chdir("..");

  const arch = `${process.platform}-${process.arch}`;
  const repoName = (process.env.GITHUB_REPOSITORY || "gha").split("/").pop();
  const jobId = process.env.GITHUB_JOB;
  const uploadFileName = `core-dumps-${arch}-${repoName}-${jobId}`;
  const extraFiles = (process.env.INPUT_EXTRA_FILES_TO_UPLOAD || "").split(
    "\n"
  );
  const filesToUpload = [`${outdir}/`, ...extraFiles];

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

function inferCrashingExecutable(filePath) {
  const stats = fs.statSync(filePath);
  if (stats.size <= 50 * 1024 * 1024 * 1024) {
    const output = execFileSync("file", [filePath], { encoding: "utf-8" });
    const regex = /execfn: '([^']+)'/;
    const match = output.match(regex);
    if (match && match[1]) {
      const executable = match[1];
      log(`Inferred crashing executable: ${executable}`);
      return executable;
    }
  }
}

async function main() {
  try {
    executeScript(filePath);
  } catch (error) {
    console.log("::error::Errored when executing script", error);
  }
}

main();
