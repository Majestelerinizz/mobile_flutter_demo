#!/bin/bash
echo "🚀 Flutter Build Optimization Starting..."

# Kill existing Java processes that may cause conflicts
echo "🔄 Cleaning up Java processes..."
taskkill /F /IM java.exe 2>nul || true
taskkill /F /IM gradle.exe 2>nul || true

# Wait for processes to fully terminate
echo "⏳ Waiting for process cleanup..."
sleep 2

# Clean Flutter cache completely
echo "🧹 Cleaning Flutter cache..."
flutter clean

# Configure Gradle for better performance
echo "⚙️ Configuring Gradle settings..."
cat > android/gradle.properties << EOF
# Flutter build optimization
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m -XX:+UseG1GC
org.gradle.daemon=true
org.gradle.configureondemand=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.buildcache.enabled=true

# Kotlin daemon optimization
kotlin.daemon.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=256m
kotlin.incremental=true
kotlin.incremental.android=true
kotlin.incremental.java=true
EOF

# Get dependencies with optimized settings
echo "📦 Installing dependencies..."
flutter pub get

# Clean Android build cache
echo "🧹 Cleaning Android build cache..."
cd android
./gradlew clean
cd ..

echo "✅ Build optimization complete!"
echo "🎯 Ready for fast and stable builds"
