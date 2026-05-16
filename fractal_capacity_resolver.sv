module fractal_capacity_resolver #(
    parameter [63:0] PI_ANCHOR = 64'h3141_5926_5358_9793
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] g_in,
    input  logic [8:0]   delta_n,
    output logic [511:0] s_encoded,
    output logic         capacity_valid
);

    logic [63:0]  path_hash;
    logic [511:0] dynamic_compression_mask;
    integer i;

    always_comb begin
        path_hash = PI_ANCHOR ^ {55'h0, delta_n};
        for (i = 0; i < 8; i = i + 1) begin
            path_hash = path_hash ^ g_in[(i*64) +: 64];
        end
    end

    always_comb begin
        for (i = 0; i < 8; i = i + 1) begin
            dynamic_compression_mask[(i*64) +: 64] = g_in[(i*64) +: 64] ^ (path_hash.rotate_left(i * 7));
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_encoded      <= 512'h0;
            capacity_valid <= 1'b0;
        } else begin
            s_encoded      <= dynamic_compression_mask;
            capacity_valid <= 1'b1;
        }
    end

endmodule
