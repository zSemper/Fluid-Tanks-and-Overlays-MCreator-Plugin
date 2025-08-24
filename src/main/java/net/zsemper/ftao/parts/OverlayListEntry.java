package net.zsemper.ftao.parts;

import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.entries.JSimpleListEntry;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.help.IHelpContext;
import net.mcreator.ui.init.L10N;
import net.mcreator.workspace.Workspace;
import net.zsemper.ftao.elements.FluidTanks;

import javax.swing.*;
import java.util.List;

public class OverlayListEntry extends JSimpleListEntry<FluidTanks.OverlayListEntry> {
    private final JSpinner index = new JSpinner(new SpinnerNumberModel(0, 0, 100, 1));
    private final JSpinner xPos = new JSpinner(new SpinnerNumberModel(0, 0, 1000, 1));
    private final JSpinner yPos = new JSpinner(new SpinnerNumberModel(0, 0, 1000, 1));
    private final JSpinner width = new JSpinner(new SpinnerNumberModel(16, 1, 16, 1));
    private final JSpinner height = new JSpinner(new SpinnerNumberModel(16, 1, 1000, 1));

    private final Workspace workspace;

    public OverlayListEntry(MCreator mcreator, IHelpContext gui, JPanel parent, List<OverlayListEntry> entryList) {
        super(parent, entryList);
        this.workspace = mcreator.getWorkspace();

        index.setPreferredSize(Constants.SPINNER_DIMENSION);
        xPos.setPreferredSize(Constants.SPINNER_DIMENSION);
        yPos.setPreferredSize(Constants.SPINNER_DIMENSION);
        width.setPreferredSize(Constants.SPINNER_DIMENSION);
        height.setPreferredSize(Constants.SPINNER_DIMENSION);

        this.line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tank_index"), L10N.label("elementGui.overlayListEntry.tankIndex", Constants.NO_PARAMS)));
        this.line.add(index);
        this.line.add(L10N.label("elementGui.overlayListEntry.xPos", Constants.NO_PARAMS));
        this.line.add(xPos);
        this.line.add(L10N.label("elementGui.overlayListEntry.yPos", Constants.NO_PARAMS));
        this.line.add(yPos);
        this.line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/overlay/tank_width"), L10N.label("elementGui.overlayListEntry.width", Constants.NO_PARAMS)));
        this.line.add(width);
        this.line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/overlay/tank_height"), L10N.label("elementGui.overlayListEntry.height", Constants.NO_PARAMS)));
        this.line.add(height);
    }

    public void reloadDataLists() {
        super.reloadDataLists();
    }

    @Override
    protected void setEntryEnabled(boolean enabled) {
        this.xPos.setEnabled(enabled);
        this.yPos.setEnabled(enabled);
        this.width.setEnabled(enabled);
        this.height.setEnabled(enabled);
        this.index.setEnabled(enabled);
    }

    @Override
    public FluidTanks.OverlayListEntry getEntry() {
        FluidTanks.OverlayListEntry entry = new FluidTanks.OverlayListEntry();
        entry.xPos = (int) xPos.getValue();
        entry.yPos = (int) yPos.getValue();
        entry.width = (int) width.getValue();
        entry.height = (int) height.getValue();
        entry.index = (int) index.getValue();
        return entry;
    }

    @Override
    public void setEntry(FluidTanks.OverlayListEntry entry) {
        xPos.setValue(entry.xPos);
        yPos.setValue(entry.yPos);
        width.setValue(entry.width);
        height.setValue(entry.height);
        index.setValue(entry.index);
    }
}
