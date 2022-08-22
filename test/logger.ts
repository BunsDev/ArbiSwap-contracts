export class Logger {
  log = (...data: any[]) => {
    console.log(...data);
  };
}

export const logger = new Logger();
