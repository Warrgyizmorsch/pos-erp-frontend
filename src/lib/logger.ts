const isProduction = process.env.NODE_ENV === "production";

export const logger = {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  log: (...args: any[]) => {
    if (!isProduction) {
      console.log(...args);
    }
  },
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  warn: (...args: any[]) => {
    if (!isProduction) {
      console.warn(...args);
    }
  },
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  error: (...args: any[]) => {
    // We typically want to keep error logging in production
    console.error(...args);
  },
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  info: (...args: any[]) => {
    if (!isProduction) {
      console.info(...args);
    }
  },
};
