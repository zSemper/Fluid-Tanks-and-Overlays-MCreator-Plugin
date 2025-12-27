package net.zsemper.ftao.parts;

import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.entries.JSimpleListEntry;
import net.mcreator.ui.component.util.ComponentUtils;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.help.IHelpContext;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.laf.themes.Theme;
import net.mcreator.ui.minecraft.FluidListField;
import net.zsemper.ftao.elements.FluidTanks;
import net.zsemper.ftao.utils.Constants;

import javax.swing.*;
import java.awt.*;
import java.util.List;

public class TankListEntry extends JSimpleListEntry<FluidTanks.TankListEntry> {
    private final JSpinner size = new JSpinner(new SpinnerNumberModel(8000, 1, 2147483647, 1));
    private final FluidListField fluidRestrictions;
    private final JComboBox<String> type = new JComboBox<>(new String[]{"Default", "Input", "Output"});

    public TankListEntry(MCreator mcreator, IHelpContext gui, JPanel parent, List<TankListEntry> entryList, int index) {
        super(parent, entryList);

        JLabel indexLabel = new JLabel(String.valueOf(index), SwingConstants.CENTER);
        indexLabel.setPreferredSize(new Dimension(30, Constants.HEIGHT));
        indexLabel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createLineBorder(Theme.current().getAltBackgroundColor(), 1), null, 0, 0, this.getFont().deriveFont(12.0F), Theme.current().getAltBackgroundColor()));
        ComponentUtils.deriveFont(indexLabel, 14);

        fluidRestrictions = new FluidListField(mcreator);

        size.setPreferredSize(new Dimension(140, Constants.HEIGHT));
        fluidRestrictions.setPreferredSize(new Dimension(400, Constants.HEIGHT));
        type.setPreferredSize(Constants.DIMENSION);

        line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tank_index"), L10N.label("elementGui.tankListEntry.tankIndex")));
        line.add(indexLabel);
        line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tanks/type"), L10N.label("elementGui.tankListEntry.tankType")));
        line.add(type);
        line.add(L10N.label("elementGui.tankListEntry.tankSize"));
        line.add(size);
        line.add(HelpUtils.wrapWithHelpButton(gui.withEntry("fluid_tanks/tanks/fluid_restrictions"), L10N.label("elementGui.tankListEntry.fluidRestrictions")));
        line.add(fluidRestrictions);
    }

    public void reloadDataLists() {
        super.reloadDataLists();
    }

    @Override
    protected void setEntryEnabled(boolean enabled) {
        size.setEnabled(enabled);
        fluidRestrictions.setEnabled(enabled);
        type.setEnabled(enabled);
    }

    @Override
    public FluidTanks.TankListEntry getEntry() {
        FluidTanks.TankListEntry entry = new FluidTanks.TankListEntry();
        entry.size = (int) size.getValue();
        if(!fluidRestrictions.getListElements().isEmpty()) {
            entry.fluidRestrictions = fluidRestrictions.getListElements();
        }
        entry.type = (String) type.getSelectedItem();
        return entry;
    }

    @Override
    public void setEntry(FluidTanks.TankListEntry entry) {
        size.setValue(entry.size);
        fluidRestrictions.setListElements(entry.fluidRestrictions);
        type.setSelectedItem(entry.type);
    }
}
