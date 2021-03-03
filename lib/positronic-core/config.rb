#
# Description should go here
#
class PositronicCore
    #
    # We want to create everything as a class/static method
    #
    class << self
        # Class Constants
        INITIAL_TAG       = 'untagged'.freeze

        DEFAULT_CATEGORY  = 'Uncategorised:'.freeze
        CATEGORIES        = {
                                'New Features:'    => [ 'new feature:', 'new:', 'feature:' ],
                                'Improvements:'    => [ 'improvement:', 'improve:' ],
                                'Bug Fixes:'       => [ 'bug fix:', 'bug:', 'bugs:' ],
                                'Security Fixes:'  => [ 'security: '],
                                'Refactor:'        => [ ],
                                'Style:'           => [ ],
                                'Deprecated:'      => [ ],
                                'Removed:'         => [ 'deleted:' ],
                                'Tests:'           => [ 'test:', 'testing:' ],
                                'Documentation:'   => [ 'docs: ' ],
                                'Chores:'          => [ 'chore:' ],
                                'Experiments:'     => [ 'experiment:' ],
                                'Miscellaneous:'   => [ 'misc:' ],
                                'Uncategorised:'   => [ 'no category:' ],
                                'Initial Commit:'  => [ 'initial:' ],
                                'Skip:'            => [ 'ignore:' ]
                            }.freeze
        DEFAULT_CONFIG    = {
                                :enable_categories => false,
                                :remove_categories => true
                            }.freeze
    end
end
