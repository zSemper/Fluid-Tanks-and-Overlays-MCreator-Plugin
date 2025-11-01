<#include "mcelements.ftl">

{
    new Object() {
        public void setFluidWithAmount(LevelAccessor level, BlockPos pos, int tank, FluidStack fluid, int amount) {
            if(level instanceof ILevelExtension extension) {
                IFluidHandler fluidHandler = extension.getCapability(Capabilities.FluidHandler.BLOCK, pos, null);
                if(fluidHandler != null) {
					int fill = Math.min(fluidHandler.getTankCapacity(tank), amount);
                    FluidStack stack = new FluidStack(fluid.getFluid(), fill);

			        try {
				        var method = fluidHandler.getClass().getMethod("getTank", int.class);
				        method.setAccessible(true);
				        Object tankObj = method.invoke(fluidHandler, tank);
				        if(tankObj instanceof FluidTank fTank) {
				            fTank.setFluid(stack);
				        } else if(fluidHandler instanceof FluidTank fTankA) {
				            fTankA.setFluid(stack);
				        }
			        } catch (NoSuchMethodException fallback) {
				        if(fluidHandler instanceof FluidTank fTankF) {
				            fTankF.setFluid(stack);
				        }
			        } catch (IllegalAccessException | InvocationTargetException e) {
				        e.printStackTrace();
			        }
                }
            }
        }
    }.setFluidWithAmount(world, BlockPos.containing(${input$x}, ${input$y}, ${input$z}), ${opt.toInt(input$index)}, ${input$fluid}, ${opt.toInt(input$amount)});
}