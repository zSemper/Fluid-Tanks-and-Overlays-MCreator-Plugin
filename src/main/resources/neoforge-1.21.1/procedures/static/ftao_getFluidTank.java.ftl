private static ExtendedFluidTank getFluidTank(LevelAccessor world, BlockPos pos, int tankIndex) {
    if (world instanceof ILevelExtension extension) {
        IFluidHandler fluidHandler = extension.getCapability(Capabilities.FluidHandler.BLOCK, pos, null);
        if (fluidHandler != null) {
            try {
                var method = fluidHandler.getClass().getMethod("getTank", int.class);
                method.setAccessible(true);
                if (method.invoke(fluidHandler, tankIndex) instanceof ExtendedFluidTank tank) {
                    return tank;
                }
            } catch (ReflectiveOperationException ex) {
                ${JavaModName}.LOGGER.error(ex.getMessage());
                for (StackTraceElement element : ex.getStackTrace()) {
                    ${JavaModName}.LOGGER.error(element);
                }
            }
        }
    }
    return null;
}