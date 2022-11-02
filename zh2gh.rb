$LOAD_PATH.unshift 'lib'
require 'dotenv'
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
  organization: ENV.fetch('Z2G_ORGANIZATION'),
  repo: ENV.fetch('Z2G_REPOSITORY'),
  number: ENV.fetch('Z2G_PROJECT'),
  label: ENV.fetch('Z2G_LABEL')
)

workspace = Zenhub::Workspace.new(
  token: ENV.fetch('ZH_TOKEN'),
  github_token: ENV.fetch('GH_TOKEN'),
  organization: ENV.fetch('Z2G_ORGANIZATION'),
  repo: ENV.fetch('Z2G_REPOSITORY'),
  id: ENV.fetch('Z2G_WORKSPACE_ID'),
  column_names_map: JSON.parse(ENV.fetch('Z2G_COLUMN_NAMES_MAP')),
  issue_numbers: project.issues_for_label.map { |issue| issue[:number] }
)

syncer = Syncer.new project: project, workspace: workspace
syncer.sync

puts 'Done.'
