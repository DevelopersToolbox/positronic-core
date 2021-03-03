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

        # This method reeks of :reek:NestedIterators
        def init_results(parsed)
            chronological = {}
            categorised = {}

            parsed.each do |tag|
                tag_str = tag.to_s

                chronological[tag_str] = []

                categorised[tag_str] = {}
                CATEGORIES.each { |category, _array| categorised[tag_str][category.to_s] = [] }
            end

            [chronological, categorised]
        end

        # This method reeks of :reek:NestedIterators
        def process_results(parsed)
            chronological, categorised = init_results(parsed.keys)

            parsed.each do |tag, array|
                tag_str = tag.to_s

                array.each do |arr|
                    (chronological[tag_str] ||= []) << arr
                    (categorised[tag_str][arr[:category]] ||= []) << arr
                end
            end
            [chronological, categorised]
        end
    end
end
