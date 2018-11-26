require "forwardable"

module Jam
  class Project
    extend Forwardable

    autoload :ExecutionPlan, "jam/project/execution_plan"
    autoload :Loader, "jam/project/loader"
    autoload :JsonParser, "jam/project/json_parser"

    def_delegators :framework, :settings, :tasks

    def initialize(framework, deploy_tasks, host)
      @framework = framework
      @deploy_tasks = deploy_tasks
      @host = host
    end

    def build_deploy_plan
      ExecutionPlan.new(framework, host, deploy_tasks)
    end

    def build_run_plan(task_name)
      ExecutionPlan.new(framework, host, [task_name])
    end

    private

    attr_reader :framework, :deploy_tasks, :host
  end
end