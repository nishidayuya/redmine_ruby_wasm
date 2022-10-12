require File.expand_path("../test_helper", __dir__)

class RedmineRubyWasm::IssuesTest < RedmineRubyWasm::ApplicationSystemTestCase
  RUBY_CODE_WITH_CODEBLOCK = <<~CODEBLOCK
    ```ruby
    %w[hello world!].map(&:capitalize).join(", ")
    ```
  CODEBLOCK
  RUBY_CODE_RESULT = '"Hello, World!"'

  let(:project) {
    Project.create!(name: "foo", identifier: "foo", trackers: [tracker])
  }
  let(:role) {
    Role.create!(name: "test role", permissions: %i[view_issues edit_issues])
  }
  let(:tracker) {
    Tracker.new(name: "Defect").tap do |tracker|
      tracker.default_status = IssueStatus.find_or_create_by!(name: "New")
      tracker.save!
    end
  }
  let(:user) {
    User.create!(
      login: "bob",
      firstname: "Bob",
      lastname: "Loblaw",
      password: "password",
      password_confirmation: "password",
      mail: "bob.loblaw@example.com",
    ).tap do |u|
      Member.create!(
        project: project,
        principal: u,
        roles: [role],
      )
    end
  }
  let(:issue_priority) { IssuePriority.find_or_create_by!(name: "Normal") }
  let(:issue_status) { IssueStatus.find_or_create_by!(name: "New") }
  let(:issue) {
    Issue.create!(
      project: project,
      subject: "bar",
      priority: issue_priority,
      tracker: tracker,
      author: user,
      status: issue_status
    )
  }

  setup do
    Setting[:text_formatting] = "markdown"

    login(user)
  end

  class CodeInIssue < self
    CODE_SELECTOR = "#content > .issue > .description > .wiki > pre > code"

    setup do
      issue.reload.update!(description: RUBY_CODE_WITH_CODEBLOCK)
    end

    test "display result when code is clicked" do
      visit(issue_path(issue))
      assert_css("*[role=dialog]", visible: :hidden) # wait for creating node

      first(CODE_SELECTOR).click
      assert_css("*[role=dialog]")
      assert_selector_inner_text_equal("#ruby-output-dialog", RUBY_CODE_RESULT)
    end
  end

  class CodeInComment < self
    CODE_SELECTOR = if Redmine::VERSION::MAJOR >= 5
                      "#history .note > .wiki > pre > code"
                    else
                      "#history .journal .wiki > pre > code"
                    end

    setup do
      issue.journals.create!(user: user, notes: RUBY_CODE_WITH_CODEBLOCK)
    end

    test "display result when code is clicked" do
      visit(issue_path(issue))
      assert_css("*[role=dialog]", visible: :hidden) # wait for creating node

      first(CODE_SELECTOR).click
      assert_css("*[role=dialog]")
      assert_selector_inner_text_equal("#ruby-output-dialog", RUBY_CODE_RESULT)
    end
  end

  private

  def login(user)
    visit(my_page_path)
    assert_equal("/login", current_path)
    within("#login-form form") do
      fill_in("username", with: user.login)
      fill_in("password", with: user.password)
      find("input[name=login]").click
    end
    assert_equal(my_page_path,  current_path)
  end
end
