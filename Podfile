

platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'SimpleMemo' do
	
  pod 'EvernoteSDK',  :git => 'https://github.com/lijuncode/evernote-cloud-sdk-ios.git', :commit => '72cbe59bae4bf3909c1aec00bf13c1cc3e582605'
  pod 'SnapKit', '~> 3.2.0'
	
	target 'SimpleMemoTests' do
		inherit! :search_paths
	end
end

post_install do | installer |
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end
