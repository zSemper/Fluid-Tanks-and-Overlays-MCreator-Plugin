package net.zsemper.ftao.parts;

import net.mcreator.element.parts.gui.SizedComponent;
import net.mcreator.element.parts.procedure.Procedure;import net.mcreator.element.parts.procedure.StringProcedure;
import net.mcreator.ui.wysiwyg.WYSIWYG;
import net.mcreator.ui.wysiwyg.WYSIWYGEditor;

import java.awt.*;

public class FluidTank extends SizedComponent {
    public final int id;
    public final Procedure tooltip;

    public FluidTank(int x, int y, int width, int height, int id, Procedure tooltip) {
        super(x, y, width, height);
        this.id = id;
        this.tooltip = tooltip;
    }

    @Override
    public String getName() {
        return "fluid_tank_" + id;
    }

    @Override
    public void paintComponent(int cx, int cy, WYSIWYGEditor wysiwygEditor, Graphics2D g) {
        String renderText = getName();

        g.setColor(new Color(0, 0, 160, 70));
        g.fillRect(cx, cy, width, height);

        g.setColor(new Color(230, 230, 230));
        g.setFont(g.getFont().deriveFont(5f));

        int textHeight = (int) (g.getFont().getStringBounds(renderText, WYSIWYG.frc).getHeight());
        g.drawString(renderText, cx + 2, cy + textHeight + 1);
    }

    @Override
    public int getWeight() {
        return 100;
    }

    @Override
    public boolean canChangeHeight() {
        return true;
    }
}
