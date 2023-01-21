# puts 'REMOVEME StringOnSteroids ruby file being included'
# include me with "require relative + include "
module StringOnSteroids

    class String
        def trim
            self.gsub(/^\s+/, "").gsub(/\s+$/, "")
        end
    end

end

