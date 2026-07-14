namespace Jellyfin.Plugin.MediaUploader.Configuration;

using System.Collections.Generic;
using MediaBrowser.Model.Plugins;

public class PluginConfiguration : BasePluginConfiguration
{
    public string UploadPath { get; set; } = string.Empty;

#pragma warning disable CA1002
#pragma warning disable CA2227
    public List<DestinationConfig> Destinations { get; set; } = new List<DestinationConfig>();
#pragma warning restore CA1002
#pragma warning restore CA2227
}
