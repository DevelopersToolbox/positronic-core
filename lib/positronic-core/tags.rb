#
# Description should go here
#
class PositronicCore
    #
    # We want to create everything as a class/static method
    #
    class << self
        #
        # Make everything else private so it cannot be accessed directly
        #

        private

        def generate_tag_list(parsed)
            parsed.keys
        end
    end
end
