package net.zsemper.ftao.utils;

import net.mcreator.element.ModElementType;
import net.mcreator.element.parts.gui.GUIComponent;
import net.mcreator.ui.wysiwyg.WYSIWYGComponentRegistration;
import net.mcreator.ui.wysiwyg.WYSIWYGEditor;
import net.zsemper.ftao.elements.*;
import net.zsemper.ftao.parts.FluidTank;
import net.zsemper.ftao.parts.FluidTankDialog;

import static net.mcreator.element.ModElementTypeLoader.register;

public class ElementLoader {
    public static ModElementType<?> FLUID_TANKS;

    public static void load() {
        FLUID_TANKS = register(new ModElementType<>("fluid_tanks", 'T', FluidTanksGUI::new, FluidTanks.class));

        GUIComponent.registerCustomComponent(FluidTank.class);
        WYSIWYGEditor.COMPONENT_REGISTRY.add(new WYSIWYGComponentRegistration<>("fluid_tank", "addfluidtank", false, FluidTank.class, FluidTankDialog.class));
    }
}
