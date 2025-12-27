package ${package}.block.entity;

public class GlobalFluidHandler implements IFluidHandler {
    private final FluidTank[] fluidTanks;
    private final FluidTank[] ioTanks;
    private final FluidTank[] inputTanks;
    private final FluidTank[] outputTanks;

    public GlobalFluidHandler(FluidTank[] fluidTanks, FluidTank[] ioTanks, FluidTank[] inputTanks, FluidTank[] outputTanks) {
        this.fluidTanks = fluidTanks;
        this.ioTanks = ioTanks;
        this.inputTanks = inputTanks;
        this.outputTanks = outputTanks;
    }

	@Override
	public int getTanks() {
		return fluidTanks.length;
	}

	@Override
	public FluidStack getFluidInTank(int tank) {
		return fluidTanks[tank].getFluid();
	}

	@Override
	public int getTankCapacity(int tank) {
		return fluidTanks[tank].getCapacity();
	}

	@Override
	public boolean isFluidValid(int tank, FluidStack stack) {
		return fluidTanks[tank].isFluidValid(stack);
	}

	@Override
	public int fill(FluidStack stack, FluidAction action) {
		FluidTank[] tanks = Stream.concat(Arrays.stream(inputTanks), Arrays.stream(ioTanks)).toArray(FluidTank[]::new);
		for (FluidTank tank : tanks) {
			int tankSpace = tank.getCapacity() - tank.getFluidAmount();
			if (stack.isEmpty()) {
				return 0;
			}
			if (!tank.getFluid().isEmpty() && tank.getFluid().getFluid().isSame(stack.getFluid())) {
				int fillAmount = Math.min(stack.getAmount(), tankSpace);
				if (fillAmount > 0) {
					return tank.fill(stack.copyWithAmount(fillAmount), action);
				} else {
					return 0;
				}
			}
			if (tank.isEmpty() && tank.isFluidValid(stack)) {
				return tank.fill(stack.copyWithAmount(stack.getAmount()), action);
			}
		}
		return 0;
	}

	@Override
	public FluidStack drain(FluidStack stack, FluidAction action) {
		FluidTank[] tanks = Stream.concat(Arrays.stream(outputTanks), Arrays.stream(ioTanks)).toArray(FluidTank[]::new);
		for (FluidTank tank : tanks) {
			if (stack.getFluid() == tank.getFluid().getFluid()) {
				return tank.drain(stack.getAmount(), action);
			}
		}
		return FluidStack.EMPTY;
	}

	@Override
	public FluidStack drain(int maxDrain, FluidAction action) {
		FluidTank[] tanks = Stream.concat(Arrays.stream(outputTanks), Arrays.stream(ioTanks)).toArray(FluidTank[]::new);

		for (FluidTank tank : tanks) {
			if (tank.getFluidAmount() > 0) {
				return tank.drain(maxDrain, action);
			}
		}
		return FluidStack.EMPTY;
	}

	public FluidTank getTank(int tank) {
		return fluidTanks[tank];
	}
}