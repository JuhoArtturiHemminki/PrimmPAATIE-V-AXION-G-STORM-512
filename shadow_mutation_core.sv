module shadow_mutation_core #(
    parameter [63:0] MUTATION_SEED = 64'hBF5F_5245_D1A3_432D
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] s_in,
    input  logic [8:0]   delta_n,
    output logic [511:0] g_out
);

    logic [511:0] intermediate_mutation;
    logic [63:0]  dynamic_mask;
    integer i;

    assign dynamic_mask = MUTATION_SEED ^ {55'h0, delta_n};

    always_comb begin
        for (i = 0; i < 8; i = i + 1) begin
            intermediate_mutation[(i*64) +: 64] = s_in[(i*64) +: 64] ^ dynamic_mask;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            g_out <= 512'h0;
        } else begin
            g_out <= (intermediate_mutation >> 157) | (intermediate_mutation << (512 - 157));
        }
    end

endmodule
