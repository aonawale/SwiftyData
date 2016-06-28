Pod::Spec.new do |spec|
spec.name = "SwiftData"
spec.version = "1.0.0"
spec.summary = "Simple CoreData wrapper for Swift iOS projects"
spec.homepage = "https://github.com/aonawale/SwiftData"
spec.license = { type: 'MIT', file: 'LICENSE.md' }
spec.authors = { "Ahmed Onawale" => 'ahmedonawale@gmail.com' }
spec.social_media_url = "http://twitter.com/ahmedonawale"
spec.ios.deployment_target = '8.0'
spec.requires_arc = true
spec.source = { git: "https://github.com/aonawale/SwiftData.git", tag: "v#{spec.version}", submodules: true }
spec.source_files = "SwiftData/**/*.{h,swift}"
end
