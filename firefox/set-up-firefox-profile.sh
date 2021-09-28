# This should be idempotent so it can be run multiple times.
#
# This script assumes it's being run from the root of the containing
# repository. No guarantees are given with respect to how it acts when
# a profile name is not provided.
#
# Usage: `./firefox/set-up-firefox-profile.sh your-profile-name`
#
firefox="firefox"
firefox_config_dir="$HOME/.mozilla/firefox"

##--- Supporting Functions

get_profile_path() {
  set -e
  cat "$firefox_config_dir"/profiles.ini | grep -A4 "Name=$1" | grep Path | sed 's/Path=//'
}

# usage: ff_set "browser.search.defaulturl" '"https://duckduckgo.com/"' "$profile_path"
set_firefox_config_value() {
  # remove previous entry
  sed -i '/^user_pref("'$1'",.*);/d' "$3"/user.js
  # insert new one
  grep -q $1 "$3"/user.js || echo "user_pref(\"$1\",$2);" >> "$3"/user.js
}

##--- Execution

profile_name="$1"
if ls "$firefox_config_dir"/Profiles/*.$1 1> /dev/null 2>&1; then
  echo "Will not create profile $1, as it already exists. Associated configuration will be updated."
else
  echo "Creating profile..."
  "$firefox" -CreateProfile "$profile_name"
fi

profile_path="$firefox_config_dir"/$(get_profile_path "$profile_name")
echo "Profile exists at $profile_path"

touch "$profile_path"/user.js

# allow for the usage of custom styles
set_firefox_config_value "toolkit.legacyUserProfileCustomizations.stylesheets" 'true' "$profile_path"
# remove pocket
set_firefox_config_value "extensions.pocket.enabled" 'false' "$profile_path"
# don't remember sign-ons
set_firefox_config_value "signon.rememberSignons" 'false' "$profile_path"
set_firefox_config_value "signon.rememberSignons.visibilityToggle" 'false' "$profile_path"
# don't warn me about about:config
set_firefox_config_value "browser.aboutConfig.showWarning" 'false' "$profile_path"
# always show the bookmarks toolbar
set_firefox_config_value "browser.toolbars.bookmarks.visibility" 'always' "$profile_path"

# copy custom styles into directory
# this assumes that this is being run from the repository root
mkdir -p "$profile_path"/chrome
cp ./firefox/userChrome.css "$profile_path"/chrome/userChrome.css

# Firefox sync should do the rest. This script does not configure it.
