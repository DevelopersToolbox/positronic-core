require 'date'
require 'open3'
require 'uri'

require_relative 'config'
require_relative 'git'
require_relative 'process'
require_relative 'tags'
require_relative 'utils'

# This is the core file
# @author Wolf
class CaretakerCore
    #
    # We want to create everything as a class/static method
    #
    class << self
        #
        # Make everything else private so it cannot be accessed directly
        #

        private

        #
        # Setup the require global configuration
        #
        def init_config(options)
            # Assign the default config
            config = DEFAULT_CONFIG

            # Merge in any user supplied options/config and return
            config.merge(options)
        end

        def real_process(config)
            log_entries = retrieve_git_log_entries

            return [ [], [], [] ] unless log_entries

            parsed = parse_git_log_entries(config, log_entries)

            tags = generate_tag_list(parsed)

            chronological, categorised = process_results(parsed)

            [tags, chronological, categorised]
        end

        #
        # Limitations with regards to Pull Requests
        #
        # 1. Squished commits work as exepected and the contents of the child commmits is available
        # 2. Rebased commits show as local commits as there is no way to see where they came from
        # 3. Unsquished commits only show the PR commit_message as the child commits are ignored
        #
        # This method reeks of :reek:TooManyStatements { max_statements: 6 }
        def parse_git_log_entries(config, log_entries)
            logs = {}
            tag = INITIAL_TAG

            log_entries.each do |line|
                tag, data = process_single_line(config, line, tag)

                (logs[tag] ||= []) << data if data
            end
            logs
        end

        def get_parts(line, tag)
            date, hash, hash_full, commit_message, tag = split_log_entries(line, tag)
            commit_message, child_commit_messages, commit_type = process_commit_message(commit_message, hash)
            category = get_category(commit_message)

            [hash, hash_full, commit_message, child_commit_messages, commit_type, category, date, tag]
        end

        def process_single_line(config, line, tag)
            hash, hash_full, commit_message, child_commit_messages, commit_type, category, date, tag = get_parts(line, tag)

            return false if category.downcase == 'skip:'

            commit_message = commit_message.sub(/.*?:/, '').strip if config[:remove_categories]

            data = { :hash => hash, :hash_full => hash_full, :commit_message => commit_message, :child_commit_messages => child_commit_messages, :commit_type => commit_type, :category => category, :date => date }

            [tag, data]
        end

        # This method reeks of :reek:DuplicateMethodCall, :reek:NestedIterators
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        def get_category(commit_message)
            commit_message_downcase = commit_message.downcase

            # Does it match a primary category ?
            category = CATEGORIES.select { |key, _values| commit_message_downcase.start_with?(key.downcase) }.map(&:first).join

            # If not a primary category, does it match one of the aliases?
            category = CATEGORIES.select { |_key, values| values.any? { |value| commit_message_downcase.start_with?(value.downcase) } }.map(&:first).join if category.empty?

            # If in doubt set to the default
            category = DEFAULT_CATEGORY if category.empty?

            category
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

        def get_pr_number(all_matches)
            all_matches.to_a.compact.pop
        end

        def generate_pr_link(matches)
            pr_number = get_pr_number(matches)

            message = "Merge pull request ##{pr_number}"
            [message, pr_number]
        end

        def process_merge_request(merge_message, hash, patterns)
            matches = merge_message.match(patterns).captures

            new_message = generate_pr_link(matches)

            child_commit_messages = get_child_messages(hash)

            [new_message, child_commit_messages]
        end

        def process_normal_commit(commit_message)
            commit_type = :commit
            [commit_message, commit_type]
        end

        def process_commit_message(commit_message, hash)
            patterns_array = [/Merge pull request #(\d+).*/, /\.*\(#(\d+)\)*\)/]
            patterns = Regexp.union(patterns_array)

            child_commit_messages = false
            commit_type = :pr

            if commit_message.scan(/Merge pull request #(\d+).*/m).size.positive? || commit_message.scan(/\.*\(#(\d+)\)*\)/m).size.positive?
                message, child_commit_messages = process_merge_request(commit_message, hash, patterns)
            else
                message, commit_type = process_normal_commit(commit_message)
            end
            [message, child_commit_messages, commit_type]
        end
    end
end
