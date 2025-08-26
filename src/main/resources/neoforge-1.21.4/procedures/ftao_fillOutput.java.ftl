{
	if(world instanceof ILevelExtension extension) {
		IFluidHandler fluidHandler = extension.getCapability(Capabilities.FluidHandler.BLOCK, BlockPos.containing(${input$x}, ${input$y}, ${input$z}), null);
		if(fluidHandler != null) {
			try {
				java.lang.reflect.Method method = fluidHandler.getClass().getMethod("fillOutput", FluidStack.class);
				method.setAccessible(true);
				method.invoke(fluidHandler, new FluidStack(${input$fluidstack}.getFluid(), (int) ${input$amount}));
			} catch (NoSuchMethodException fallback) {
				fluidHandler.fill(new FluidStack(${input$fluidstack}.getFluid(), (int) ${input$amount}), IFluidHandler.FluidAction.EXECUTE);
			} catch (IllegalAccessException | InvocationTargetException e) {
				e.printStackTrace();
			}
		}
	}
}