package net.zsemper.ftao;

import net.mcreator.plugin.JavaPlugin;
import net.mcreator.plugin.Plugin;
import net.mcreator.plugin.events.PreGeneratorsLoadingEvent;
import net.mcreator.workspace.Workspace;
import net.zsemper.ftao.utils.Constants;
import net.zsemper.ftao.utils.ElementLoader;

public class ModPlugin extends JavaPlugin {
    public ModPlugin(Plugin plugin) {
        super(plugin);

        addListener(PreGeneratorsLoadingEvent.class, event -> ElementLoader.load());

        Constants.LOG.info("Fluid Tanks and Overlays Plugin was loaded.");
    }
}
