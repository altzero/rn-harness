// lib/feature-list.ts — pure helpers over feature_list.json.
//
// This module is the layer-1 (pure TS) home for feature-list parsing. UI
// (layer 2, components/hooks) and routes (layer 3, app/) read through here
// — never JSON.parse(...) the file directly in a component.

export type FeatureStatus = 'todo' | 'in_progress' | 'blocked' | 'done';

export type Feature = {
  id: string;
  title: string;
  category?: string;
  description: string;
  verification: string[];
  status: FeatureStatus;
  passes: boolean;
  owner: string | null;
  commitSha: string | null;
  notes?: string;
};

export type FeatureList = {
  project: string;
  description?: string;
  states?: FeatureStatus[];
  wipLimit?: number;
  features: Feature[];
};

export type FeatureCounts = Record<FeatureStatus, number> & { total: number };

export function countByStatus(list: FeatureList): FeatureCounts {
  const counts: FeatureCounts = {
    todo: 0,
    in_progress: 0,
    blocked: 0,
    done: 0,
    total: list.features.length,
  };
  for (const f of list.features) counts[f.status]++;
  return counts;
}

export function nextActionable(list: FeatureList): Feature | null {
  return (
    list.features.find(f => f.status === 'in_progress') ??
    list.features.find(f => f.status === 'todo') ??
    null
  );
}

export function violatesWipLimit(list: FeatureList): boolean {
  const limit = list.wipLimit ?? 1;
  return list.features.filter(f => f.status === 'in_progress').length > limit;
}
