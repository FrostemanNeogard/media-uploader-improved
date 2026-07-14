dotnet build Jellyfin.Plugin.MediaUploaderImproved/Jellyfin.Plugin.MediaUploaderImproved.csproj -c Release 2>&1 | tail -6
rm -f dist/Jellyfin.Plugin.MediaUploaderImproved_1.0.0.0.zip
zip -j dist/Jellyfin.Plugin.MediaUploaderImproved_1.0.0.0.zip Jellyfin.Plugin.MediaUploaderImproved/bin/Release/net8.0/Jellyfin.Plugin.MediaUploaderImproved.dll
echo "--- packaged ---"
unzip -l dist/Jellyfin.Plugin.MediaUploaderImproved_1.0.0.0.zip
md5sum dist/Jellyfin.Plugin.MediaUploaderImproved_1.0.0.0.zip | cut -d' ' -f1