$LOAD_PATH.unshift 'lib'
require 'github/project'
require 'zenhub/workspace'
require 'syncer'
require 'bundler/setup'
require 'async'
require 'async/semaphore'
require 'json'
require 'zenhub_ruby'

project = Github::Project.new(
  token: ENV.fetch('GH_TOKEN'),
  organization: 'department-of-veterans-affairs',
  repo: 'va.gov-team',
  number: 807,
  label: 'platform-tech-team-3'
)

workspace = Zenhub::Workspace.new(
  token: ENV.fetch('ZH_TOKEN'),
  github_token: ENV.fetch('GH_TOKEN'),
  organization: 'department-of-veterans-affairs',
  repo: 'va.gov-team',
  id: '6335ab9b1901b99243ce7601',
  column_names_map: {
    'Backlog' => ['Current Sprint', 'Upcoming Sprint', 'Backlog', 'Current Initiatives/Epics', 'Icebox'],
    'In Progress' => ['Blocked/Has Dependency', 'Review/QA', 'In Progress']
  },
  issue_numbers: project.issues_for_label.map { |issue| issue[:number] }
)

syncer = Syncer.new project: project, workspace: workspace
syncer.sync

puts 'Done.'
