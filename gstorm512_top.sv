module gstorm512_top #(
    parameter [511:0] K_MASK_TOP    = 512'hACE_B00_DAB_BA0_000_123_456_789_ABC_DEF,
    parameter [511:0] KA_ANCHOR_TOP  = 512'h514E_474C_5254_5921_0000_0000_0000_0000
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [511:0] m_in,
    input  logic [511:0] g_in,
    input  logic         p_in,
    output logic [511:0] s_out,
    output logic [63:0]  link_entropy,
    output logic         reroute_trigger,
    output logic         link_stable
);

    logic [511:0] sr_to_gs_data;
    logic [511:0] gs_to_hr_data;
    logic         gs_valid;
    logic [8:0]   pipeline_delta;
    logic [511:0] mutated_shadow;
    logic [511:0] capacity_resolved_shadow;
    logic         matrix_stable;

    sr512_core #(
        .KA_ANCHOR(KA_ANCHOR_TOP)
    ) stage1_sr_inst (
        .clk  (clk),
        .rst_n(rst_n),
        .m_in (m_in),
        .s_rec(sr_to_gs_data)
    );

    assign pipeline_delta = stage1_sr_inst.delta_reg;

    shadow_mutation_core stage2_mutation_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .s_in   (sr_to_gs_data),
        .delta_n(pipeline_delta),
        .g_out  (mutated_shadow)
    );

    fractal_capacity_resolver stage2_resolver_inst (
        .clk           (clk),
        .rst_n         (rst_n),
        .g_in          (mutated_shadow),
        .delta_n       (pipeline_delta),
        .s_encoded     (capacity_resolved_shadow),
        .capacity_valid(matrix_stable)
    );

    gs512_core #(
        .K_MASK(K_MASK_TOP)
    ) stage2_gs_inst (
        .clk    (clk),
        .rst_n  (rst_n),
        .m_in   (sr_to_gs_data), 
        .g_in   (capacity_resolved_shadow),
        .p_in   (p_in),
        .s_rec  (gs_to_hr_data),
        .s_valid(gs_valid)
    );

    tr512_core stage3_tr_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .delta_n        (pipeline_delta),
        .e_drift        (link_entropy),
        .proactive_alert(reroute_trigger)
    );

    always_comb begin
        if (gs_valid && matrix_stable) begin
            s_out        = gs_to_hr_data;
            link_stable  = 1'b1;
        } else begin
            s_out        = sr_to_gs_data;
            link_stable  = 1'b0;
        }
    end

endmodule
