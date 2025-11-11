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
	private final ResourceLocation BLOCK_ATLAS = ResourceLocation.withDefaultNamespace("textures/atlas/blocks.png");

	public FluidStackWidget(Screen screen, FluidTank tank, int x, int y, int width, int height) {
		super(x, y, width, height, Component.empty());
		this.screen = screen;
		this.tank = tank;
	}

	public void renderWidget(GuiGraphics guiGraphics, int mouseX, int mouseY, float partialTick) {
		Minecraft minecraft = Minecraft.getInstance();
		renderTooltip(guiGraphics, mouseX, mouseY);

		if(!tank.getFluid().isEmpty()) {
		    FluidStack fluid = tank.getFluid();
		    IClientFluidTypeExtensions props = IClientFluidTypeExtensions.of(fluid.getFluid());

		    if(minecraft.getTextureManager().getTexture(BLOCK_ATLAS) instanceof TextureAtlas atlas) {
		        TextureAtlasSprite sprite = atlas.getSprite(props.getStillTexture(fluid));
		        float atlasWidth = (float) sprite.contents().width() / (sprite.getU1() - sprite.getU0());
		        float atlasHeight = (float) sprite.contents().height() / (sprite.getV1() - sprite.getV0());
		        int renderHeight = (int) (((float) tank.getFluidAmount() / tank.getCapacity()) * this.getHeight());

                for(int i = 0; i < Math.ceil(renderHeight / 16.0); i++) {
                    int y = this.getY() + this.getHeight() - (renderHeight - 16 * i);
                    int height = Math.min(16, renderHeight - 16 * i);

                    guiGraphics.blit(
                        RenderPipelines.GUI_TEXTURED,
                        BLOCK_ATLAS,
                        this.getX(),
                        y,
                        sprite.getU0() * atlasWidth,
                        sprite.getV0() * atlasHeight,
                        this.getWidth(),
                        height,
                        (int) atlasWidth,
                        (int) atlasHeight,
                        props.getTintColor()
                    );
                }
		    }
		}
	}

	protected void updateWidgetNarration(NarrationElementOutput output) {}

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
			guiGraphics.setTooltipForNextFrame(font, Arrays.asList(tooltipText), mouseX, mouseY);
		}
	}

	private static boolean mouseHover(int mouseX, int mouseY, int x, int y, int width, int height) {
		return (mouseX >= x && mouseX <= x + width) && (mouseY >= y && mouseY <= y + height);
	}
}

<#-- @formatter:on -->