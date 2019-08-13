
Pod::Spec.new do |s|
  s.name             = 'WordSuggestion'
  s.version          = '0.2.0'
  s.summary          = 'A Swift word suggestion model.'

  s.description      = <<-DESC
Swift N-Gram word suggestion implementation.
                       DESC

  s.homepage         = 'https://github.com/mainasuk/WordSuggestion'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mainasuk' => 'cirno.mainasuk@gmail.com' }
  s.source           = { :git => 'https://github.com/mainasuk/WordSuggestion.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '11.0'

  s.source_files = 'WordSuggestion/Classes/**/*'
  
  s.resource_bundles = {
    'Corpus' => ['WordSuggestion/Assets/*.csv']
  }

  s.dependency 'RealmSwift'
end
