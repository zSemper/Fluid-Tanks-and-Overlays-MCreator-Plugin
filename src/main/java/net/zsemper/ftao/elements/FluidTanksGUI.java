package net.zsemper.ftao.elements;

import net.mcreator.element.ModElementType;
import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.util.ComponentUtils;
import net.mcreator.ui.component.util.PanelUtils;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.minecraft.SingleModElementSelector;
import net.mcreator.ui.modgui.ModElementGUI;
import net.mcreator.workspace.elements.ModElement;
import net.zsemper.ftao.parts.BlockComboBox;
import net.zsemper.ftao.utils.Constants;
import net.zsemper.ftao.parts.OverlayList;
import net.zsemper.ftao.parts.TankList;

import javax.annotation.Nullable;
import javax.swing.*;
import java.awt.*;
import java.net.URI;
import java.net.URISyntaxException;

public class FluidTanksGUI extends ModElementGUI<FluidTanks> {
    private final BlockComboBox block;
    private final JComboBox<String> inteType;
    private final TankList tanks;
    private final SingleModElementSelector gui;
    private final OverlayList overlays;
    private JPanel globalOverlays;

    public FluidTanksGUI(MCreator mcreator, ModElement modElement, boolean editingMode) {
        super(mcreator, modElement, editingMode);

        block = new BlockComboBox();
        inteType = new JComboBox<>(new String[]{"Default", "Input", "Output"});
        tanks = new TankList(mcreator, this);
        gui = new SingleModElementSelector(mcreator, ModElementType.GUI);
        overlays = new OverlayList(mcreator, this);

        this.initGUI();
        super.finalizeGUI();
    }

    protected void initGUI() {
        JComponent blockName = L10N.label("elementGui.fluidTanks.block");
        JComponent inteTankType = L10N.label("elementGui.fluidTanks.tankType");
        JComponent guiName = L10N.label("elementGui.fluidTanks.gui");

        ComponentUtils.deriveFont(blockName, 16);
        ComponentUtils.deriveFont(inteTankType, 16);
        ComponentUtils.deriveFont(inteType, 16);
        ComponentUtils.deriveFont(guiName, 16);
        ComponentUtils.deriveFont(gui, 16);

        JComponent inteTankTypeFormatted = HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/tanks/type"), inteTankType);

        block.setOpaque(false);
        inteType.setOpaque(false);
        tanks.setOpaque(false);
        overlays.setOpaque(false);

        blockName.setPreferredSize(new Dimension(185, 40));
        block.setPreferredSize(new Dimension(200, 40));
        inteTankTypeFormatted.setPreferredSize(new Dimension(200, 40));
        inteType.setPreferredSize(new Dimension(200, 40));
        guiName.setPreferredSize(new Dimension(50, 40));
        gui.setPreferredSize(new Dimension(200, 40));

        // Tanks
        JPanel globalTanks = new JPanel(new BorderLayout());
        globalTanks.setOpaque(false);

        JPanel mainTanks = new JPanel();
        mainTanks.setLayout(new BoxLayout(mainTanks, BoxLayout.Y_AXIS));
        mainTanks.setOpaque(false);
        mainTanks.add(PanelUtils.join(FlowLayout.LEFT, PanelUtils.join(FlowLayout.LEFT, blockName), block));
        mainTanks.add(PanelUtils.join(FlowLayout.LEFT, inteTankTypeFormatted, inteType));

        JComponent tankPanel = PanelUtils.northAndCenterElement(HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/tanks"), L10N.label("elementGui.fluidTanks.tanks")), this.tanks);
        tankPanel.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
        globalTanks.add(PanelUtils.northAndCenterElement(PanelUtils.join(0, mainTanks), tankPanel));


        // Overlays
        globalOverlays = new JPanel(new BorderLayout());
        globalOverlays.setOpaque(false);

        JPanel mainOverlays = new JPanel();
        mainOverlays.setLayout(new BoxLayout(mainOverlays, BoxLayout.X_AXIS));
        mainOverlays.setOpaque(false);
        mainOverlays.add(guiName);
        mainOverlays.add(gui);
        mainOverlays.setBorder(BorderFactory.createEmptyBorder(10, 10, 0, 0));

        JPanel mainOverlaysWithInfo = new JPanel();
        mainOverlaysWithInfo.setLayout(new BoxLayout(mainOverlaysWithInfo, BoxLayout.Y_AXIS));
        mainOverlaysWithInfo.setOpaque(false);
        mainOverlaysWithInfo.add(L10N.label("elementGui.fluidTanks.overlayInfo"));
        mainOverlaysWithInfo.add(mainOverlays);

        JComponent overlayPanel = PanelUtils.northAndCenterElement(HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/overlays"), L10N.label("elementGui.fluidTanks.overlays")), this.overlays);
        overlayPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        globalOverlays.add(PanelUtils.northAndCenterElement(PanelUtils.join(0, mainOverlaysWithInfo), overlayPanel));

        JPanel global = new JPanel();
        global.setLayout(new BoxLayout(global, BoxLayout.Y_AXIS));
        global.setOpaque(false);
        global.add(globalTanks);
        global.add(globalOverlays);

        addPage(L10N.t("elementgui.common.page_properties"), global);
    }

    public void reloadDataLists() {
        super.reloadDataLists();
        block.setBlockEntries(mcreator.getWorkspace());
        tanks.reloadDataLists();
        overlays.reloadDataLists();
    }

    protected void afterGeneratableElementStored() {
        try {
            mcreator.getGenerator().generateElement(mcreator.getWorkspace().getModElementByName(block.getSelectedItem()).getGeneratableElement(), true);
        } catch (Exception e) {
            Constants.LOG.error(e.getMessage());
        }
    }

    @Override
    protected void openInEditingMode(FluidTanks fluidTanks) {
        block.setSelectedItem(fluidTanks.block);
        inteType.setSelectedItem(fluidTanks.inteType);
        tanks.setEntries(fluidTanks.tanks);
        gui.setEntry(fluidTanks.gui);
        overlays.setEntries(fluidTanks.overlays);

        if (fluidTanks.overlays.isEmpty()) globalOverlays.setVisible(false);
    }

    @Override
    public FluidTanks getElementFromGUI() {
        FluidTanks fluidTanks = new FluidTanks(this.modElement);
        fluidTanks.block = block.getSelectedItem();
        fluidTanks.inteType = (String) inteType.getSelectedItem();
        fluidTanks.tanks = tanks.getEntries();
        fluidTanks.gui = gui.getEntry();
        fluidTanks.overlays = overlays.getEntries();
        return fluidTanks;
    }

    @Override
    @Nullable
    public URI contextURL() throws URISyntaxException {
        return new URI(Constants.WIKI_URL + "fluid_tanks");
    }
}
