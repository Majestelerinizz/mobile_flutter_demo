@echo off
echo 🚀 Flutter Build Optimization Starting...

REM Kill existing Java processes that may cause conflicts
echo 🔄 Cleaning up Java processes...
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM gradle.exe >nul 2>&1

REM Wait for processes to fully terminate
echo ⏳ Waiting for process cleanup...
timeout /t 2 /nobreak >nul

REM Clean Flutter cache completely
echo 🧹 Cleaning Flutter cache...
flutter clean

REM Configure Gradle for better performance
echo ⚙️ Configuring Gradle settings...
(
echo # Flutter build optimization
echo org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m -XX:+UseG1GC
echo org.gradle.daemon=true
echo org.gradle.configureondemand=true
echo org.gradle.parallel=true
echo org.gradle.caching=true
echo org.gradle.buildcache.enabled=true
echo.
echo # Kotlin daemon optimization
echo kotlin.daemon.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=256m
echo kotlin.incremental=true
echo kotlin.incremental.android=true
echo kotlin.incremental.java=true
) > android\gradle.properties

REM Get dependencies with optimized settings
echo 📦 Installing dependencies...
flutter pub get

REM Clean Android build cache
echo 🧹 Cleaning Android build cache...
cd android
gradlew clean
cd ..

echo ✅ Build optimization complete!
echo 🎯 Ready for fast and stable builds
pause
