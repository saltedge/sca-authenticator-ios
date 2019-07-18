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

#!/bin/sh

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

cp Example/Authenticator/Supporting\ Files/application.example.plist Example/Authenticator/Supporting\ Files/application.plist
cp Example/Authenticator/Supporting\ Files/GoogleService-Info.example.plist Example/Authenticator/Supporting\ Files/GoogleService-Info.plist

bundle install
bundle exec pod repo update master
set -o pipefail

if [ "${BUILD_TYPE}" == "full" ]; then
  bundle exec rake all_tests
else
  bundle exec rake unit_tests
fi
