<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 #
 # Additional permission for code generator templates (*.ftl files)
 #
 # As a special exception, you may create a larger work that contains part or
 # all of the MCreator code generator templates (*.ftl files) and distribute
 # that work under terms of your choice, so long as that work isn't itself a
 # template for code generation. Alternatively, if you modify or redistribute
 # the template itself, you may (at your option) remove this special exception,
 # which will cause the template and the resulting code generator output files
 # to be licensed under the GNU General Public License without this special
 # exception.
-->

<#-- @formatter:off -->

<#assign tanks = w.hasElementsOfType("fluid_tanks")?then(w.getGElementsOfType("fluid_tanks")?filter(tank -> (tank.block?? && tank.block == name)), "")>
<#assign fluidTank = tanks?has_content?then(tanks[0], "")>

package ${package}.block.entity;

<#compress>
public class ${name}BlockEntity extends RandomizableContainerBlockEntity implements WorldlyContainer {

	private NonNullList<ItemStack> stacks = NonNullList.<ItemStack>withSize(${data.inventorySize}, ItemStack.EMPTY);

	private final LazyOptional<? extends IItemHandler>[] handlers = SidedInvWrapper.create(this, Direction.values());

	public ${name}BlockEntity(BlockPos position, BlockState state) {
		super(${JavaModName}BlockEntities.${data.getModElement().getRegistryNameUpper()}.get(), position, state);
	}

	@Override public void load(CompoundTag compound) {
		super.load(compound);

		if (!this.tryLoadLootTable(compound))
			this.stacks = NonNullList.withSize(this.getContainerSize(), ItemStack.EMPTY);

		ContainerHelper.loadAllItems(compound, this.stacks);

		<#if data.hasEnergyStorage>
		if(compound.get("energyStorage") instanceof IntTag intTag)
			energyStorage.deserializeNBT(intTag);
		</#if>

		<#if data.isFluidTank>
		    <#if fluidTank != "">
		        for(int i = 0; i < fluidTanks.length; i++) {
		            fluidTanks[i].readFromNBT(compound.getCompound("fluidTank" + i));
		        }
		    <#else>
		        fluidTank0.readFromNBT(compound.getCompound("fluidTank0"));
		    </#if>
		</#if>
	}

	@Override public void saveAdditional(CompoundTag compound) {
		super.saveAdditional(compound);

		if (!this.trySaveLootTable(compound)) {
			ContainerHelper.saveAllItems(compound, this.stacks);
		}

		<#if data.hasEnergyStorage>
		compound.put("energyStorage", energyStorage.serializeNBT());
		</#if>

		<#if data.isFluidTank>
		    <#if fluidTank != "">
		        for(int i = 0; i < fluidTanks.length; i++) {
		            compound.put("fluidTank" + i, fluidTanks[i].writeToNBT(new CompoundTag()));
		        }
		    <#else>
		        compound.put("fluidTank0", fluidTank0.writeToNBT(new CompoundTag()));
            </#if>
		</#if>
	}

	@Override public ClientboundBlockEntityDataPacket getUpdatePacket() {
		return ClientboundBlockEntityDataPacket.create(this);
	}

	@Override public CompoundTag getUpdateTag() {
		return this.saveWithFullMetadata();
	}

	@Override public int getContainerSize() {
		return stacks.size();
	}

	@Override public boolean isEmpty() {
		for (ItemStack itemstack : this.stacks)
			if (!itemstack.isEmpty())
				return false;
		return true;
	}

	@Override public Component getDefaultName() {
		return Component.literal("${registryname}");
	}

	@Override public int getMaxStackSize() {
		return ${data.inventoryStackSize};
	}

	@Override public AbstractContainerMenu createMenu(int id, Inventory inventory) {
		<#if !data.guiBoundTo?has_content>
		return ChestMenu.threeRows(id, inventory);
		<#else>
		return new ${data.guiBoundTo}Menu(id, inventory, new FriendlyByteBuf(Unpooled.buffer()).writeBlockPos(this.worldPosition));
		</#if>
	}

	@Override public Component getDisplayName() {
		return Component.literal("${data.name}");
	}

	@Override protected NonNullList<ItemStack> getItems() {
		return this.stacks;
	}

