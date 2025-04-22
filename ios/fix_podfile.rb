#!/usr/bin/env ruby

# Script to fix DEFINES_MODULE conflicts in Podfile
# Run with: ruby fix_podfile.rb

podfile_path = 'Podfile'

# Read original Podfile content
original_content = File.read(podfile_path)

# Define fixed content to insert before the 'post_install' block
fixed_content = <<~FIXED_CONTENT
  # Fix DEFINES_MODULE conflicts
  fix_defines_module = -> (installer) {
    conflict_pods = ["expo-dev-menu", "Main", "ReactNativeCompatibles", "SafeAreaView", "Vendored"]
    installer.pods_project.targets.each do |target|
      if conflict_pods.include?(target.name.to_s)
        puts "🔧 Removing DEFINES_MODULE from \#{target.name}"
        target.build_configurations.each do |config|
          config.build_settings.delete('DEFINES_MODULE')
        end
      end
    end
  }
FIXED_CONTENT

# Modify post_install to call our fix
if original_content.include?('post_install do |installer|')
  modified_content = original_content.gsub(
    'post_install do |installer|',
    "#{fixed_content}\n\n  post_install do |installer|\n    fix_defines_module.call(installer)"
  )
else
  puts "❌ Couldn't find post_install block in Podfile"
  exit 1
end

# Write the modified content back
File.write(podfile_path, modified_content)
puts "✅ Successfully updated Podfile with DEFINES_MODULE conflict fix" 