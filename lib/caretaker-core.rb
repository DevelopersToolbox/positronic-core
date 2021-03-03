require 'json'

#
# We will need to change this when we restrcuture the code
#
require 'caretaker-core/core'
require 'caretaker-core/version'

#
# Docs to go here
#
class CaretakerCore
    #
    # Docs to go here
    #
    class << self
        #
        # Docs to go here
        #
        def run(options = {})
            # Will throw an exception if not a git repo
            check_for_git_repo

            # Set the initial config and handle user supplied options
            config = init_config(options)

            # Get URL and slug for the repo, will throw and exception if no remote origin is set
            repository, slug = git_repo_details

            # Add to config for easy access
            config[:repo_url] = repository

            # Really do the processing
            tags, chronological, categorised = real_process(config)

            # Return the data to the calling function
            { :tags => tags, :commits => { :chronological => chronological, :categorised => categorised }, :repo => { :url => repository, :slug => slug } }.to_json
        end
    end
end
