package net.zsemper.ftao.parts;

import net.mcreator.blockly.data.Dependency;
import net.mcreator.ui.component.JEmptyBox;
import net.mcreator.ui.component.util.PanelUtils;
import net.mcreator.ui.dialogs.wysiwyg.AbstractWYSIWYGDialog;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.procedure.AbstractProcedureSelector;
import net.mcreator.ui.procedure.ProcedureSelector;
import net.mcreator.ui.wysiwyg.WYSIWYGEditor;
import net.mcreator.workspace.elements.VariableTypeLoader;

import javax.annotation.Nullable;
import javax.swing.*;
import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

public class FluidTankDialog extends AbstractWYSIWYGDialog<FluidTank> {
    public FluidTankDialog(WYSIWYGEditor editor, @Nullable FluidTank fluidTank) {
        super(editor, fluidTank);

        setModalityType(Dialog.DEFAULT_MODALITY_TYPE);
        setSize(320, 180);
        setLocationRelativeTo(editor.mcreator);

        JSpinner id = new JSpinner(new SpinnerNumberModel(0, 0, 1000, 1));
        JButton ok = new JButton(UIManager.getString("OptionPane.okButtonText"));
        JButton cancel = new JButton(UIManager.getString("OptionPane.cancelButtonText"));

        AbstractProcedureSelector.ReloadContext context = AbstractProcedureSelector.ReloadContext.create(editor.mcreator.getWorkspace());
        ProcedureSelector tooltipSelector = new ProcedureSelector(
                null,
                editor.mcreator,
                L10N.t("dialog.gui.fluid_tank_tooltip"),
                VariableTypeLoader.BuiltInTypes.STRING,
                Dependency.fromString("x:number/y:number/z:number/world:world/entity:entity")
        );
        tooltipSelector.refreshList(context);

        setTitle(L10N.t("dialog.gui.add_fluid_tank"));

        add("North", PanelUtils.join(FlowLayout.CENTER, L10N.label("dialog.gui.fluid_tank_id"), id));
        add("Center", PanelUtils.join(new JEmptyBox(10, 10), tooltipSelector, new JEmptyBox(10, 10)));
        add("South", PanelUtils.join(ok, cancel));

        getRootPane().setDefaultButton(ok);

        addWindowListener(new WindowAdapter() {
            @Override
            public void windowActivated(WindowEvent e) {
                SwingUtilities.invokeLater(id::requestFocus);
            }
        });

        if (fluidTank != null) {
            ok.setText(L10N.t("dialog.common.save_changes"));
            id.setValue(fluidTank.id);
            tooltipSelector.setSelectedProcedure(fluidTank.tooltip);
        }

        ok.addActionListener(e -> {
            dispose();

            if (fluidTank == null) {
                FluidTank component = new FluidTank(0, 0, 16, 16, (int) id.getValue(), tooltipSelector.getSelectedProcedure());
                setEditingComponent(component);
                editor.editor.addComponent(component);
                editor.list.setSelectedValue(component, true);
                editor.editor.moveMode();
            } else {
                int idx = editor.components.indexOf(fluidTank);
                editor.components.remove(fluidTank);
                FluidTank comp = new FluidTank(fluidTank.x, fluidTank.y, fluidTank.width, fluidTank.height, (int) id.getValue(), tooltipSelector.getSelectedProcedure());
                editor.components.add(idx, comp);
                setEditingComponent(comp);
            }
        });
        cancel.addActionListener(e -> dispose());

        setVisible(true);
    }
}
