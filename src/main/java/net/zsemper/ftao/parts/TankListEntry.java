package net.zsemper.ftao.parts;

import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.entries.JSimpleListEntry;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.help.IHelpContext;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.minecraft.FluidListField;
import net.mcreator.workspace.Workspace;
import net.zsemper.ftao.elements.FluidTanks;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class TankListEntry extends JSimpleListEntry<FluidTanks.TankListEntry> {
    private final JSpinner index = new JSpinner(new SpinnerNumberModel(1, 1, 100,1));
    private final JSpinner size = new JSpinner(new SpinnerNumberModel(8000, 1, 2147483647, 1));
    private FluidListField fluidRestrictions;

    private final Workspace workspace;

    public TankListEntry(MCreator mcreator, IHelpContext gui, JPanel parent, List<TankListEntry> entryList) {
        super(parent, entryList);

        fluidRestrictions = new FluidListField(mcreator);
        this.workspace = mcreator.getWorkspace();

        index.setPreferredSize(Constants.SPINNER_DIMENSION);
        size.setPreferredSize(new Dimension(140, Constants.HEIGHT));
        fluidRestrictions.setPreferredSize(new Dimension(400, Constants.HEIGHT));

        this.line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tank_index"), L10N.label("elementGui.tankListEntry.tankIndex", Constants.NO_PARAMS)));
        this.line.add(index);
        this.line.add(L10N.label("elementGui.tankListEntry.tankSize", Constants.NO_PARAMS));
        this.line.add(size);
        this.line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tanks/fluid_restrictions"), L10N.label("elementGui.tankListEntry.fluidRestrictions", Constants.NO_PARAMS)));
        this.line.add(fluidRestrictions);
    }

    public void reloadDataLists() {
        super.reloadDataLists();
    }

    @Override
    protected void setEntryEnabled(boolean enabled) {
        this.index.setEnabled(enabled);
        this.size.setEnabled(enabled);
        this.fluidRestrictions.setEnabled(enabled);
    }

    @Override
    public FluidTanks.TankListEntry getEntry() {
        FluidTanks.TankListEntry entry = new FluidTanks.TankListEntry();
        entry.index = (int) index.getValue();
        entry.size = (int) size.getValue();
        if(!fluidRestrictions.getListElements().isEmpty()) {
            entry.fluidRestrictions = fluidRestrictions.getListElements();
        }
        return entry;
    }

    @Override
    public void setEntry(FluidTanks.TankListEntry entry) {
        index.setValue(entry.index);
        size.setValue(entry.size);
        fluidRestrictions.setListElements(entry.fluidRestrictions);
    }
}
