package net.zsemper.ftao.parts;

import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.entries.JSimpleEntriesList;
import net.mcreator.ui.help.IHelpContext;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.laf.themes.Theme;
import net.zsemper.ftao.elements.FluidTanks;
import net.zsemper.ftao.utils.Constants;

import javax.swing.*;
import java.util.List;

public class TankList extends JSimpleEntriesList<TankListEntry, FluidTanks.TankListEntry> {
    public TankList(MCreator mcreator, IHelpContext gui) {
        super(mcreator, gui);

        this.add.setText(L10N.t("elementGui.fluidTanks.tankListAdd", Constants.NO_PARAMS));
        this.setBorder(BorderFactory.createTitledBorder(BorderFactory.createLineBorder(Theme.current().getForegroundColor(), 1), L10N.t("elementGui.fluidTanks.tankListEntries", Constants.NO_PARAMS), 0, 0, this.getFont().deriveFont(12.0F), Theme.current().getForegroundColor()));
    }

    protected TankListEntry newEntry(JPanel parent, List<TankListEntry> entryList, boolean userAction) {
        return new TankListEntry(this.mcreator, this.gui, parent, entryList, getEntries().size() + 1);
    }
}
