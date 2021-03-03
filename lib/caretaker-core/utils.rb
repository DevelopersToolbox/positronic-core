#
# Description should go here
#
class CaretakerCore
    #
    # We want to create everything as a class/static method
    #
    class << self
        #
        # Make everything else private so it cannot be accessed directly
        #

        private

        def split_log_entries(line, tag)
            hash, hash_full, refs, commit_message, date = line.split('|')

            tag = extract_tag(refs, tag)

            [date, hash, hash_full, commit_message, tag]
        end

        def extract_tag(refs, old_tag)
            tag = old_tag
            if refs.include? 'tag: '
                refs = refs.gsub(/.*tag:/i, '')
                refs = refs.gsub(/,.*/i, '')
                tag = refs.gsub(/\).*/i, '')
            end
            tag.to_s.strip
        end
    end
end
