// @file Contracts SDK - Agent contracts and domain interfaces
// Self-contained interfaces for agent contracts, independent of core package

// Agent Contract - the primary contract all agents must satisfy
export interface AgentContract {
  identity: string;
  mission: string;
  allowed_tasks: string[];
  forbidden_tasks: string[];
  required_knowledge: string[];
  preferred_tools: string[];
  decision_rules: string;
  workflow: string;
  input_contract: InputContract;
  output_contract: OutputContract;
  quality_gate: QualityGate;
}

// Input Contract
export interface InputContract {
  required: Record<string, string>;
  optional: Record<string, { default: unknown; description: string }>;
  validation: { strict: boolean; abort_on_first_error: boolean };
}

// Output Contract
export interface OutputContract {
  result_type: string;
  summary: string;
  evidence: EvidenceRecord[];
  status: "success" | "partial" | "failure";
}

// Evidence Record (contract-local, independent of core)
export interface EvidenceRecord {
  id: string;
  source: string;
  type: "file" | "terminal" | "build" | "test" | "security" | "api";
  content: string;
  timestamp: number;
  exit_code?: number;
  files_modified?: string[];
  files_created?: string[];
  files_deleted?: string[];
}

// Quality Gate (contract-local)
export interface QualityGate {
  name: string;
  passed: boolean;
  score: number;
  findings: Finding[];
  evidence: EvidenceRecord[];
  auto_fix_available: boolean;
}

// Finding (contract-local)
export interface Finding {
  id: string;
  category:
    | "architecture"
    | "code-quality"
    | "frontend"
    | "backend"
    | "database"
    | "security"
    | "testing"
    | "infrastructure"
    | "dependencies"
    | "performance"
    | "accessibility"
    | "documentation"
    | "deployment"
    | "observability"
    | "ai-readiness"
    | "market-readiness";
  severity: "critical" | "high" | "medium" | "low" | "info";
  title: string;
  description: string;
  evidence: string[];
  recommendation: string;
  auto_fix_available: boolean;
}

// Task Definition (contract-local)
export interface TaskDefinition {
  id: string;
  description: string;
  step: string;
  status: "pending" | "in_progress" | "completed" | "failed";
  attempt: number;
  max_attempts: number;
  started_at?: number;
  finished_at?: number;
  duration_ms?: number;
}

// Export types for convenience - these are the core domain types
