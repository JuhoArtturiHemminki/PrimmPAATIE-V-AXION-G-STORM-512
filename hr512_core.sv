module hr512_core #(
    parameter [63:0] PRIME_157 = 64'h0000_0000_0000_009D,
    parameter [63:0] PRIME_311 = 64'h0000_0000_0000_0137
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] s_rec_in,
    input  logic [63:0]  e_drift_in,
    output logic [511:0] s_out,
    output logic         jamming_detected
);

    logic [63:0]  dynamic_anchor;
    logic [511:0] filtered_matrix;
    integer i;

    assign dynamic_anchor = (e_drift_in * PRIME_157) ^ PRIME_311;
    assign jamming_detected = (e_drift_in > 64'h000F_FFFF_FFFF_FFFF);

    always_comb begin
        for (i = 0; i < 8; i = i + 1) begin
            filtered_matrix[(i*64) +: 64] = s_rec_in[(i*64) +: 64] ^ dynamic_anchor;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s_out <= 512'h0;
        } else begin
            s_out <= (filtered_matrix >> 9) | (filtered_matrix << (512 - 9));
        }
    end

endmodule
