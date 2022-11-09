puts 'REMOVEME StringOnSteroids ruby file being included'

module StringOnSteroids

    class String
        def trim
            self.gsub(/^\s+/, "").gsub(/\s+$/, "")
        end
    end

end

