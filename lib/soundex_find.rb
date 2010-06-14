# SoundexFind
module WGJ #:nodoc:
  module SoundexFind #:nodoc:

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      
      def soundex_columns(columns, options = {})
        include WGJ::SoundexFind::InstanceMethods
        extend WGJ::SoundexFind::SingletonMethods
        
        before_save :update_soundex

        self.sdx_columns = (columns.is_a?(Array) ? columns : [columns])
        self.sdx_options = options
      end
    end
    
    # This module contains class methods
    module SingletonMethods
      @sdx_columns = []
      @options = {}

      def sdx_columns=(a)
        @sdx_columns = a  
      end
      
      def sdx_columns
        @sdx_columns
      end
      
      def sdx_options=(o)
        @sdx_options = o  
      end
      
      def sdx_options
        @sdx_options
      end
      
      def soundex_find(*args)
        options = args.extract_options!
        
        sdx = (self.sdx_options[:start] ? '' : '%') +
                self.soundex(options.delete(:soundex)) +
                (self.sdx_options[:end] ? '' : '%')
        
        #TODO: currently supports only one column
        with_scope :find => { :conditions => ["#{self.sdx_columns[0]}_soundex LIKE ?", sdx] } do
          items = self.find(args.first, options) 
        end
      end
      
      #TODO: Use resource file, and support more languages, or alternate charsets.
      SoundexChars = 'BPFVCSKGJQXZDTLMNR'
      SoundexNums  = '111122222222334556'
      SoundexCharsEx = '^' + SoundexChars
      SoundexCharsDel = '^A-Z'
      SoundexSkipChars = 'HW'
    
      # desc: http://en.wikipedia.org/wiki/Soundex
      # more examples: http://www.archives.gov/genealogy/census/soundex.html
      # online converter to compare standard strict options: http://resources.rootsweb.ancestry.com/cgi-bin/soundexconverter
      # adapted from Alexander Ermolaev
      # http://snippets.dzone.com/posts/show/4530
      def soundex(string)
        limit   = self.sdx_options[:limit]
        strict  = self.sdx_options[:strict]

        # replace skip chars, remove invalid chars
        str     = string.upcase.tr(SoundexSkipChars, "|").delete(SoundexCharsDel).squeeze    

        # soundex rules state duplicate numbers not seperated by vowels get combined, so for now turn vowels into _'s
        result = str[0 .. -1].tr(SoundexCharsEx, "_").tr(SoundexChars, SoundexNums) rescue ''

        # remove skip char placeholders and following code if they follow a consonant
        result = result.gsub(/#{SoundexSkipChars.split(//).join("|")}\d/, "")
        
        # combine duplicate codes not seperated by vowels
        result = result.squeeze

        # remove vowel place holders (except first char if it is _)
        result = result[0 .. 0].to_s + result[1 .. -1].to_s.gsub("_", "")
        
        # obey limit if set
        result = result[0 .. (limit ? (limit) : -1)].to_s
        
        # when strict, turn first code back into the first character of the string
        if strict
          result = string[0 .. 0].upcase.to_s + result[1 .. -1].to_s
        else
          # if not strict, remove first character if it's an _
          result = result[1 .. -1].to_s if result[0 .. 0].to_s == "_"
        end
        
        # pad up to limit with 0's
        result = result.ljust(limit + 1, "0") if limit
        
        result
      end
      
    end
    
    # This module contains instance methods
    module InstanceMethods

      def update_soundex
        self.class.sdx_columns.each {|c|
          self.send("#{c}_soundex=", self.class.soundex(self.send(c)))
        }
      end
      
    end
  end
end



