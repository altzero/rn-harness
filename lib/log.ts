// lib/log.ts — single logger for the running app.
//
// Why this exists: harness engineering, lecture 11. When an agent debugs the
// running app, it needs structured, greppable signal — not ad-hoc
// `console.log`s scattered across the codebase. Route everything through
// here. Add tags so the agent can filter (`grep '\[ui-002\]' metro.log`).

type Level = 'debug' | 'info' | 'warn' | 'error';

const PREFIX: Record<Level, string> = {
  debug: '🪲',
  info: 'ℹ️',
  warn: '⚠️',
  error: '🛑',
};

function emit(level: Level, tag: string, msg: string, extra?: unknown) {
  const line = `${PREFIX[level]} [${tag}] ${msg}`;
  if (extra === undefined) {
    // eslint-disable-next-line no-console
    console[level === 'debug' ? 'log' : level](line);
  } else {
    // eslint-disable-next-line no-console
    console[level === 'debug' ? 'log' : level](line, extra);
  }
}

export const log = {
  debug: (tag: string, msg: string, extra?: unknown) => emit('debug', tag, msg, extra),
  info: (tag: string, msg: string, extra?: unknown) => emit('info', tag, msg, extra),
  warn: (tag: string, msg: string, extra?: unknown) => emit('warn', tag, msg, extra),
  error: (tag: string, msg: string, extra?: unknown) => emit('error', tag, msg, extra),
};
