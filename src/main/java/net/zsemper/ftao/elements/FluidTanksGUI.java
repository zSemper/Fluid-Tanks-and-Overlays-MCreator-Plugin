package net.zsemper.ftao.elements;

import net.mcreator.element.ModElementType;
import net.mcreator.element.converter.v2021_1.LegacyDimensionProcedureRemover;
import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.JEmptyBox;
import net.mcreator.ui.component.SearchableComboBox;
import net.mcreator.ui.component.util.ComboBoxUtil;
import net.mcreator.ui.component.util.ComponentUtils;
import net.mcreator.ui.component.util.PanelUtils;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.minecraft.SingleModElementSelector;
import net.mcreator.ui.modgui.ModElementGUI;
import net.mcreator.ui.validation.AggregatedValidationResult;
import net.mcreator.workspace.elements.ModElement;
import net.zsemper.ftao.utils.Constants;
import net.zsemper.ftao.parts.OverlayList;
import net.zsemper.ftao.parts.TankList;

import javax.annotation.Nullable;
import javax.swing.*;
import java.awt.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.stream.Collectors;

public class FluidTanksGUI extends ModElementGUI<FluidTanks> {
    private final SearchableComboBox<String> block;
    private final JComboBox<String> inteType;
    private final TankList tanks;
    private final SingleModElementSelector gui;
    private final OverlayList overlays;

    public FluidTanksGUI(MCreator mcreator, ModElement modElement, boolean editingMode) {
        super(mcreator, modElement, editingMode);

        block = new SearchableComboBox<>();
        inteType = new JComboBox<>(new String[]{"Default", "Input", "Output"});
        tanks = new TankList(mcreator, this);
        gui = new SingleModElementSelector(mcreator, ModElementType.GUI);
        overlays = new OverlayList(mcreator, this);

        this.initGUI();
        super.finalizeGUI();
    }

    protected void initGUI() {
        JComponent blockName = L10N.label("elementGui.fluidTanks.block", Constants.NO_PARAMS);
        JComponent inteTankType = L10N.label("elementGui.fluidTanks.tankType", Constants.NO_PARAMS);
        JComponent guiName = L10N.label("elementGui.fluidTanks.gui", Constants.NO_PARAMS);

        ComponentUtils.deriveFont(blockName, 16);
        ComponentUtils.deriveFont(block, 16);
        ComponentUtils.deriveFont(inteTankType, 16);
        ComponentUtils.deriveFont(inteType, 16);
        ComponentUtils.deriveFont(guiName, 16);
        ComponentUtils.deriveFont(gui, 16);

        block.setOpaque(false);
        inteType.setOpaque(false);
        tanks.setOpaque(false);
        overlays.setOpaque(false);

        blockName.setPreferredSize(new Dimension(50, Constants.HEIGHT));
        block.setPreferredSize(new Dimension(200, Constants.HEIGHT));
        inteTankType.setPreferredSize(new Dimension(150, Constants.HEIGHT));
        inteType.setPreferredSize(new Dimension(200, Constants.HEIGHT));
        guiName.setPreferredSize(new Dimension(50, 40));
        gui.setPreferredSize(new Dimension(200, 40));

        // Global
        JPanel global = new JPanel(new BorderLayout());
        global.setOpaque(false);

        // Tanks
        JPanel globalTanks = new JPanel(new BorderLayout());
        globalTanks.setOpaque(false);

        JPanel mainTanks = new JPanel();
        mainTanks.setLayout(new BoxLayout(mainTanks, BoxLayout.X_AXIS));
        mainTanks.setOpaque(false);
        mainTanks.add(blockName);
        mainTanks.add(block);
        mainTanks.add(new JEmptyBox(40, Constants.HEIGHT));
        mainTanks.add(HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/tanks/type"), inteTankType));
        mainTanks.add(inteType);
        mainTanks.setBorder(BorderFactory.createEmptyBorder(10, 10, 0, 0));

        JComponent tankPanel = PanelUtils.northAndCenterElement(HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/tanks"), L10N.label("elementGui.fluidTanks.tanks", Constants.NO_PARAMS)), this.tanks);
        tankPanel.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
        globalTanks.add(PanelUtils.northAndCenterElement(PanelUtils.join(0, new Component[]{mainTanks}), tankPanel));


        // Overlays
        JPanel globalOverlays = new JPanel(new BorderLayout());
        globalOverlays.setOpaque(false);

        JPanel mainOverlays = new JPanel();
        mainOverlays.setLayout(new BoxLayout(mainOverlays, BoxLayout.X_AXIS));
        mainOverlays.setOpaque(false);
        mainOverlays.add(guiName);
        mainOverlays.add(gui);
        mainOverlays.setBorder(BorderFactory.createEmptyBorder(10, 10, 0, 0));

        JComponent overlayPanel = PanelUtils.northAndCenterElement(HelpUtils.wrapWithHelpButton(this.withEntry("fluid_tanks/overlays"), L10N.label("elementGui.fluidTanks.overlays", Constants.NO_PARAMS)), this.overlays);
        overlayPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        globalOverlays.add(PanelUtils.northAndCenterElement(PanelUtils.join(0, new Component[]{mainOverlays}), overlayPanel));

        JPanel main = new JPanel(new GridLayout(2, 1, 2, 2));
        main.setOpaque(false);
        main.add(globalTanks);
        main.add(globalOverlays);

        global.add(PanelUtils.northAndCenterElement(new JEmptyBox(), main));

        addPage(L10N.t("elementgui.common.page_properties", Constants.NO_PARAMS), global);
    }

    protected AggregatedValidationResult validatePage(int page) {
        if(block.getSelectedItem() == null) {
            return new AggregatedValidationResult.FAIL(L10N.t("elementGui.fluidTanks.valBlock", Constants.NO_PARAMS));
        }
        return new AggregatedValidationResult.PASS();
    }

    public void reloadDataLists() {
        super.reloadDataLists();

        ComboBoxUtil.updateComboBoxContents(block, this.mcreator.getWorkspace().getModElements().stream().filter((var) -> {
            return var.getType() == ModElementType.BLOCK;
        }).map(ModElement::getName).collect(Collectors.toList()));

        tanks.reloadDataLists();
        overlays.reloadDataLists();
    }

    protected void afterGeneratableElementStored() {
        try {
            mcreator.getGenerator().generateElement(mcreator.getWorkspace().getModElementByName(block.getSelectedItem()).getGeneratableElement(), true);
            mcreator.getGenerator().generateElement(mcreator.getWorkspace().getModElementByName(gui.getEntry()).getGeneratableElement(), true);
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
