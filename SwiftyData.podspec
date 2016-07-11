Pod::Spec.new do |spec|
spec.name = "SwiftyData"
spec.version = "0.1.0"
spec.summary = "Simple CoreData wrapper for Swift iOS projects"
spec.homepage = "https://github.com/aonawale/SwiftyData"
spec.license = { type: 'MIT', file: 'LICENSE.md' }
spec.authors = { "Ahmed Onawale" => 'ahmedonawale@gmail.com' }
spec.social_media_url = "http://twitter.com/ahmedonawale"
spec.ios.deployment_target = '8.0'
spec.requires_arc = true
spec.source = { git: "https://github.com/aonawale/SwiftyData.git", tag: "0.1.0", submodules: true }
spec.source_files = "SwiftyData/**/*.{h,swift}"
spec.description = <<-DESC
	A Swift Core Data wrapper with nice API for interacting with managed objects and managed object contexts.
DESC
end
