<#include "mcelements.ftl">

{
    BlockEntity blockEntity = world.getBlockEntity(BlockPos.containing(${input$x}, ${input$y}, ${input$z}));
    final FluidStack stack = new FluidStack(${input$fluid}.getFluid(), ${opt.toInt(input$amount)});
    if(blockEntity != null) {
		blockEntity.getCapability(ForgeCapabilities.FLUID_HANDLER, null).ifPresent(fluidHandler -> {
		    try {
                var method = fluidHandler.getClass().getMethod("getTank", int.class);
                method.setAccessible(true);
                Object tankObj = method.invoke(fluidHandler, ${opt.toInt(input$index)});
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
		});
    }
}