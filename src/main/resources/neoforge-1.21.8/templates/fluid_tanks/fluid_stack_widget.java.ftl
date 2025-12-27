/**
 * Copyright (c) 2025 zSemper
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the MIT License
 */

<#-- @formatter:off -->

package ${package}.utils;

import java.util.Arrays;

public class FluidStackWidget extends AbstractWidget {
	private final Screen screen;
	private final FluidTank tank;
	@Nullable
	private final String tooltip;
	private final ResourceLocation BLOCK_ATLAS = ResourceLocation.withDefaultNamespace("textures/atlas/blocks.png");

	public FluidStackWidget(Screen screen, FluidTank tank, int x, int y, int width, int height, String tooltip) {
		super(x, y, width, height, Component.empty());
		this.screen = screen;
		this.tank = tank;
		this.tooltip = tooltip;
	}

	public void renderWidget(GuiGraphics guiGraphics, int mouseX, int mouseY, float partialTick) {
		renderTooltip(guiGraphics, mouseX, mouseY);

		if (!tank.isEmpty()) {
			IClientFluidTypeExtensions props = IClientFluidTypeExtensions.of(tank.getFluid().getFluid());

			if (Minecraft.getInstance().getTextureManager().getTexture(BLOCK_ATLAS) instanceof TextureAtlas atlas) {
				TextureAtlasSprite sprite = atlas.getSprite(props.getStillTexture(tank.getFluid()));
				float atlasWidth = (float) sprite.contents().width() / (sprite.getU1() - sprite.getU0());
				float atlasHeight = (float) sprite.contents().height() / (sprite.getV1() - sprite.getV0());
                int renderableHeight = (tank.getFluidAmount() * this.getHeight()) / tank.getCapacity();

				for (int i = 0; (double) i < Math.ceil(renderableHeight / 16.0); i++) {
				    int renderHeight = Math.min(16, renderableHeight - 16 * i);
					int yOffset = this.getHeight() - (renderableHeight - 16 * i);

					for (int j = 0; (double) j < Math.ceil(this.getWidth() / 16.0); j++) {
					    int renderWidth = Math.min(16, this.getWidth() - 16 * j);

                        guiGraphics.blit(
                            RenderPipelines.GUI_TEXTURED,
                            BLOCK_ATLAS,
                            this.getX() + 16 * j,
                            this.getY() + yOffset,
                            sprite.getU0() * atlasWidth,
                            sprite.getV0() * atlasHeight,
                            renderWidth,
                            renderHeight,
                            (int) atlasWidth,
                            (int) atlasHeight,
                            props.getTintColor()
                        );
					}
				}
 			}
		}
	}

	protected void updateWidgetNarration(NarrationElementOutput output) {}

	public void renderTooltip(GuiGraphics guiGraphics, int mouseX, int mouseY) {
		if (mouseHover(mouseX, mouseY, this.getX(), this.getY(), this.getWidth(), this.getHeight())) {
			Font font = screen.getMinecraft().font;

			FormattedCharSequence[] tooltipText;

			if (tooltip == null) {
			    tooltipText = new FormattedCharSequence[2];
			    int amount;

			    if (!tank.isEmpty()) {
			        tooltipText[0] = tank.getFluid().getHoverName().getVisualOrderText();
			        amount = tank.getFluidAmount();
			    } else {
			        tooltipText[0] = Component.translatable("block.minecraft.air").getVisualOrderText();
			        amount = 0;
			    }

			    tooltipText[1] = Component.literal(amount + "mB / " + tank.getCapacity() + "mB").getVisualOrderText();
			} else {
			    String[] parts = tooltip.split("\n");
			    tooltipText = new FormattedCharSequence[parts.length];

			    for (int i = 0; i < parts.length; i++) {
			        tooltipText[i] = Component.literal(parts[i]).getVisualOrderText();
			    }
			}
			guiGraphics.setTooltipForNextFrame(font, Arrays.asList(tooltipText), mouseX, mouseY);
		}
	}

	private static boolean mouseHover(int mouseX, int mouseY, int x, int y, int width, int height) {
		return (mouseX >= x && mouseX <= x + width) && (mouseY >= y && mouseY <= y + height);
	}
}
