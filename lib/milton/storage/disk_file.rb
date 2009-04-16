require File.join(File.dirname(__FILE__), 'base')

module Citrusbyte
  module Milton
    module Storage
      # How Milton deals with a file stored on disk...
      class DiskFile < Base
        class << self
          # Creates the given directory and sets it to the mode given in
          # options[:chmod]
          def recreate_directory(directory, options)
            return true if File.exists?(directory)
            FileUtils.mkdir_p(directory)
            File.chmod(options[:chmod], directory)
          end
          
          def create(filename, source, options)
            file = new(filename, options)
            
            recreate_directory(file.dirname, options)
            File.cp(source, file.path)
            File.chmod(options[:chmod], file.path)
            
            file
          end
        end

        # Returns the full path and filename to the file with the given options.
        # If no options are given then returns the path and filename to the
        # original file.
        def path
          File.join(dirname, filename)
        end

        # Returns the full directory path up to the file, w/o the filename.
        def dirname
          File.join(root_path, partitioned_path)
        end

        # Returns true if the file exists on the underlying file system.
        def exists?
          File.exist?(path)
        end
        
        # Removes the file from the underlying file system and any derivatives of
        # the file.
        def destroy
          FileUtils.rm_rf dirname if File.exists?(dirname)
        end

        protected

        # Partitioner that takes an id, pads it up to 12 digits then splits
        # that into 4 folders deep, each 3 digits long.
        # 
        # i.e.
        #   000/000/012/139
        # 
        # Scheme allows for 1000 billion files while never storing more than
        # 1000 files in a single folder.
        #
        # Can overwrite this method to provide your own partitioning scheme.
        def partitioned_path
          # TODO: there's probably some fancy 1-line way to do this...
          padded = ("0"*(12-id.to_s.size)+id.to_s).split('')
          File.join(*[0, 3, 6, 9].collect{ |i| padded.slice(i, 3).join })
        end

        # The full path to the root of where files will be stored on disk.
        def root_path
          options[:file_system_path]
        end
      end
    end
  end
end
