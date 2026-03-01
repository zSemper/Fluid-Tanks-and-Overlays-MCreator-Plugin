Blockly.Blocks["validation_mutator_container"] = {
    init: function () {
        this.appendDummyInput().appendField(javabridge.t("blockly.block.validation_mutator.container"));
        this.appendStatementInput("STACK");
        this.contextMenu = false;
        this.setColour("#a5a55b");
    }
};

Blockly.Blocks["validation_mutator_input"] = {
    init: function () {
        this.appendDummyInput().appendField(javabridge.t("blockly.block.validation_mutator.input"));
        this.setPreviousStatement(true);
        this.setNextStatement(true);
        this.contextMenu = false;
        this.fieldValues_ = [];
        this.setColour("#a5a55b");
    }
};

Blockly.Extensions.registerMutator(
    "validation_mutator",
    simpleRepeatingInputMixin(
        "validation_mutator_container",
        "validation_mutator_input",
        "entry",
        function(thisBlock, inputName, index) {
            thisBlock.appendValueInput(inputName + index)
                     .setCheck("Boolean")
                     .setAlign(Blockly.Input.Align.RIGHT);
        }),
    undefined,
    [ "validation_mutator_input" ]
);