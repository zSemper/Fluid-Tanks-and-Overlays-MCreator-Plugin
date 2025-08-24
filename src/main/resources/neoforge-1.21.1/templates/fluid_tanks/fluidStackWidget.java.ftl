/**
 * Copyright (c) 2025 zSemper
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the MIT License
 */

package ${package}.utils;

import java.util.Arrays;

public class FluidStackWidget extends AbstractWidget {
	private final Screen screen;
	private final FluidTank tank;

	public FluidStackWidget(Screen screen, FluidTank tank, int x, int y, int width, int height) {
		super(x, y, width, height, Component.empty());
		this.screen = screen;
		this.tank = tank;
	}

	public void renderWidget(GuiGraphics guiGraphics, int mouseX, int mouseY, float partialTick) {
		Minecraft minecraft = Minecraft.getInstance();
		RenderSystem.defaultBlendFunc();
		RenderSystem.enableDepthTest();

		this.renderTooltip(guiGraphics, mouseX, mouseY);

		if(!tank.getFluid().isEmpty()) {
			FluidStack fluidStack = tank.getFluid();
			IClientFluidTypeExtensions props = IClientFluidTypeExtensions.of(fluidStack.getFluid());

			ResourceLocation still = props.getStillTexture(fluidStack);
			AbstractTexture texture = minecraft.getTextureManager().getTexture(InventoryMenu.BLOCK_ATLAS);

			if(texture instanceof TextureAtlas atlas) {
				atlas = (TextureAtlas) texture;
				TextureAtlasSprite sprite = atlas.getSprite(still);
				int color = props.getTintColor();

				RenderSystem.setShaderColor(
					(float) FastColor.ARGB32.red(color) / 255.0F,
					(float) FastColor.ARGB32.green(color) / 255.0F,
					(float) FastColor.ARGB32.blue(color) / 255.0F,
					(float) FastColor.ARGB32.alpha(color) / 255.0F
				);
				RenderSystem.enableBlend();

				int stored = tank.getFluidAmount();
				float capacity = (float) tank.getCapacity();
				float filledVolume = (float) stored / capacity;

				int renderableHeight = (int) (filledVolume * (float) this.getHeight());
				int atlasWidth = (int) ((float) sprite.contents().width() / (sprite.getU1() - sprite.getU0()));
				int atlasHeight = (int) ((float) sprite.contents().height() / (sprite.getV1() - sprite.getV0()));

				guiGraphics.pose().pushPose();
				guiGraphics.pose().translate(0.0F, (float) (this.getHeight() - 16), 0.0F);

				for(int i = 0; (double) i < Math.ceil((double) ((float) renderableHeight / 16.0F)); ++i) {
					int drawingHeight = Math.min(16, renderableHeight - 16 * i);
					int notDrawingHeight = 16 - drawingHeight;

					guiGraphics.blit(
						InventoryMenu.BLOCK_ATLAS,
						this.getX(),
						this.getY() + notDrawingHeight,
						0,
						sprite.getU0() * (float) atlasWidth,
						sprite.getV0() * (float) atlasHeight + (float) notDrawingHeight,
						this.getWidth(),
						drawingHeight,
						atlasWidth,
						atlasHeight
					);
					guiGraphics.pose().translate(0.0F, -16.0F, 0.0F);
				}

				RenderSystem.setShaderColor(1.0F, 1.0F, 1.0F, 1.0F);
				guiGraphics.pose().popPose();
 			}
		}

		RenderSystem.disableDepthTest();
	}

	protected void updateWidgetNarration(NarrationElementOutput pNarrationElementOutput) {
}

	public void renderTooltip(GuiGraphics guiGraphics, int mouseX, int mouseY) {
		if (mouseHover(mouseX, mouseY, this.getX(), this.getY(), this.getWidth(), this.getHeight())) {
			Font font = screen.getMinecraft().font;
			FormattedCharSequence[] tooltipText = new FormattedCharSequence[2];
			int amount;

			if (!tank.getFluid().isEmpty()) {
				tooltipText[0] = tank.getFluid().getHoverName().getVisualOrderText();
				amount = tank.getFluidAmount();
			} else {
				tooltipText[0] = Component.literal("Air").getVisualOrderText();
				amount = 0;
			}

			tooltipText[1] = Component.literal(amount + "mB / " + tank.getCapacity() + "mB").getVisualOrderText();
			guiGraphics.renderTooltip(font, Arrays.asList(tooltipText), mouseX, mouseY);
		}
	}

	private static boolean mouseHover(int mouseX, int mouseY, int x, int y, int width, int height) {
		return (mouseX >= x && mouseX <= x + width) && (mouseY >= y && mouseY <= y + height);
	}
}
