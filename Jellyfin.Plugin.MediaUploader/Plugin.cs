namespace Jellyfin.Plugin.MediaUploader;

using System;
using System.Collections.Generic;
using System.Globalization;
using Jellyfin.Plugin.MediaUploader.Configuration;
using MediaBrowser.Common.Configuration;
using MediaBrowser.Common.Plugins;
using MediaBrowser.Model.Plugins;
using MediaBrowser.Model.Serialization;

public class Plugin : BasePlugin<PluginConfiguration>, IHasWebPages
{
    public Plugin(IApplicationPaths applicationPaths, IXmlSerializer xmlSerializer)
        : base(applicationPaths, xmlSerializer)
    {
        Instance = this;
    }

    public override string Name => "Media Uploader";

    public override string Description => "Allows uploading media files directly via the web interface.";

    public override Guid Id => Guid.Parse("514d4276-bf23-4a85-b074-66b4cd38fd90");

    public static Plugin? Instance { get; private set; }

    public IEnumerable<PluginPageInfo> GetPages()
    {
        return
        [
            new PluginPageInfo
            {
                Name = this.Name,
                EmbeddedResourcePath = string.Format(CultureInfo.InvariantCulture, "{0}.Configuration.configPage.html", this.GetType().Namespace),
            }
        ];
    }
}
