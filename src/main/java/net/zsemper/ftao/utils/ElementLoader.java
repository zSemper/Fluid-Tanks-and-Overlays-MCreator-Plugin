package net.zsemper.ftao.utils;

import net.mcreator.element.ModElementType;
import net.zsemper.ftao.elements.*;

import static net.mcreator.element.ModElementTypeLoader.register;

public class ElementLoader {
    public static ModElementType<?> FLUID_TANKS;

    public static void load() {
        FLUID_TANKS = register(new ModElementType<>("fluid_tanks", 'T', FluidTanksGUI::new, FluidTanks.class));
    }
}
