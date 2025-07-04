module top_module(
    input clk,
    input areset,

    input  predict_valid,
    input  [6:0] predict_pc,
    output       predict_taken,
    output [6:0] predict_history,

    input train_valid,
    input train_taken,
    input train_mispredicted,
    input [6:0] train_history,
    input [6:0] train_pc
);

    reg [1:0] pht [0:127];
    reg [6:0] history;

    wire [6:0] predict_index = predict_pc ^ history;
    assign predict_taken = (pht[predict_index] >= 2'd2);
    assign predict_history = history;

    wire [6:0] train_index = train_pc ^ train_history;

    integer i;

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            history <= 7'b0;
            for (i = 0; i < 128; i = i + 1) begin
                pht[i] <= 2'b01;
            end
        end else begin
            if (train_valid) begin
                if (train_taken) begin
                    if (pht[train_index] != 2'b11)
                        pht[train_index] <= pht[train_index] + 1;
                end else begin
                    if (pht[train_index] != 2'b00)
                        pht[train_index] <= pht[train_index] - 1;
                end

                if (train_mispredicted) begin
                    history <= {train_history[5:0], train_taken};
                end else if (predict_valid) begin
                    history <= {history[5:0], predict_taken};
                end
            end else if (predict_valid) begin
                history <= {history[5:0], predict_taken};
            end
        end
    end

endmodule
