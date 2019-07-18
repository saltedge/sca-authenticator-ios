#  This file is part of the Salt Edge Authenticator distribution
#  (https:github.com/saltedge/sca-authenticator-ios)
#  Copyright (c) 2019 Salt Edge Inc.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, version 3.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http:www.gnu.org/licenses/>.
#
#  For the additional permissions granted for Salt Edge Authenticator
#  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md

load "rake_helpers.rb"
load "localizations_helpers.rb" if File.exist?("localizations_helpers.rb")
require 'nokogiri'

desc "All Tests"
task :all_tests => [:unit_tests]

desc "All Unit Tests"
task :unit_tests => [:clean, :check_dependencies, :XCSpecs, :coverage]

desc "Xcode Unit Tests"
task :XCSpecs do
  system_or_exit "xcodebuild -workspace Example/Authenticator.xcworkspace -scheme Authenticator-Example -configuration Debug -destination 'name=iPhone SE' test | xcpretty -t; test ${PIPESTATUS[0]} -eq 0"
end

desc "Code Coverage"
task :coverage do
  system("cd Example && bundle exec slather coverage")
  page = Nokogiri::HTML(File.read("Example/coverage_reports/index.html"))
  coverage = page.css('span#total_coverage').text
  puts "\nTotal unit tests coverage: " + coverage
end

desc "Check dependencies"
task :check_dependencies do
  check_dependencies
end

desc "Clean DerivedData"
task :clean do
  system("rm -rf Example/DerivedData/Authenticator/Build")
end

task :fetch_localizations do
  env = ENV["ENV"] || "production"
  locales = ["en"]
  fetch_localization({ "env" => env, "locales" => locales })
end
