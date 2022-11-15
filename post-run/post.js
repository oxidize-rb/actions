const execSync = require("child_process").execSync;

const run = process.env["INPUT_RUN"];
const cwd = process.env["INPUT_CWD"];

const options = { stdio: "inherit" };

if (cwd && cwd.length > 0) {
  options.cwd = cwd;
}

const command = `bash -c "${run}"`;

execSync(command, options);
