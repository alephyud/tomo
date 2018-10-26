require "forwardable"

module Jam
  class Remote
    extend Forwardable
    def_delegators :ssh, :host
    def_delegators :shell_command, :chdir, :env, :umask

    include Jam::DSL

    def initialize(ssh, helpers: [])
      @ssh = ssh
      @shell_command = ShellCommand.new
      helpers.each { |mod| extend(mod) }
      freeze
    end

    def attach(*command, echo: true)
      full_command = shell_command.build(*command)
      log(full_command, echo) if echo
      ssh.ssh_exec(*full_command)
    end

    # rubocop:disable Metrics/ParameterLists
    def run(*command,
            echo: true,
            silent: false,
            pty: false,
            raise_on_error: true)
      full_command = shell_command.build(*command)
      log(full_command, echo) if echo
      ssh.ssh_subprocess(
        *full_command,
        silent: silent,
        pty: pty,
        raise_on_error: raise_on_error
      )
    end
    # rubocop:enable Metrics/ParameterLists

    private

    attr_reader :ssh, :shell_command

    def log(command, echo)
      command_string = echo == true ? Array(command).join(" ") : echo
      puts "\e[0;90;49m#{host}$ #{command_string}\e[0m"
    end
  end
end