#!/usr/bin/env ruby

# This script creates a Podfile that avoids all DEFINES_MODULE conflicts
# Run with: ruby strong_fix.rb

new_podfile = <<~PODFILE
require File.join(File.dirname(`node --print "require.resolve('expo/package.json')"`), "scripts/autolinking")
require File.join(File.dirname(`node --print "require.resolve('react-native/package.json')"`), "scripts/react_native_pods")

require 'json'
podfile_properties = JSON.parse(File.read(File.join(__dir__, 'Podfile.properties.json'))) rescue {}

ENV['RCT_NEW_ARCH_ENABLED'] = podfile_properties['newArchEnabled'] == 'true' ? '1' : '0'
ENV['EX_DEV_CLIENT_NETWORK_INSPECTOR'] = podfile_properties['EX_DEV_CLIENT_NETWORK_INSPECTOR'] ||= '1'

platform :ios, podfile_properties['ios.deploymentTarget'] || '13.4'
install! 'cocoapods',
  :deterministic_uuids => false

prepare_react_native_project!

# Temporary monkey patch for Podspec to resolve DEFINES_MODULE conflicts upfront
# This must be placed before any pods are declared
module Pod
  class Specification
    def self.patch_for_defines_module_conflicts
      return if @patched_for_defines_module
      @patched_for_defines_module = true
      
      # Store original pod_target_xcconfig method
      old_pod_target_xcconfig = instance_method(:pod_target_xcconfig)
      
      # Override pod_target_xcconfig to filter out DEFINES_MODULE
      define_method(:pod_target_xcconfig) do
        xcconfig = old_pod_target_xcconfig.bind(self).call || {}
        
        # Remove DEFINES_MODULE from known problematic pods
        if ["expo-dev-menu", "Main", "ReactNativeCompatibles", "SafeAreaView", "Vendored"].include?(name.split('/').first)
          xcconfig.delete('DEFINES_MODULE')
          puts "🛠 Removing DEFINES_MODULE from \#{name} pod specification" if xcconfig.key?('DEFINES_MODULE')
        end
        
        xcconfig
      end
      
      puts "✅ Successfully patched Pod::Specification to prevent DEFINES_MODULE conflicts"
    end
  end
end

# Apply the patch immediately
Pod::Specification.patch_for_defines_module_conflicts

# Disable Flipper which often causes issues
flipper_config = FlipperConfiguration.disabled

target 'KarmaFarm' do
  use_expo_modules!
  config = use_native_modules!
  
  # NOTE: use_frameworks! is commented out to avoid DEFINES_MODULE conflicts
  # use_frameworks! :linkage => :static
  
  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => podfile_properties['expo.jsEngine'] == nil || podfile_properties['expo.jsEngine'] == 'hermes',
    # An absolute path to your application root.
    :app_path => File.dirname(__dir__),
    :flipper_configuration => flipper_config
  )

  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )

    # This is necessary for Xcode 14, because it signs resource bundles by default
    # when building for devices.
    installer.target_installation_results.pod_target_installation_results
      .each do |pod_name, target_installation_result|
      target_installation_result.resource_bundle_targets.each do |resource_bundle_target|
        resource_bundle_target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
    
    # Final pass to remove DEFINES_MODULE from target build settings
    conflict_pods = ["expo-dev-menu", "Main", "ReactNativeCompatibles", "SafeAreaView", "Vendored"]
    
    installer.pods_project.targets.each do |target|
      if conflict_pods.include?(target.name.to_s)
        target.build_configurations.each do |config|
          if config.build_settings.key?('DEFINES_MODULE')
            config.build_settings.delete('DEFINES_MODULE')
            puts "🔧 Removed DEFINES_MODULE from \#{target.name}"
          end
        end
      end
    end
  end

  post_integrate do |installer|
    begin
      expo_patch_react_imports!(installer)
    rescue => e
      Pod::UI.warn e
    end
  end
end
PODFILE

# Create a backup of the original Podfile
if File.exist?('Podfile')
  backup_file = "Podfile.backup.#{Time.now.to_i}"
  File.write(backup_file, File.read('Podfile'))
  puts "📋 Created backup of original Podfile at #{backup_file}"
end

# Write the new Podfile
File.write('Podfile', new_podfile)
puts "✅ Created fixed Podfile that prevents DEFINES_MODULE conflicts"
puts "🔄 Now run: pod deintegrate && pod cache clean --all && pod install" 