module RedmineRubyWasm
  class << self
    def include_to_helper(destination_helper, helper)
      destination_helper.include(helper)

      ActionController::Base.descendants.each do |controller_class|
        next if !controller_class._helpers.include?(destination_helper)

        controller_class.helper(helper)
      end
    end
  end
end
