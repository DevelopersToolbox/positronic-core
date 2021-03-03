#
# Description should go here
#
class CaretakerCore
    #
    # We want to create everything as a class/static method
    #
    class << self
        private

        #
        # Are we running this from within a git repo??
        #
        def check_for_git_repo
            raise StandardError.new('Directory does not contain a git repository - aborting') unless execute_command('git rev-parse --show-toplevel')
        end

        #
        # Has a remote origin been setup?
        #
        def git_remote_origin
            origin = execute_command('git config --get remote.origin.url')
            raise StandardError.new('remote.origin.url is not set - aborting') unless origin

            origin = origin.delete_suffix('.git') if origin.end_with?('.git')
            origin.gsub(':', '/').gsub('git@', 'https://') if origin.start_with?('git@')
        end

        #
        # comment to go here
        #
        def retrieve_git_log_entries
            log_entries = execute_command("git log --first-parent --oneline --pretty=format:'%h|%H|%d|%s|%cs'")

            return false unless log_entries

            log_entries.split("\n")
        end

        #
        # comment to go here
        #
        def get_child_messages(parent)
            body = execute_command("git log --pretty=format:'%b' -n 1 #{parent}")

            body.split("\n").each { |line| line.sub!('*', '') }.map(&:strip).reject(&:empty?).map { |line| line } unless body.empty?
        end

        #
        # stuff
        #
        def git_repo_details
            origin = git_remote_origin
            uri = URI.parse(origin)

            slug = uri.path.delete_prefix('/')
            repository = "https://#{uri.host}/#{slug}"

            [repository, slug]
        end

        #
        # Execute a given command and return the output from stdout or false if it fails
        #
        def execute_command(cmd)
            Open3.popen3(cmd) do |_stdin, stdout, _stderr, wait_thr|
                return stdout.read.chomp if wait_thr.value.success?
            end
            false
        end
    end
end
