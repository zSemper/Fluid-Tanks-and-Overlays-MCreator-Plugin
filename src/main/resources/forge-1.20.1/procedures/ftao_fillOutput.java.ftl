{
    int _fill = ${opt.toInt(input$amount)};
	BlockEntity blockEntity = world.getBlockEntity(BlockPos.containing(${input$x}, ${input$y}, ${input$z}));
	if(blockEntity != null) {
		blockEntity.getCapability(ForgeCapabilities.FLUID_HANDLER, null).ifPresent(capability -> {
		    try {
                java.lang.reflect.Method _method = capability.getClass().getMethod("fillOutput", FluidStack.class);
                _method.setAccessible(true);
                _method.invoke(capability, new FluidStack(${input$fluidstack}.getFluid(), _fill));
		    } catch (NoSuchMethodException fallback) {
                capability.fill(new FluidStack(${input$fluidstack}.getFluid(), _fill), IFluidHandler.FluidAction.EXECUTE);
		    } catch (IllegalAccessException | InvocationTargetException e) {
		        e.printStackTrace();
		    }
		});
	}
}