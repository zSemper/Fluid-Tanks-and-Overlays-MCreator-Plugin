package net.zsemper.ftao.elements;

import net.mcreator.element.GeneratableElement;
import net.mcreator.element.parts.Fluid;
import net.mcreator.workspace.elements.ModElement;
import net.mcreator.workspace.references.ModElementReference;

import java.util.List;

public class FluidTanks extends GeneratableElement {
    @ModElementReference public String block;
    public List<TankListEntry> tanks;
    @ModElementReference public String gui;
    public List<OverlayListEntry> overlays;

    public FluidTanks(ModElement element) {
        super(element);
    }

    public static class TankListEntry {
        public TankListEntry() {}

        public int index;
        public int size;
        @ModElementReference
        public List<Fluid> fluidRestrictions;
    }

    public static class OverlayListEntry {
        public OverlayListEntry() {}

        public int xPos;
        public int yPos;
        public int width;
        public int height;
        public int index;
    }
}
