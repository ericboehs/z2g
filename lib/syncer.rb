class Syncer
  attr_accessor :project, :workspace

  def initialize(project:, workspace:)
    @project = project
    @workspace = workspace
  end

  def sync
    workspace_issues.keys.each do |column_name|
      column_issues = workspace_issues[column_name]
      if project.issue_numbers_by_status[column_name] == column_issues
        $stdout.puts %Q{"#{column_name}" is in sync.}
        next
      end

      $stdout.puts %Q{Syncing "#{column_name}"...}
      project.remove_issues ids: project.issue_ids_for_column(column_name)

      column_issues.each do |issue_number|
        issue_content_id = project.issue_node_id issue_number
        issue_node_id = project.add_issue(issue_id: issue_content_id)[:data][:addProjectV2ItemById][:item][:id]

        status_field = project.node_for_field 'Status'
        status_option_id = status_field[:options].find { |option| option[:name] == column_name }[:id]

        $stdout.puts "Adding ##{issue_number} to #{column_name}."
        project.set_issue_field(issue_id: issue_node_id, field_node_id: status_field[:id], option_node_id: status_option_id)
      end
    end
  end

  private

  def workspace_issues
    @workspace_issues ||= workspace.mapped_issue_numbers_by_status
  end
end
