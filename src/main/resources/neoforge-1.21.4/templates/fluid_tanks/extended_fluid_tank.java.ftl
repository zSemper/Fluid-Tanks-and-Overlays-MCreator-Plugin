/**
 * Copyright (c) 2025 zSemper
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the MIT License
 */

<#-- @formatter:off -->

package ${package}.utils;

public class ExtendedFluidTank extends FluidTank {
    private final int baseCapacity;
    private final Predicate<FluidStack> baseValidator;

    public ExtendedFluidTank(int capacity) {
        this(capacity, stack -> true);
    }

    public ExtendedFluidTank(int capacity, Predicate<FluidStack> validator) {
        super(capacity, validator);
        this.baseCapacity = capacity;
        this.baseValidator = validator;
    }


    /**
     * Resets the capacity of the tank back to its original value
     *
     * @param voidOverflow Controls if the access fluid inside the tank should be deleted
     */
    public void resetCapacity(boolean voidOverflow) {
        this.capacity = baseCapacity;

        if (voidOverflow && (!fluid.isEmpty() && fluid.getAmount() > baseCapacity)) {
            fluid.setAmount(baseCapacity);
        }

        onContentsChanged();
    }

    /**
     * Resets the validation for the fluids allowed in the tank to its original value
     *
     * @param voidBlacklisted Controls if the fluid, if blacklisted, should be deleted from the tank
     */
    public void resetValidator(boolean voidBlacklisted) {
        this.validator = baseValidator;

        if (voidBlacklisted && (!fluid.isEmpty() && !baseValidator.test(fluid))) {
            fluid = FluidStack.EMPTY;
        }

        onContentsChanged();
    }

    /**
     * Helper method for cleaner code and auto checking to prevent higher fluid amount than capacity
     *
     * @param fluid The fluid that is gonna be set in the tank
     * @param amount The amount of fluid that is in the tank
     *               Amount can be higher than tank capacity and gets evaluated in the method
    */
    public void setFluid(Fluid fluid, int amount) {
        int min = Math.min(amount, this.getCapacity());
        setFluid(new FluidStack(fluid, min));
    }

    /**
     * Overrides the default {@code FluidTank#readFromNBT} method to retrieve the capacity of the tank
     *
     * @param lookupProvider The provider to deserialize the {@code fluid} FluidStack
     * @param nbt The data of the tank
     * @return Returns the ExtendedFluidTank with it's set data
     */
    @Override
    public ExtendedFluidTank readFromNBT(HolderLookup.Provider lookupProvider, CompoundTag nbt) {
        fluid = FluidStack.parseOptional(lookupProvider, nbt.getCompound("Fluid"));
        if (nbt.get("Capacity") instanceof IntTag tag) {
            capacity = tag.getAsInt();
        }
        return this;
    }

    /**
     * Overrides the default {@code FluidTank#writeToNBT} method to store the capacity of the tank
     *
     * @param lookupProvider The provider to serialize the {@code fluid} FluidStack
     * @param nbt Stores the data of the tank
     * @return Returns the stored data of the tank
     */
    @Override
    public CompoundTag writeToNBT(HolderLookup.Provider lookupProvider, CompoundTag nbt) {
        if (!fluid.isEmpty()) {
            nbt.put("Fluid", fluid.save(lookupProvider));
        }
        nbt.put("Capacity", IntTag.valueOf(capacity));
        return nbt;
    }
}

<#-- @formatter:on -->