Pod::Spec.new do |s|
  s.name         = "BarrageRendererMac"
  s.version      = "0.0.1"
  s.summary      = "With BarrageRenderer, you can easily create barrage or danmaku in your apps."
  s.homepage     = "https://github.com/MrLu/BarrageRenderer"
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.author       = { "MrLu" => "370198370@qq.com" }
  s.platform     = :osx, '10.10'
  s.source       = { :git => "https://github.com/MrLu/BarrageRenderer.git", :branch => "mac" }
  s.source_files  = "BarrageRendererMac/*.{h,m}","BarrageRendererMac/*/*.{h,m}"
end