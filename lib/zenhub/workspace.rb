module Zenhub
  class Workspace
    attr_accessor :token, :github_token, :organization, :repo, :id, :column_names_map, :issue_numbers

    def initialize(token:, github_token:, organization:, repo:, id:, column_names_map:, issue_numbers:)
      @token = token
      @github_token = github_token
      @organization = organization
      @repo = repo
      @id = id
      @column_names_map = column_names_map
      @issue_numbers = issue_numbers
    end

    def mapped_issues_by_status
      column_names_map.map do |column_name, zh_column_names|
        column_issues = zh_column_names.map { |zh_column_name| issues[zh_column_name] }
        [column_name, column_issues.flatten]
      end.to_h
    end

    def issues
      @issues ||= (
        $stdout.puts "Loading ZenHub Workspace..."
        response = client.workspace_data("#{organization}/#{repo}", id)

        response.body['pipelines'].map do |pipeline|
          ws_issues = pipeline['issues']
          ws_issues = ws_issues.select { |ws_issue| issue_numbers.include? ws_issue['issue_number'] }

          [pipeline['name'], ws_issues]
        end.to_h
      )
    end

    def client
      @client = ZenhubRuby::Client.new(token, github_token)
    end
  end
end
