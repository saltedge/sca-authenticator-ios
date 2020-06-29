#
# Be sure to run `pod lib lint SaltedgeAuthenticatorSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'SaltedgeAuthenticatorSDK'
  s.version               = '1.1.0'
  s.summary               = 'SDK for decoupled authentication solution to meet the requirements of Strong Customer Authentication (SCA)'

  s.description           = <<-DESC
                            Authenticator iOS SDK - is a module for connecting to Salt Edge Authenticator API of
                            Bank (Service Provider) System, that implements Strong Customer Authentication/Dynamic Linking process.
                            DESC

  s.homepage              = 'https://github.com/saltedge/sca-authenticator-ios'
  s.license               = { :type => 'GPLv3', :file => 'LICENSE.txt' }
  s.author                = { 'Salt Edge Inc.' => 'authenticator@saltedge.com' }
  s.source                = { :git => 'https://github.com/saltedge/sca-authenticator-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version         = '5'
  s.module_name           = 'SEAuthenticator'

  s.source_files          = 'SaltedgeAuthenticatorSDK/Classes/**/*'

  s.dependency 'CryptoSwift'
end
