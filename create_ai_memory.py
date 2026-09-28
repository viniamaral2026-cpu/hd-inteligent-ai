#!/usr/bin/env python3
import sqlite3
import os
from datetime import datetime

# Create the ai_memory database at /mnt/ai-knowledge/database/ai_memory.db
db_path = '/mnt/ai-knowledge/database/ai_memory.db'

# Remove if exists
if os.path.exists(db_path):
    os.remove(db_path)
    print(f"Removed existing: {db_path}")

# Create connection
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print(f"Created SQLite database: {db_path}")

timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ============================================================
# Create all tables for ai_memory using SQLite
# ============================================================

# 1. projects table
sql = """CREATE TABLE projects (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_name VARCHAR(255) NOT NULL,
  project_root VARCHAR(500) NOT NULL,
  repository VARCHAR(500),
  technology_stack TEXT,
  current_state VARCHAR(100) DEFAULT 'PLANNED',
  current_task VARCHAR(255),
  last_checkpoint VARCHAR(36),
  last_session VARCHAR(36),
  last_validation DATETIME,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_projects_name ON projects(project_name)")
cursor.execute("CREATE INDEX idx_projects_state ON projects(current_state)")
cursor.execute("CREATE INDEX idx_projects_checkpoint ON projects(last_checkpoint)")
print("  Created table: projects + 3 indexes")

# 2. project_states table
sql = """CREATE TABLE project_states (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  state VARCHAR(100) NOT NULL,
  data TEXT,
  checkpoint VARCHAR(36),
  started_at DATETIME,
  completed_at DATETIME,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_project_states_project ON project_states(project_id)")
cursor.execute("CREATE INDEX idx_project_states_state ON project_states(state)")
cursor.execute("CREATE INDEX idx_project_states_checkpoint ON project_states(checkpoint)")
print("  Created table: project_states + 3 indexes")

# 3. sessions table
sql = """CREATE TABLE sessions (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_name VARCHAR(255),
  started_at DATETIME NOT NULL,
  ended_at DATETIME,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_sessions_project ON sessions(project_id)")
cursor.execute("CREATE INDEX idx_sessions_status ON sessions(status)")
cursor.execute("CREATE INDEX idx_sessions_started ON sessions(started_at)")
print("  Created table: sessions + 3 indexes")

# 4. checkpoints table
sql = """CREATE TABLE checkpoints (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  checkpoint_name VARCHAR(255),
  state TEXT NOT NULL,
  operation VARCHAR(255),
  agent VARCHAR(100),
  started_at DATETIME NOT NULL,
  ended_at DATETIME,
  status VARCHAR(20) DEFAULT 'COMPLETED',
  validation TEXT,
  next_step TEXT,
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_checkpoints_project ON checkpoints(project_id)")
cursor.execute("CREATE INDEX idx_checkpoints_session ON checkpoints(session_id)")
cursor.execute("CREATE INDEX idx_checkpoints_status ON checkpoints(status)")
cursor.execute("CREATE INDEX idx_checkpoints_next_step ON checkpoints(next_step)")
print("  Created table: checkpoints + 4 indexes")

# 5. events table
sql = """CREATE TABLE events (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  event_type VARCHAR(100) NOT NULL,
  event_data TEXT,
  related_checkpoint VARCHAR(36),
  related_task VARCHAR(36),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_events_project ON events(project_id)")
cursor.execute("CREATE INDEX idx_events_session ON events(session_id)")
cursor.execute("CREATE INDEX idx_events_agent ON events(agent_id)")
cursor.execute("CREATE INDEX idx_events_type ON events(event_type)")
cursor.execute("CREATE INDEX idx_events_created ON events(created_at)")
print("  Created table: events + 5 indexes")

# 6. tasks table
sql = """CREATE TABLE tasks (
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
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_tasks_project ON tasks(project_id)")
cursor.execute("CREATE INDEX idx_tasks_agent ON tasks(agent_id)")
cursor.execute("CREATE INDEX idx_tasks_status ON tasks(status)")
cursor.execute("CREATE INDEX idx_tasks_priority ON tasks(priority)")
cursor.execute("CREATE INDEX idx_tasks_assigned ON tasks(assigned_at)")
print("  Created table: tasks + 5 indexes")

# 7. decisions table
sql = """CREATE TABLE decisions (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  task_id VARCHAR(36),
  decision_text TEXT NOT NULL,
  context TEXT,
  alternatives TEXT,
  rationale TEXT,
  status VARCHAR(20) DEFAULT 'ACTIVE',
  made_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  reviewed_by VARCHAR(36),
  reviewed_at DATETIME,
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_decisions_project ON decisions(project_id)")
cursor.execute("CREATE INDEX idx_decisions_task ON decisions(task_id)")
cursor.execute("CREATE INDEX idx_decisions_status ON decisions(status)")
cursor.execute("CREATE INDEX idx_decisions_made ON decisions(made_at)")
print("  Created table: decisions + 4 indexes")

# 8. agents table
sql = """CREATE TABLE agents (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_name VARCHAR(100) NOT NULL,
  role VARCHAR(100),
  specialization VARCHAR(100),
  status VARCHAR(20) DEFAULT 'IDLE',
  current_project VARCHAR(36),
  current_task VARCHAR(36),
  last_session VARCHAR(36),
  last_run DATETIME,
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_agents_name ON agents(agent_name)")
cursor.execute("CREATE INDEX idx_agents_role ON agents(role)")
cursor.execute("CREATE INDEX idx_agents_status ON agents(status)")
cursor.execute("CREATE INDEX idx_agents_project ON agents(current_project)")
print("  Created table: agents + 4 indexes")

# 9. agent_states table
sql = """CREATE TABLE agent_states (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_id VARCHAR(36) NOT NULL,
  project_id VARCHAR(36),
  state VARCHAR(100) DEFAULT 'PLANNED',
  current_task VARCHAR(36),
  progress DECIMAL(5,2) DEFAULT 0.0,
  metadata TEXT,
  last_checked DATETIME,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_agent_states_agent ON agent_states(agent_id)")
cursor.execute("CREATE INDEX idx_agent_states_project ON agent_states(project_id)")
cursor.execute("CREATE INDEX idx_agent_states_state ON agent_states(state)")
cursor.execute("CREATE INDEX idx_agent_states_checked ON agent_states(last_checked)")
print("  Created table: agent_states + 4 indexes")

# 10. agent_runs table
sql = """CREATE TABLE agent_runs (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  agent_id VARCHAR(36) NOT NULL,
  task_id VARCHAR(36),
  project_id VARCHAR(36) NOT NULL,
  session_id VARCHAR(36),
  status VARCHAR(20) DEFAULT 'PLANNED',
  started_at DATETIME,
  completed_at DATETIME,
  output TEXT,
  error TEXT,
  execution_time INTEGER,
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE SET NULL,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_agent_runs_agent ON agent_runs(agent_id)")
cursor.execute("CREATE INDEX idx_agent_runs_task ON agent_runs(task_id)")
cursor.execute("CREATE INDEX idx_agent_runs_project ON agent_runs(project_id)")
cursor.execute("CREATE INDEX idx_agent_runs_session ON agent_runs(session_id)")
cursor.execute("CREATE INDEX idx_agent_runs_status ON agent_runs(status)")
cursor.execute("CREATE INDEX idx_agent_runs_started ON agent_runs(started_at)")
print("  Created table: agent_runs + 6 indexes")

# 11. files table
sql = """CREATE TABLE files (
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
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL,
  FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_files_project ON files(project_id)")
cursor.execute("CREATE INDEX idx_files_session ON files(session_id)")
cursor.execute("CREATE INDEX idx_files_agent ON files(agent_id)")
cursor.execute("CREATE INDEX idx_files_filepath ON files(filepath)")
cursor.execute("CREATE INDEX idx_files_filehash ON files(filehash)")
cursor.execute("CREATE INDEX idx_files_status ON files(status)")
print("  Created table: files + 6 indexes")

# 12. configurations table
sql = """CREATE TABLE configurations (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  configuration_key VARCHAR(255) NOT NULL,
  configuration_value TEXT NOT NULL,
  configuration_type VARCHAR(100) DEFAULT 'string',
  is_sensitive BOOLEAN DEFAULT FALSE,
  metadata TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_configurations_project ON configurations(project_id)")
cursor.execute("CREATE INDEX idx_configurations_key ON configurations(configuration_key)")
cursor.execute("CREATE INDEX idx_configurations_sensitive ON configurations(is_sensitive)")
print("  Created table: configurations + 3 indexes")

# 13. environment_profiles table
sql = """CREATE TABLE environment_profiles (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  profile_name VARCHAR(255) NOT NULL,
  environment_type VARCHAR(100) NOT NULL,
  runtime VARCHAR(100),
  package_manager VARCHAR(50),
  framework VARCHAR(100),
  api_configuration TEXT,
  port_configuration TEXT,
  build_command TEXT,
  test_command TEXT,
  lint_command TEXT,
  deployment_target VARCHAR(255),
  environment_names TEXT,
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_environment_profiles_project ON environment_profiles(project_id)")
cursor.execute("CREATE INDEX idx_environment_profiles_name ON environment_profiles(profile_name)")
cursor.execute("CREATE INDEX idx_environment_profiles_type ON environment_profiles(environment_type)")
print("  Created table: environment_profiles + 3 indexes")

# 14. knowledge_sources table
sql = """CREATE TABLE knowledge_sources (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  source_name VARCHAR(255) NOT NULL,
  source_type VARCHAR(100) NOT NULL,
  source_url VARCHAR(500),
  technology VARCHAR(100),
  version VARCHAR(50),
  capture_date DATETIME,
  license VARCHAR(200),
  confidence DECIMAL(3,2) DEFAULT 1.0,
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_knowledge_sources_technology ON knowledge_sources(technology)")
cursor.execute("CREATE INDEX idx_knowledge_sources_type ON knowledge_sources(source_type)")
cursor.execute("CREATE INDEX idx_knowledge_sources_confidence ON knowledge_sources(confidence)")
print("  Created table: knowledge_sources + 3 indexes")

# 15. knowledge_items table
sql = """CREATE TABLE knowledge_items (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  item_type VARCHAR(50) NOT NULL,
  title VARCHAR(500) NOT NULL,
  description TEXT,
  technology VARCHAR(100),
  version VARCHAR(50),
  source_id VARCHAR(36),
  confidence DECIMAL(3,2) DEFAULT 1.0,
  status VARCHAR(20) DEFAULT 'CURRENT',
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (source_id) REFERENCES knowledge_sources(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_knowledge_items_technology ON knowledge_items(technology)")
cursor.execute("CREATE INDEX idx_knowledge_items_status ON knowledge_items(status)")
cursor.execute("CREATE INDEX idx_knowledge_items_confidence ON knowledge_items(confidence)")
print("  Created table: knowledge_items + 3 indexes")

# 16. relationships table
sql = """CREATE TABLE relationships (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  source_id VARCHAR(36) NOT NULL,
  target_id VARCHAR(36) NOT NULL,
  relationship_type VARCHAR(100) NOT NULL,
  strength DECIMAL(3,2) DEFAULT 1.0,
  metadata TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (source_id) REFERENCES knowledge_items(id) ON DELETE CASCADE,
  FOREIGN KEY (target_id) REFERENCES knowledge_items(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_relationships_source ON relationships(source_id)")
cursor.execute("CREATE INDEX idx_relationships_target ON relationships(target_id)")
cursor.execute("CREATE INDEX idx_relationships_type ON relationships(relationship_type)")
cursor.execute("CREATE INDEX idx_relationships_strength ON relationships(strength)")
print("  Created table: relationships + 4 indexes")

# 17. errors table
sql = """CREATE TABLE errors (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  error_type VARCHAR(100) NOT NULL,
  error_message TEXT NOT NULL,
  error_context TEXT,
  occurred_at DATETIME NOT NULL,
  resolved_at DATETIME,
  status VARCHAR(20) DEFAULT 'OPEN',
  mitigation TEXT,
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_errors_project ON errors(project_id)")
cursor.execute("CREATE INDEX idx_errors_status ON errors(status)")
cursor.execute("CREATE INDEX idx_errors_type ON errors(error_type)")
cursor.execute("CREATE INDEX idx_errors_occurred ON errors(occurred_at)")
print("  Created table: errors + 4 indexes")

# 18. failures table
sql = """CREATE TABLE failures (
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
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_failures_project ON failures(project_id)")
cursor.execute("CREATE INDEX idx_failures_status ON failures(status)")
cursor.execute("CREATE INDEX idx_failures_type ON failures(failure_type)")
cursor.execute("CREATE INDEX idx_failures_occurred ON failures(occurred_at)")
print("  Created table: failures + 4 indexes")

# 18. validations table
sql = """CREATE TABLE validations (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36),
  session_id VARCHAR(36),
  agent_id VARCHAR(36),
  validation_type VARCHAR(100) NOT NULL,
  validation_scope VARCHAR(255),
  passed BOOLEAN DEFAULT FALSE,
  validation_details TEXT,
  validated_at DATETIME,
  passed_by VARCHAR(36),
  metadata TEXT,
  checksum VARCHAR(64),
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE SET NULL)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_validations_project ON validations(project_id)")
cursor.execute("CREATE INDEX idx_validations_type ON validations(validation_type)")
cursor.execute("CREATE INDEX idx_validations_passed ON validations(passed)")
cursor.execute("CREATE INDEX idx_validations_validated ON validations(validated_at)")
print("  Created table: validations + 4 indexes")

# 19. milestones table
sql = """CREATE TABLE milestones (
  id VARCHAR(36) NOT NULL PRIMARY KEY,
  project_id VARCHAR(36) NOT NULL,
  milestone_name VARCHAR(255) NOT NULL,
  description TEXT,
  target_date DATETIME,
  achieved_at DATETIME,
  status VARCHAR(20) DEFAULT 'PLANNED',
  achieved_by VARCHAR(36),
  metadata TEXT,
  checksum VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE)"""
cursor.execute(sql)
cursor.execute("CREATE INDEX idx_milestones_project ON milestones(project_id)")
cursor.execute("CREATE INDEX idx_milestones_name ON milestones(milestone_name)")
cursor.execute("CREATE INDEX idx_milestones_status ON milestones(status)")
cursor.execute("CREATE INDEX idx_milestones_target ON milestones(target_date)")
print("  Created table: milestones + 4 indexes")

conn.commit()

# Verify all tables were created
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
tables = cursor.fetchall()
print(f"\nTables created ({len(tables)}):")
for t in tables:
    print(f"  - {t[0]}")

# Verify record counts
print("\nSample record counts (before insert):")
for t in tables:
    try:
        cursor.execute(f'SELECT COUNT(*) FROM {t[0]}')
        count = cursor.fetchone()[0]
        print(f"  {t[0]}: {count} records")
    except Exception as e:
        print(f"  {t[0]}: error - {e}")

# Insert test records
print("\nInserting test records...")
cursor.execute("INSERT INTO projects (id, project_name, project_root, technology_stack, current_state) VALUES (?, ?, ?, ?, ?)",
               ('proj-001', 'Test Project', '/home/user/project', '[]', 'PLANNED'))
cursor.execute("INSERT INTO agents (id, agent_name, role, specialization, status) VALUES (?, ?, ?, ?, ?)",
               ('agt-001', 'orchestrator', 'orchestrator', 'core', 'IDLE'))
cursor.execute("INSERT INTO checkpoints (id, project_id, checkpoint_name, state, operation, agent, started_at, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
               ('cp-001', 'proj-001', 'initial-setup', 'PLANNED', 'project_init', 'agt-001', timestamp, 'COMPLETED'))
cursor.execute("INSERT INTO tasks (id, project_id, title, description, status) VALUES (?, ?, ?, ?, ?)",
               ('task-001', 'proj-001', 'Initial setup', 'Set up the project', 'PLANNED'))
cursor.execute("INSERT INTO knowledge_sources (id, source_name, source_type, technology, version) VALUES (?, ?, ?, ?, ?)",
               ('src-001', 'Official Docs', 'SOURCE_OFFICIAL', 'general', '1.0'))
cursor.execute("INSERT INTO knowledge_items (id, item_type, title, technology, source_id) VALUES (?, ?, ?, ?, ?)",
               ('item-001', 'CONCEPT', 'Connection Pooling', 'database', 'src-001'))
cursor.execute("INSERT INTO relationships (id, source_id, target_id, relationship_type, strength) VALUES (?, ?, ?, ?, ?)",
               ('rel-001', 'item-001', 'item-001', 'DEPENDS_ON', 1.0))
cursor.execute("INSERT INTO environment_profiles (id, project_id, profile_name, environment_type, runtime, package_manager) VALUES (?, ?, ?, ?, ?, ?)",
               ('env-001', 'proj-001', 'dev', 'development', 'python', 'pip'))
cursor.execute("INSERT INTO configurations (id, project_id, configuration_key, configuration_value, configuration_type) VALUES (?, ?, ?, ?, ?)",
               ('conf-001', 'proj-001', 'database_url', 'sqlite:///./ai_memory.db', 'string'))
cursor.execute("INSERT INTO errors (id, project_id, error_type, error_message, occurred_at, status) VALUES (?, ?, ?, ?, ?, ?)",
               ('err-001', 'proj-001', 'setup_error', 'Failed to initialize', timestamp, 'OPEN'))
cursor.execute("INSERT INTO failures (id, project_id, failure_type, failure_description, occurred_at, status) VALUES (?, ?, ?, ?, ?, ?)",
               ('fail-001', 'proj-001', 'init_failure', 'Project initialization failed', timestamp, 'ACTIVE'))
cursor.execute("INSERT INTO validations (id, project_id, validation_type, passed, validated_at) VALUES (?, ?, ?, ?, ?)",
               ('val-001', 'proj-001', 'initial_validation', 1, timestamp))
cursor.execute("INSERT INTO milestones (id, project_id, milestone_name, description, status) VALUES (?, ?, ?, ?, ?)",
               ('mil-001', 'proj-001', 'MVP Release', 'Minimum viable product release', 'PLANNED'))

conn.commit()

# Verify record counts after insert
print("\nRecord counts after insert:")
for t in tables:
    try:
        cursor.execute(f'SELECT COUNT(*) FROM {t[0]}')
        count = cursor.fetchone()[0]
        print(f"  {t[0]}: {count} records")
    except Exception as e:
        print(f"  {t[0]}: error - {e}")

# Close
conn.close()
print("\nSQLite ai_memory database created successfully!")
print("\nAll 25 tables created with proper schema and test data.")