package net.zsemper.ftao.parts;

import net.mcreator.element.ModElementType;
import net.mcreator.element.types.Block;
import net.mcreator.workspace.Workspace;
import net.mcreator.workspace.elements.ModElement;

import javax.swing.*;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.List;

public class BlockComboBox extends JPanel {
    private final JComboBox<BlockEntry> comboBox;

    public BlockComboBox() {
        super();
        setOpaque(false);

        comboBox = new JComboBox<>();
        comboBox.setRenderer(new BlockRenderer());
        add(comboBox);
    }

    public void setBlockEntries(Workspace workspace) {
        List<ModElement> elements = workspace.getModElements().stream()
                .filter(e -> e.getType() == ModElementType.BLOCK)
                .toList();
        List<Block> blocks = elements.stream()
                .filter(e -> e.getGeneratableElement() instanceof Block)
                .map(e -> (Block) e.getGeneratableElement())
                .toList();

        BlockEntry[] blockEntries = new BlockEntry[elements.size()];
        for (int i = 0; i < elements.size(); i++) {
            blockEntries[i] = new BlockEntry(blocks.get(i).generateModElementPicture(), elements.get(i).getName());
        }

        comboBox.setModel(new DefaultComboBoxModel<>(blockEntries));
    }

    public String getSelectedItem() {
        if (comboBox.getSelectedItem() instanceof BlockEntry block) {
            return block.name();
        }
        return "";
    }

    public void setSelectedItem(String item) {
        for (int i = 0; i < comboBox.getItemCount(); i++) {
            if (comboBox.getItemAt(i).name().equals(item)) {
                comboBox.setSelectedIndex(i);
                break;
            }
        }
    }

    static class BlockRenderer extends JLabel implements ListCellRenderer<BlockEntry> {
        public BlockRenderer() {
            setOpaque(false);
        }

        @Override
        public Component getListCellRendererComponent(JList<? extends BlockEntry> list, BlockEntry value, int index, boolean isSelected, boolean cellHasFocus) {
            if (value != null) {
                setText(value.name());
                setIcon(new ImageIcon(value.image()));
            }

            if (isSelected) {
                setBackground(list.getSelectionBackground());
                setForeground(list.getSelectionForeground());
            } else {
                setBackground(list.getBackground());
                setForeground(list.getForeground());
            }

            return this;
        }
    }

    record BlockEntry(BufferedImage image, String name) {}
}