	@Override protected void setItems(NonNullList<ItemStack> stacks) {
		this.stacks = stacks;
	}

	@Override public boolean canPlaceItem(int index, ItemStack stack) {
		<#list data.inventoryOutSlotIDs as id>
		if (index == ${id})
			return false;
		</#list>
		return true;
	}

	<#-- START: ISidedInventory -->
	@Override public int[] getSlotsForFace(Direction side) {
		return IntStream.range(0, this.getContainerSize()).toArray();
	}

	@Override public boolean canPlaceItemThroughFace(int index, ItemStack stack, @Nullable Direction direction) {
		return this.canPlaceItem(index, stack);
	}

	@Override public boolean canTakeItemThroughFace(int index, ItemStack stack, Direction direction) {
		<#list data.inventoryInSlotIDs as id>
		if (index == ${id})
			return false;
        </#list>
		return true;
	}
	<#-- END: ISidedInventory -->

	<#if data.hasEnergyStorage>
	private final EnergyStorage energyStorage = new EnergyStorage(${data.energyCapacity}, ${data.energyMaxReceive}, ${data.energyMaxExtract}, ${data.energyInitial}) {
		@Override public int receiveEnergy(int maxReceive, boolean simulate) {
			int retval = super.receiveEnergy(maxReceive, simulate);
			if(!simulate) {
				setChanged();
				level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
			}
			return retval;
		}

		@Override public int extractEnergy(int maxExtract, boolean simulate) {
			int retval = super.extractEnergy(maxExtract, simulate);
			if(!simulate) {
				setChanged();
				level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
			}
			return retval;
		}
	};
    </#if>

    <#if data.isFluidTank>
        // FTaO: added IFluidHandler
	    public final IFluidHandler fluidHandler = new IFluidHandler() {
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

			    for(FluidTank tank : tanks) {
				    int tankSpace = tank.getCapacity() - tank.getFluidAmount();

				    if(stack.isEmpty()) {
					    return 0;
				    }

				    if(!tank.getFluid().isEmpty() && tank.getFluid().getFluid().isSame(stack.getFluid())) {
					    int fillAmount = Math.min(stack.getAmount(), tankSpace);
					    if(fillAmount > 0) {
					        FluidStack fs = stack.copy();
					        fs.setAmount(fillAmount);
						    return tank.fill(fs, action);
					    } else {
						    return 0;
					    }
				    }

				    if(tank.isEmpty() && tank.isFluidValid(stack)) {
				        FluidStack fs = stack.copy();
				        fs.setAmount(stack.getAmount());
					    return tank.fill(fs, action);
				    }
			    }
			    return 0;
		    }

		    @Override
		    public FluidStack drain(FluidStack stack, FluidAction action) {
		        FluidTank[] tanks = Stream.concat(Arrays.stream(outputTanks), Arrays.stream(ioTanks)).toArray(FluidTank[]::new);

                for(FluidTank tank : tanks) {
				    if(stack.getFluid() == tank.getFluid().getFluid()) {
					    return tank.drain(stack.getAmount(), action);
				    }
			    }
			    return FluidStack.EMPTY;
	    	}

	    	@Override
	    	public FluidStack drain(int maxDrain, FluidAction action) {
	    	    FluidTank[] tanks = Stream.concat(Arrays.stream(outputTanks), Arrays.stream(ioTanks)).toArray(FluidTank[]::new);

	    		for(FluidTank tank : tanks) {
	    			if(tank.getFluidAmount() > 0) {
	    				return tank.drain(maxDrain, action);
	    			}
	    		}
	    		return FluidStack.EMPTY;
	    	}

