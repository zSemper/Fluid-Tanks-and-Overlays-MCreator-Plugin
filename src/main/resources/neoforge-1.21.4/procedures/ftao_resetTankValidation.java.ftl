<#include "mcelements.ftl">
<@addTemplate file="static/ftao_getFluidTank.java.ftl" />

Optional.ofNullable(getFluidTank(world, BlockPos.containing(x, y, z), ${opt.toInt(input$index)})).ifPresent(t -> t.resetValidator(${input$void}));