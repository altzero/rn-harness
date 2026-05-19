import {
  countByStatus,
  nextActionable,
  violatesWipLimit,
  type FeatureList,
} from '../lib/feature-list';

const list: FeatureList = {
  project: 'test',
  wipLimit: 1,
  features: [
    {
      id: 'a',
      title: 'A',
      description: '',
      verification: ['x'],
      status: 'done',
      passes: true,
      owner: null,
      commitSha: 'abc',
    },
    {
      id: 'b',
      title: 'B',
      description: '',
      verification: ['x'],
      status: 'in_progress',
      passes: false,
      owner: 'claude',
      commitSha: null,
    },
    {
      id: 'c',
      title: 'C',
      description: '',
      verification: ['x'],
      status: 'todo',
      passes: false,
      owner: null,
      commitSha: null,
    },
  ],
};

describe('countByStatus', () => {
  it('returns one count per status plus total', () => {
    expect(countByStatus(list)).toEqual({
      todo: 1,
      in_progress: 1,
      blocked: 0,
      done: 1,
      total: 3,
    });
  });
});

describe('nextActionable', () => {
  it('prefers in_progress over todo', () => {
    expect(nextActionable(list)?.id).toBe('b');
  });

  it('falls back to first todo when nothing is in_progress', () => {
    const noWip = {
      ...list,
      features: list.features.map(f =>
        f.status === 'in_progress' ? { ...f, status: 'todo' as const } : f,
      ),
    };
    expect(nextActionable(noWip)?.id).toBe('b');
  });

  it('returns null when nothing is actionable', () => {
    const allDone: FeatureList = {
      ...list,
      features: list.features.map(f => ({
        ...f,
        status: 'done' as const,
        passes: true,
        commitSha: 'x',
      })),
    };
    expect(nextActionable(allDone)).toBeNull();
  });
});

describe('violatesWipLimit', () => {
  it('returns false at the limit', () => {
    expect(violatesWipLimit(list)).toBe(false);
  });

  it('returns true above the limit', () => {
    const twoInProgress: FeatureList = {
      ...list,
      features: list.features.map(f => ({ ...f, status: 'in_progress' as const })),
    };
    expect(violatesWipLimit(twoInProgress)).toBe(true);
  });
});