	    	// FTaO
		    public FluidTank getTank(int index) {
			    return fluidTanks[index];
		    }
	    };

        private final FluidTank fluidTank0 = new FluidTank(${data.fluidCapacity}
            <#if data.fluidRestrictions?has_content>
                , fs -> {
                    <#list data.fluidRestrictions as restrict>
                        if(fs.getFluid() == ${restrict}) return true;
                    </#list>
                    return false;
                }
            </#if>
        ) {
            @Override
            protected void onContentsChanged() {
                super.onContentsChanged();
	    		setChanged();
	    		level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
            }

		    @Override
		    public void setFluid(FluidStack stack) {
			    super.setFluid(stack);
			    setChanged();
			    level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
		    }
        };

        <#if fluidTank != "">
	        <#list fluidTank.tanks as tank>
	            private final FluidTank fluidTank${tank?index + 1} = new FluidTank(${tank.size}
	                <#if tank.fluidRestrictions?has_content>
	                    , fs -> {
	                        <#list tank.fluidRestrictions as restrict>
	                            if(fs.getFluid() == ${restrict}) return true;
	                        </#list>
	                        return false;
	                    }
	                </#if>
	            ) {
	                @Override
	                protected void onContentsChanged() {
	                    super.onContentsChanged();
	                    setChanged();
	                    level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
	                }

		            @Override
		            public void setFluid(FluidStack stack) {
			            super.setFluid(stack);
			            setChanged();
			            level.sendBlockUpdated(worldPosition, level.getBlockState(worldPosition), level.getBlockState(worldPosition), 2);
		            }
	            };
	        </#list>
	    </#if>

	    public FluidTank getFluidTank0() {
	        return fluidTank0;
	    }

	    <#if fluidTank != "">
	        <#list fluidTank.tanks as tank>
	            public FluidTank getFluidTank${tank?index + 1}() {
	                return fluidTank${tank?index + 1};
	            }
	        </#list>
	    </#if>

        // FtaO: Holds all fluid tanks + extra with individual type setting
	    private final FluidTank[] fluidTanks = {
	        fluidTank0
	        <#if fluidTank != "">
	            <#list fluidTank.tanks as tank>
	                , fluidTank${tank?index + 1}
	            </#list>
	        </#if>
	    };

	    private final FluidTank[] ioTanks = {
	        <#if fluidTank != "">
	            <#assign ioTanks = []>

	            <#if fluidTank.inteType == "Default">
	                <#assign ioTanks += ["fluidTank0"]>
	            </#if>
	            <#list fluidTank.tanks as tank>
	                <#if tank.type == "Default">
	                    <#assign ioTanks += ["fluidTank${tank?index + 1}"]>
	                </#if>
	            </#list>

	            ${ioTanks?join(",")}
	        </#if>
	    };

	    private final FluidTank[] inputTanks = {
	        <#if fluidTank != "">
	            <#assign ioTanks = []>

	            <#if fluidTank.inteType == "Input">
	                <#assign ioTanks += ["fluidTank0"]>
	            </#if>
	            <#list fluidTank.tanks as tank>
	                <#if tank.type == "Input">
	                    <#assign ioTanks += ["fluidTank${tank?index + 1}"]>
	                </#if>
	            </#list>

	            ${ioTanks?join(",")}
	        </#if>
	    };

	    private final FluidTank[] outputTanks = {
	        <#if fluidTanks != "">
	            <#assign ioTanks = []>

	            <#if fluidTank.inteType == "Output">
	                <#assign ioTanks += ["fluidTank0"]>
	            </#if>
	            <#list fluidTank.tanks as tank>
	                <#if tank.type == "Output">
	                    <#assign ioTanks += ["fluidTank${tank?index + 1}"]>
	                </#if>
	            </#list>

	            ${ioTanks?join(",")}
	        </#if>
	    };
    </#if>

	@Override public <T> LazyOptional<T> getCapability(Capability<T> capability, @Nullable Direction facing) {
		if (!this.remove && facing != null && capability == ForgeCapabilities.ITEM_HANDLER)
			return handlers[facing.ordinal()].cast();

		<#if data.hasEnergyStorage>
		if (!this.remove && capability == ForgeCapabilities.ENERGY)
			return LazyOptional.of(() -> energyStorage).cast();
        </#if>

		<#if data.isFluidTank>
		if (!this.remove && capability == ForgeCapabilities.FLUID_HANDLER)
			return LazyOptional.of(() -> fluidHandler).cast();
        </#if>

		return super.getCapability(capability, facing);
	}

	@Override public void setRemoved() {
		super.setRemoved();
		for(LazyOptional<? extends IItemHandler> handler : handlers)
			handler.invalidate();
	}

}
</#compress>
<#-- @formatter:on -->