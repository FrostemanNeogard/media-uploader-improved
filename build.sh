dotnet build Jellyfin.Plugin.MediaUploader/Jellyfin.Plugin.MediaUploader.csproj -c Release 2>&1 | tail -6
rm -f dist/Jellyfin.Plugin.MediaUploader_1.0.0.0.zip
zip -j dist/Jellyfin.Plugin.MediaUploader_1.0.0.0.zip Jellyfin.Plugin.MediaUploader/bin/Release/net8.0/Jellyfin.Plugin.MediaUploader.dll
echo "--- packaged ---"
unzip -l dist/Jellyfin.Plugin.MediaUploader_1.0.0.0.zip