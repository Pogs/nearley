echo "Building test parser (this should check integrity)."
bin/nearleyc.coffee test/parens.ne -o test/parens.js;
echo "Parser build successfully."

date > test/profile.log
echo "Running profiles...";
coffee test/profile.coffee >> test/profile.log;
echo "Done running profiles.";
cat test/profile.log

echo "Testing exponential whitespace bug..."
time bin/nearleyc.coffee test/indentation.ne > /dev/null
echo "Done with all tests."
