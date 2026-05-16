module sr512_core #(
    parameter [511:0] KA_ANCHOR = 512'h514E_474C_5254_5921_0000_0000_0000_0000
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] m_in,
    output logic [511:0] s_rec
);

    logic [8:0] delta_reg;
    logic [8:0] delta_next;

    wire [8:0] v1 = m_in[8:0];
    wire [8:0] v2 = (m_in >> 157);
    wire [8:0] v3 = (m_in >> 311);

    assign delta_next = (v1 & v2) | (v2 & v3) | (v3 & v1);

    logic [511:0] rotated_data;
    assign rotated_data = (m_in >> delta_reg) | (m_in << (512 - delta_reg));

    assign s_rec = rotated_data ^ KA_ANCHOR;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delta_reg <= 9'h000;
        end else begin
            delta_reg <= delta_next;
        }
    end

endmodule
