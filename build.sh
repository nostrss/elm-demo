#!/bin/bash

# Exit on error
set -e

echo "Building Elm application..."

# Build Elm with optimization
elm make src/Main.elm --optimize --output=elm.js

# Calculate MD5 hash of the built file
if command -v md5sum &> /dev/null; then
    HASH=$(md5sum elm.js | cut -d' ' -f1 | cut -c1-8)
elif command -v md5 &> /dev/null; then
    HASH=$(md5 -q elm.js | cut -c1-8)
else
    echo "Error: Neither md5sum nor md5 command found"
    exit 1
fi

echo "Generated hash: $HASH"

# Rename elm.js to elm.[hash].js
NEW_FILENAME="elm.$HASH.js"
mv elm.js "$NEW_FILENAME"
echo "Created: $NEW_FILENAME"

# Update index.html to reference the new filename
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/elm\.[a-f0-9]\{8\}\.js/$NEW_FILENAME/g" index.html
    sed -i '' "s/elm\.js/$NEW_FILENAME/g" index.html
else
    # Linux
    sed -i "s/elm\.[a-f0-9]\{8\}\.js/$NEW_FILENAME/g" index.html
    sed -i "s/elm\.js/$NEW_FILENAME/g" index.html
fi
echo "Updated index.html"

# Update 404.html to reference the new filename
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/elm\.[a-f0-9]\{8\}\.js/$NEW_FILENAME/g" 404.html
    sed -i '' "s/elm\.js/$NEW_FILENAME/g" 404.html
else
    # Linux
    sed -i "s/elm\.[a-f0-9]\{8\}\.js/$NEW_FILENAME/g" 404.html
    sed -i "s/elm\.js/$NEW_FILENAME/g" 404.html
fi
echo "Updated 404.html"

# Remove old elm.*.js files (except the new one)
find . -maxdepth 1 -name "elm.*.js" ! -name "$NEW_FILENAME" -delete 2>/dev/null || true

echo "Build complete! Generated: $NEW_FILENAME"

# Create public directory and copy files for Vercel deployment
echo "Preparing files for deployment..."
mkdir -p public
cp "$NEW_FILENAME" public/
cp index.html public/
cp 404.html public/
echo "Files copied to public/ directory"
