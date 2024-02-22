const { spawn } = require("child_process");

const run = process.env["INPUT_RUN"];
const cwd = process.env["INPUT_CWD"] || "."; // Use the current directory as default

console.log(`::info::Running command in ${cwd}:\n\n${run}`);

const options = {
  cwd: cwd,
  stdio: ["pipe", process.stdout, process.stderr],
};
let shell;

if (process.env.RUNNER_OS === "Windows") {
  shell = "C:\\msys64\\usr\\bin\\bash.EXE";
} else {
  shell = "/bin/bash";
}

const bashProcess = spawn(shell, [], options);

bashProcess.stdin.write(run);
bashProcess.stdin.end();

bashProcess.on("exit", (code) => {
  console.log(`Child process exited with code ${code}`);
  process.exit(code);
});
