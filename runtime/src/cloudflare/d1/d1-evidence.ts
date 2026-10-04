/**
 * D1 Integration for NoteAgents Evidence Engine
 * Armazenamento estruturado de evidências e scores de readiness
 */
export interface EvidenceRecord {
  id: string;
  type: 'build' | 'test' | 'audit' | 'security' | 'migration';
  status: 'passed' | 'failed' | 'skipped' | 'pending';
  description: string;
  details: Record<string, any>;
  timestamp: string;
  project: string;
  metadata: Record<string, any>;
}

export interface ReadinessScore {
  overall: 'high' | 'medium' | 'low' | 'critical';
  build: 'passed' | 'failed' | 'not_run';
  tests: 'passed' | 'failed' | 'not_run';
  lint: 'passed' | 'failed' | 'not_run';
  security: 'passed' | 'failed' | 'not_run';
  lastUpdated: string;
  history: ReadinessScoreHistoryEntry[];
}

export interface ReadinessScoreHistoryEntry {
  timestamp: string;
  overall: 'high' | 'medium' | 'low' | 'critical';
  trigger: 'manual' | 'scheduled' | 'failed' | 'deploy';
}

export class D1EvidenceEngine {
  private db: any;

  constructor(db: any) {
    this.db = db;
  }

  /**
   * Registrar uma nova evidência
   */
  async recordEvidence(
    type: EvidenceRecord['type'],
    status: EvidenceRecord['status'],
    description: string,
    details: Record<string, any> = {},
    project: string
  ): Promise<EvidenceRecord> {
    const record: EvidenceRecord = {
      id: crypto.randomUUID(),
      type,
      status,
      description,
      details,
      timestamp: new Date().toISOString(),
      project,
      metadata: {}
    };

    await this.db.exec(
      `INSERT INTO evidence (id, type, status, description, details, timestamp, project, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [record.id, record.type, record.status, record.description, JSON.stringify(record.details), record.timestamp, record.project, JSON.stringify(record.metadata)]
    );

    return record;
  }

  /**
   * Obter evidências por tipo e status
   */
  async getEvidenceByType(
    type: EvidenceRecord['type'],
    status?: EvidenceRecord['status']
  ): Promise<EvidenceRecord[]> {
    let sql = 'SELECT * FROM evidence WHERE type = ?';
    const params: any[] = [type];

    if (status) {
      sql += ' AND status = ?';
      params.push(status);
    }

    const result = await this.db.exec(sql, params);
    return result.results || [];
  }

  /**
   * Atualizar score de readiness
   */
  async updateReadinessScore(score: ReadinessScore): Promise<void> {
    const historyJson = score.history ? JSON.stringify(score.history) : '[]';

    await this.db.exec(
      `INSERT INTO readiness_score (overall, build, tests, lint, security, last_updated, history) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [score.overall, score.build, score.tests, score.lint, score.security, score.lastUpdated, historyJson]
    );
  }

  /**
   * Obter score de readiness atual
   */
  async getCurrentReadiness(): Promise<ReadinessScore | null> {
    const result = await this.db.exec(
      'SELECT * FROM readiness_score ORDER BY last_updated DESC LIMIT 1'
    );

    if (!result.results || !result.results.length) return null;

    const row = result.results[0];
    return {
      overall: row.overall,
      build: row.build,
      tests: row.tests,
      lint: row.lint,
      security: row.security,
      lastUpdated: row.last_updated,
      history: row.history ? JSON.parse(row.history) : []
    };
  }

  /**
   * Obter histórico de scores
   */
  async getReadinessHistory(): Promise<ReadinessScoreHistoryEntry[]> {
    const result = await this.db.exec(
      'SELECT * FROM readiness_score ORDER BY last_updated DESC'
    );

    if (!result.results || !result.results.length) return [];

    return result.results.map((r: any) => ({
      timestamp: r.last_updated,
      overall: r.overall,
      trigger: r.history ? JSON.parse(r.history)[0]?.trigger || 'manual' : 'manual'
    }));
  }

  /**
   * Registrar evento de deployment
   */
  async recordDeploymentEvent(
    deployId: string,
    status: 'started' | 'completed' | 'failed',
    notes: string = ''
  ): Promise<void> {
    const now = new Date().toISOString();

    await this.db.exec(
      `INSERT INTO deployment_events (id, status, notes, timestamp) VALUES (?, ?, ?, ?)`,
      [deployId, status, notes, now]
    );
  }
}