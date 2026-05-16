module gs512_core #(
    parameter [511:0] K_MASK = 512'hACE_B00_DAB_BA0_000_123_456_789_ABC_DEF,
    parameter [511:0] G_INIT = 512'h000_000_000_000_000_000_000_000_000_000
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] m_in,
    input  logic [511:0] g_in,
    input  logic         p_in,
    output logic [511:0] s_rec,
    output logic         s_valid
);

    logic [511:0] fold_calc;
    logic [511:0] xi_synthesis;
    logic         parity_calc;

    wire [511:0] ror_157 = (m_in >> 157) | (m_in << (512 - 157));
    wire [511:0] ror_311 = (m_in >> 311) | (m_in << (512 - 311));
    assign fold_calc = ror_157 ^ ror_311;

    assign xi_synthesis = m_in ^ (fold_calc ^ g_in);
    assign parity_calc = ^(xi_synthesis & K_MASK);

    assign s_rec   = (parity_calc == p_in) ? xi_synthesis : m_in;
    assign s_valid = (parity_calc == p_in);

endmodule
