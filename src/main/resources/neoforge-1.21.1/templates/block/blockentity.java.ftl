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
<#include "../procedures.java.ftl">

<#assign tanks = w.hasElementsOfType("fluid_tanks")?then(w.getGElementsOfType("fluid_tanks")?filter(tank -> tanks.block == name), "")>
<#assign fluidTank = tanks?has_content?then(tanks[0], "")>

package ${package}.block.entity;

<#compress>
public class ${name}BlockEntity extends RandomizableContainerBlockEntity implements WorldlyContainer
 		<#if data.sensitiveToVibration>, GameEventListener.Provider<VibrationSystem.Listener>, VibrationSystem</#if> {

	private NonNullList<ItemStack> stacks = NonNullList.withSize(${data.inventorySize}, ItemStack.EMPTY);

	<#if data.sensitiveToVibration>
	private final VibrationSystem.Listener vibrationListener = new VibrationSystem.Listener(this);
	private final VibrationSystem.User vibrationUser = new VibrationUser(this.getBlockPos());
	private VibrationSystem.Data vibrationData = new VibrationSystem.Data();
	</#if>

	<#if data.renderType() == 4>
		<#list data.animations as animation>
		public final AnimationState animationState${animation?index} = new AnimationState();
		</#list>
	</#if>

	public ${name}BlockEntity(BlockPos position, BlockState state) {
		super(${JavaModName}BlockEntities.${REGISTRYNAME}.get(), position, state);
	}

	@Override public void loadAdditional(CompoundTag compound, HolderLookup.Provider lookupProvider) {
		super.loadAdditional(compound, lookupProvider);

		if (!this.tryLoadLootTable(compound))
			this.stacks = NonNullList.withSize(this.getContainerSize(), ItemStack.EMPTY);

		ContainerHelper.loadAllItems(compound, this.stacks, lookupProvider);

		<#if data.hasEnergyStorage>
		if(compound.get("energyStorage") instanceof IntTag intTag)
			energyStorage.deserializeNBT(lookupProvider, intTag);
		</#if>

		<#if data.isFluidTank>
		    <#if fluidTank != "">
		        for(int i = 0; i < fluidTanks.length; i++) {
		            fluidTanks[i].readFromNBT(lookupProvider, compound.getCompound("fluidTank" + i));
		        }
		    <#else>
		        fluidTank0.readFromNBT(lookupProvider, compound.getCompound("fluidTank0"));
		    </#if>
		</#if>

		<#if data.sensitiveToVibration>
		if (compound.contains("listener", 10)) {
			VibrationSystem.Data.CODEC.parse(lookupProvider.createSerializationContext(NbtOps.INSTANCE), compound.getCompound("listener"))
					.resultOrPartial(e -> ${JavaModName}.LOGGER.error("Failed to parse vibration listener for ${data.name}: '{}'", e))
					.ifPresent(data -> this.vibrationData = data);
		}
		</#if>
	}

	@Override public void saveAdditional(CompoundTag compound, HolderLookup.Provider lookupProvider) {
		super.saveAdditional(compound, lookupProvider);

		if (!this.trySaveLootTable(compound)) {
			ContainerHelper.saveAllItems(compound, this.stacks, lookupProvider);
		}

		<#if data.hasEnergyStorage>
		compound.put("energyStorage", energyStorage.serializeNBT(lookupProvider));
		</#if>

		<#if data.isFluidTank>
		    <#if fluidTank != "">
		        for(int i = 0; i < fluidTanks.length; i++) {
		            compound.put("fluidTank" + i, fluidTanks[i].writeToNBT(lookupProvider, new CompoundTag()));
		        }
		    <#else>
		        compound.put("fluidTank0", fluidTank0.writeToNBT(lookupProvider, new CompoundTag()));
            </#if>
		</#if>

		<#if data.sensitiveToVibration>
		VibrationSystem.Data.CODEC.encodeStart(lookupProvider.createSerializationContext(NbtOps.INSTANCE), this.vibrationData)
				.resultOrPartial(e -> ${JavaModName}.LOGGER.error("Failed to encode vibration listener for ${data.name}: '{}'", e))
				.ifPresent(listener -> compound.put("listener", listener));
		</#if>
	}

	@Override public ClientboundBlockEntityDataPacket getUpdatePacket() {
		return ClientboundBlockEntityDataPacket.create(this);
	}

	@Override public CompoundTag getUpdateTag(HolderLookup.Provider lookupProvider) {
		return this.saveWithFullMetadata(lookupProvider);
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

	<#if data.inventoryStackSize != 99>
	@Override public int getMaxStackSize() {
		return ${data.inventoryStackSize};
	}
	</#if>

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

	<#-- START: WorldlyContainer -->
	@Override public int[] getSlotsForFace(Direction side) {
		return IntStream.range(0, this.getContainerSize()).toArray();
	}

	@Override public boolean canPlaceItemThroughFace(int index, ItemStack itemstack, @Nullable Direction direction) {
		return this.canPlaceItem(index, itemstack)
		<#if hasProcedure(data.inventoryAutomationPlaceCondition)>&&
			<@procedureCode data.inventoryAutomationPlaceCondition, {
				"index": "index",
				"itemstack": "itemstack",
				"direction": "direction"
			}, false/>
		</#if>;
	}

	@Override public boolean canTakeItemThroughFace(int index, ItemStack itemstack, Direction direction) {
		<#list data.inventoryInSlotIDs as id>
		if (index == ${id})
			return false;
		</#list>
		<#if hasProcedure(data.inventoryAutomationTakeCondition)>
			return <@procedureCode data.inventoryAutomationTakeCondition, {
				"index": "index",
				"itemstack": "itemstack",
				"direction": "direction"
			}, false/>;
		<#else>
			return true;
		</#if>
	}
	<#-- END: WorldlyContainer -->

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

	public EnergyStorage getEnergyStorage() {
		return energyStorage;
	}
	</#if>

	<#if data.isFluidTank>
        // FTaO: modifies the IFluidHandler to work with all tanks instead of only the first one
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
						    return tank.fill(stack.copyWithAmount(fillAmount), action);
					    } else {
						    return 0;
					    }
				    }

				    if(tank.isEmpty() && tank.isFluidValid(stack)) {
					    return tank.fill(stack.copyWithAmount(stack.getAmount()), action);
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

        // FTaO: Used in BlockEntity Init and returns the entire IFluidHandler instead of the IFluidHandler of the first set fluid tank
	    public IFluidHandler getFluidTank() {
		    return fluidHandler;
	    }

	    private final FluidTank fluidTank0 = new FluidTank(${data.fluidCapacity}
		    <#if data.fluidRestrictions?has_content>
		        , fs -> {
		            <#list data.fluidRestrictions as fluidRestriction>
                        if (fs.getFluid() == ${fluidRestriction}) return true;
                    </#list>
		            return false;
		        }
		    </#if>
	    ) {
		    @Override protected void onContentsChanged() {
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
	        <#if fluidTank != "">
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

    <#if data.sensitiveToVibration>
    @Override public VibrationSystem.Data getVibrationData() {
    	return this.vibrationData;
    }

    @Override public VibrationSystem.User getVibrationUser() {
    	return this.vibrationUser;
    }

    @Override public VibrationSystem.Listener getListener() {
    	return this.vibrationListener;
    }

	private class VibrationUser implements VibrationSystem.User {

		private final int x;
		private final int y;
		private final int z;
		private final PositionSource positionSource;

		public VibrationUser(BlockPos blockPos) {
			this.x = blockPos.getX();
			this.y = blockPos.getY();
			this.z = blockPos.getZ();
			this.positionSource = new BlockPositionSource(blockPos);
		}

		@Override public PositionSource getPositionSource() {
			return this.positionSource;
		}

		<#if data.vibrationalEvents?has_content>
		@Override public TagKey<GameEvent> getListenableEvents() {
			return TagKey.create(Registries.GAME_EVENT, ResourceLocation.withDefaultNamespace("${data.getModElement().getRegistryName()}_can_listen"));
		}
		</#if>

		@Override public int getListenerRadius() {
			<#if hasProcedure(data.vibrationSensitivityRadius)>
				Level world = ${name}BlockEntity.this.getLevel();
				BlockState blockstate = ${name}BlockEntity.this.getBlockState();
				return (int) <@procedureOBJToNumberCode data.vibrationSensitivityRadius/>;
			<#else>
				return ${data.vibrationSensitivityRadius.getFixedValue()};
			</#if>
		}

		@Override public boolean canReceiveVibration(ServerLevel world, BlockPos vibrationPos, Holder<GameEvent> holder, GameEvent.Context context) {
			<#if hasProcedure(data.canReceiveVibrationCondition)>
				return <@procedureCode data.canReceiveVibrationCondition {
					"x": "x",
					"y": "y",
					"z": "z",
					"vibrationX": "vibrationPos.getX()",
					"vibrationY": "vibrationPos.getY()",
					"vibrationZ": "vibrationPos.getZ()",
					"world": "world",
					"entity": "context.sourceEntity()",
					"blockstate": "${name}BlockEntity.this.getBlockState()"
				}/>
			<#else>
				return true;
			</#if>
		}

		@Override public void onReceiveVibration(ServerLevel world, BlockPos vibrationPos, Holder<GameEvent> holder, Entity entity, Entity projectileShooter, float distance) {
			<#if hasProcedure(data.onReceivedVibration)>
				<@procedureCode data.onReceivedVibration {
					"x": "x",
					"y": "y",
					"z": "z",
					"vibrationX": "vibrationPos.getX()",
					"vibrationY": "vibrationPos.getY()",
					"vibrationZ": "vibrationPos.getZ()",
					"world": "world",
					"blockstate": "${name}BlockEntity.this.getBlockState()",
					"entity": "entity",
					"sourceentity": "projectileShooter"
				}/>
			</#if>
		}

		@Override public void onDataChanged() {
			${name}BlockEntity.this.setChanged();
		}

		@Override public boolean requiresAdjacentChunksToBeTicking() {
			return true;
		}
	}
    </#if>
}
</#compress>
<#-- @formatter:on -->