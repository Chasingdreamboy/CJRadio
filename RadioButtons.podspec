Pod::Spec.new do |s|
  s.name         = "RadioButtons"
  s.version      = "2.3.0"
  s.summary      = "一个单选按钮组合的使用.在2.3.0版本这里停止使用，并改为pod‘CJRadio/CJRadioButtons"
  s.homepage     = "https://github.com/dvlproad/CJRadio"
  s.license      = "MIT"
  s.author             = { "dvlproad" => "studyroad@qq.com" }
  # s.social_media_url   = "http://twitter.com/dvlproad"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/dvlproad/CJRadio.git", :tag => "deprecated_RadioButtons_2.3.0" }
  s.source_files  = "CJRadio/*.{h,m}"
  s.frameworks = 'UIKit'

  s.deprecated = true

end
