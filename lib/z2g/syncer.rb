module Z2g
  class Syncer
    attr_accessor :project, :workspace

    def initialize(project:, workspace:)
      @project = project
      @workspace = workspace
    end

    def sync_to_project
      workspace_issues.keys.each do |column_name|
        ws_issues_for_column = workspace_issues[column_name]
        ws_issue_numbers_for_column = ws_issues_for_column.map { |ws_issue| ws_issue['issue_number'] }

        sort_in_sync =
          project.issues_by_status[column_name]&.map { |pi| pi[:content][:number] } ==
          ws_issue_numbers_for_column
        estimates_in_sync =
          ws_issues_for_column&.map { |wi| wi['estimate']['value'] rescue nil } ==
            project.issues_by_status[column_name]&.map do |pi|
              pi[:fieldValues][:nodes].find { |node| node[:field][:name] == "Points" rescue nil }[:number].to_i rescue nil
            end

        if sort_in_sync && estimates_in_sync
          $stdout.puts %Q{"#{column_name}" is in sync.}
          next
        end

        $stdout.puts %Q{Syncing "#{column_name}"...}
        project.remove_issues ids: project.issue_ids_for_column(column_name)

        ws_issues_for_column.each do |ws_issue|
          issue_content_id = project.issue_node_id ws_issue['issue_number']
          issue_node_id = project.add_issue(issue_id: issue_content_id)[:data][:addProjectV2ItemById][:item][:id]

          status_field = project.node_for_field 'Status'
          status_option_id = status_field[:options].find { |option| option[:name] == column_name }[:id]

          $stdout.puts "Adding ##{ws_issue['issue_number']} to #{column_name}."
          project.set_issue_field(issue_id: issue_node_id, field_node_id: status_field[:id], option_node_id: status_option_id)

          if ws_issue['estimate']
            points_field = project.node_for_field 'Points'
            project.set_issue_field(issue_id: issue_node_id, field_node_id: points_field[:id], value: ws_issue['estimate']['value'])
          end
        end
      end
    end

    private

    def workspace_issues
      @workspace_issues ||= workspace.mapped_issues_by_status
    end
  end
end
