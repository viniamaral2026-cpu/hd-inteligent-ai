CREATE DATABASE IF NOT EXISTS ai_memory DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci;
USE ai_memory;

-- projects table
CREATE TABLE projects (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_name VARCHAR(255) NOT NULL,
  project_root VARCHAR(500) NOT NULL,
  repository VARCHAR(500),
  technology_stack JSON,
  current_state VARCHAR(100) DEFAULT 'PLANNED',
  current_task VARCHAR(255),
  last_checkpoint VARCHAR(36),
  last_session VARCHAR(36),
  last_validation DATETIME,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_project_name (project_name),
  INDEX idx_current_state (current_state),
  INDEX idx_last_checkpoint (last_checkpoint)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- project_states table
CREATE TABLE project_states (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  state VARCHAR(100) NOT NULL,
  data JSON,
  checkpoint VARCHAR(36),
  started_at DATETIME,
  completed_at DATETIME,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_project_id (project_id),
  INDEX idx_state (state),
  INDEX idx_checkpoint (checkpoint)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- sessions table
CREATE TABLE sessions (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_name VARCHAR(255),
  started_at DATETIME NOT NULL,
  ended_at DATETIME,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_project_id (project_id),
  INDEX idx_status (status),
  INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- checkpoints table
CREATE TABLE checkpoints (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  checkpoint_name VARCHAR(255),
  state JSON NOT NULL,
  operation VARCHAR(255),
  agent VARCHAR(100),
  started_at DATETIME NOT NULL,
  ended_at DATETIME,
  status VARCHAR(20) DEFAULT 'COMPLETED',
  validation TEXT,
  next_step TEXT,
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_checkpoint_name (checkpoint_name),
  INDEX idx_status (status),
  INDEX idx_started_at (started_at)
) ENGENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- events table
CREATE TABLE events (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  event_type VARCHAR(100) NOT NULL,
  event_data JSON,
  related_checkpoint VARCHAR(36),
  related_task VARCHAR(36),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_event_type (event_type),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- tasks table
CREATE TABLE tasks (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  title VARCHAR(500) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'PLANNED',
  priority VARCHAR(20) DEFAULT 'MEDIUM',
  agent_id VARCHAR(36),
  assigned_at DATETIME,
  started_at DATETIME,
  completed_at DATETIME,
  result TEXT,
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_status (status),
  INDEX idx_priority (priority),
  INDEX idx_assigned_at (assigned_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- decisions table
CREATE TABLE decisions (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  task_id VARCHAR(36),
  decision_text TEXT NOT NULL,
  context JSON,
  alternatives JSON,
  rationale TEXT,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  made_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  reviewed_by VARCHAR(36),
  reviewed_at DATETIME,
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
  FOREIGN KEY (reviewed_by) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_task_id (task_id),
  INDEX idx_status (status),
  INDEX idx_made_at (made_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- agents table
CREATE TABLE agents (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_name VARCHAR(100) NOT NULL,
  role VARCHAR(100),
  specialization VARCHAR(100),
  status VARCHAR(20) DEFAULT 'IDLE',
  current_project VARCHAR(36),
  current_task VARCHAR(36),
  last_session VARCHAR(36),
  last_run DATETIME,
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_agent_name (agent_name),
  INDEX idx_role (role),
  INDEX idx_status (status),
  INDEX idx_current_project (current_project)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- agent_states table
CREATE TABLE agent_states (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_id VARCHAR(36) NOT NULL,
  project_id VARCHAR(36),
  state VARCHAR(100) DEFAULT 'PLANNED',
  current_task VARCHAR(36),
  progress DECIMAL(5,2) DEFAULT 0.0,
  metadata JSON,
  last_checked DATETIME,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_agent_id (agent_id),
  INDEX idx_project_id (project_id),
  INDEX idx_state (state),
  INDEX idx_last_checked (last_checked)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- agent_runs table
CREATE TABLE agent_runs (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_id VARCHAR(36) NOT NULL,
  task_id VARCHAR(36),
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  status VARCHAR(20) DEFAULT 'PLANNED',
  started_at DATETIME,
  completed_at DATETIME,
  output JSON,
  error TEXT,
  execution_time INTEGER,
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  INDEX idx_agent_id (agent_id),
  INDEX idx_task_id (task_id),
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_status (status),
  INDEX idx_started_at (started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- files table
CREATE TABLE files (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  filepath VARCHAR(500) NOT NULL,
  filename VARCHAR(255) NOT NULL,
  filehash VARCHAR(64) NOT NULL,
  filetype VARCHAR(100),
  size INTEGER,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_filepath (filepath),
  INDEX idx_filehash (filehash),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- configurations table
CREATE TABLE configurations (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  configuration_key VARCHAR(255) NOT NULL,
  configuration_value TEXT NOT NULL,
  configuration_type VARCHAR(100) DEFAULT 'string',
  is_sensitive BOOLEAN DEFAULT FALSE,
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_project_id (project_id),
  INDEX idx_configuration_key (configuration_key),
  INDEX idx_is_sensitive (is_sensitive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- environment_profiles table
CREATE TABLE environment_profiles (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  profile_name VARCHAR(255) NOT NULL,
  environment_type VARCHAR(100) NOT NULL,
  runtime VARCHAR(100),
  package_manager VARCHAR(50),
  framework VARCHAR(100),
  api_configuration JSON,
  port_configuration JSON,
  build_command TEXT,
  test_command TEXT,
  lint_command TEXT,
  deployment_target VARCHAR(255),
  environment_names JSON,
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_project_id (project_id),
  INDEX idx_profile_name (profile_name),
  INDEX idx_environment_type (environment_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- knowledge_sources table
CREATE TABLE knowledge_sources (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  source_name VARCHAR(255) NOT NULL,
  source_type VARCHAR(100) NOT NULL,
  source_url VARCHAR(500),
  technology VARCHAR(100),
  version VARCHAR(50),
  capture_date DATETIME,
  license VARCHAR(200),
  confidence DECIMAL(3,2) DEFAULT 1.0,
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_technology (technology),
  INDEX idx_source_type (source_type),
  INDEX idx_confidence (confidence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- knowledge_items table (also exists in knowledge.db, preserved separately)
CREATE TABLE knowledge_items (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  item_type VARCHAR(50) NOT NULL,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  technology VARCHAR(100),
  version VARCHAR(50),
  source_id VARCHAR(36),
  confidence DECIMAL(3,2) DEFAULT 1.0,
  status VARCHAR(20) DEFAULT 'CURRENT',
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (source_id) REFERENCES knowledge_sources(id) ON DELETE SET NULL,
  INDEX idx_item_type (item_type),
  INDEX idx_technology (technology),
  INDEX idx_status (status),
  INDEX idx_confidence (confidence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- relationships table
CREATE TABLE relationships (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  source_id VARCHAR(36) NOT NULL,
  target_id VARCHAR(36) NOT NULL,
  relationship_type VARCHAR(100) NOT NULL,
  strength DECIMAL(3,2) DEFAULT 1.0,
  metadata JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (source_id) REFERENCES knowledge_items(id) ON DELETE CASCADE,
  FOREIGN KEY (target_id) REFERENCES knowledge_items(id) ON DELETE CASCADE,
  INDEX idx_source_id (source_id),
  INDEX idx_target_id (target_id),
  INDEX idx_relationship_type (relationship_type),
  INDEX idx_strength (strength)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- errors table
CREATE TABLE errors (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  error_type VARCHAR(100) NOT NULL,
  error_message TEXT NOT NULL,
  error_context JSON,
  occurred_at DATETIME NOT NULL,
  resolved_at DATETIME,
  status VARCHAR(20) DEFAULT 'OPEN',
  mitigation TEXT,
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_error_type (error_type),
  INDEX idx_status (status),
  INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- failures table
CREATE TABLE failures (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  failure_type VARCHAR(100) NOT NULL,
  failure_description TEXT NOT NULL,
  occurred_at DATETIME NOT NULL,
  resolved BOOLEAN DEFAULT FALSE,
  resolution_text TEXT,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_failure_type (failure_type),
  INDEX idx_status (status),
  INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- validations table
CREATE TABLE validations (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  validation_type VARCHAR(100) NOT NULL,
  validation_scope VARCHAR(255),
  passed BOOLEAN DEFAULT FALSE,
  validation_details JSON,
  validated_at DATETIME,
  passed_by VARCHAR(36),
  metadata JSON,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL,
  INDEX idx_project_id (project_id),
  INDEX idx_session_id (session_id),
  INDEX idx_agent_id (agent_id),
  INDEX idx_validation_type (validation_type),
  INDEX idx_passed (passed),
  INDEX idx_validated_at (validated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- milestones table
CREATE TABLE milestones (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  milestone_name VARCHAR(255) NOT NULL,
  description TEXT,
  target_date DATETIME,
  achieved_at DATETIME,
  status VARCHAR(20) DEFAULT 'PLANNED',
  achieved_by VARCHAR(36),
  metadata JSON,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  INDEX idx_project_id (project_id),
  INDEX idx_milestone_name (milestone_name),
  INDEX idx_status (status),
  INDEX idx_target_date (target_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes for performance
CREATE INDEX idx_projects_current_state ON projects(current_state);
CREATE INDEX idx_projects_last_checkpoint ON projects(last_checkpoint);
CREATE INDEX idx_checkpoints_project_id ON checkpoints(project_id);
CREATE INDEX idx_checkpoints_status ON checkpoints(status);
CREATE INDEX idx_checkpoints_next_step ON checkpoints(next_step);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_agent_id ON tasks(agent_id);
CREATE INDEX idx_decisions_project_id ON decisions(project_id);
CREATE INDEX idx_agents_current_project ON agents(current_project);
CREATE INDEX idx_agents_status ON agents(status);
CREATE INDEX idx_agent_states_agent_id ON agent_states(agent_id);
CREATE INDEX idx_agent_states_project_id ON agent_states(project_id);
CREATE INDEX idx_knowledge_sources_technology ON knowledge_sources(technology);
CREATE INDEX idx_knowledge_items_technology ON knowledge_items(technology);
CREATE INDEX idx_knowledge_items_status ON knowledge_items(status);
CREATE INDEX idx_relationships_source ON relationships(source_id);
CREATE INDEX idx_relationships_target ON relationships(target_id);
CREATE INDEX idx_errors_project_id ON errors(project_id);
CREATE INDEX idx_errors_status ON errors(status);
CREATE INDEX idx_failures_project_id ON failures(project_id);
CREATE INDEX idx_validations_project_id ON validations(project_id);
CREATE INDEX idx_milestones_project_id ON milestones(project_id);
CREATE INDEX idx_environment_profiles_project ON environment_profiles(project_id);
CREATE INDEX idx_environment_profiles_name ON environment_profiles(profile_name);

-- Trigger to update projects.updated_at
DELIMITER //
CREATE TRIGGER projects_updated_at
BEFORE UPDATE ON projects
FOR EACH ROW
BEGIN
  SET NEW.updated_at = CURRENT_TIMESTAMP;
END;
// DELIMITER ;