import { program } from "commander";
import { initialize } from "./commands/init";
import { doctor } from "./commands/doctor";
import { status } from "./commands/status";
import { audit } from "./commands/audit";
import { analyze } from "./commands/analyze";

program
  .name("noteagents")
  .description("Autonomous Engineering Agent Runtime")
  .version("1.0.0");

program
  .command("init")
  .description("Initialize the runtime and analyze project")
  .option("-p, --project <path>", "Project root path", process.cwd())
  .action(async (options) => {
    await initialize(options.project);
  });

program
  .command("doctor")
  .description("Audit the environment")
  .option("-p, --project <path>", "Project root path", process.cwd())
  .action(async (options) => {
    await doctor(options.project);
  });

program
  .command("status")
  .description("Show project status")
  .option("-p, --project <path>", "Project root path", process.cwd())
  .action(async (options) => {
    await status(options.project);
  });

program
  .command("audit")
  .description("Run project audit")
  .option("-p, --project <path>", "Project root path", process.cwd())
  .action(async (options) => {
    await audit(options.project);
  });

program
  .command("analyze")
  .description("Analyze project structure")
  .option("-p, --project <path>", "Project root path", process.cwd())
  .action(async (options) => {
    await analyze(options.project);
  });

program.parseAsync(process.argv);