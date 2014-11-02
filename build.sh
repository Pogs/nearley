echo "Building nearley..."
./bin/nearleyc.coffee ./lib/nearley-language-bootstrapped.ne -o grammar.tmp
echo "Deleting temp file..."
mv grammar.tmp ./lib/nearley-language-bootstrapped.js
echo "Running tests..."
test/launch.sh
